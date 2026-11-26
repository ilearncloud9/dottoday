import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/drift_conflict_store.dart';
import 'package:dottoday/data/sync/engine_sync_service.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/memory_log_sink.dart';
import '../../support/sync_device.dart';

// What the Sync sheet, banner and pill read (docs/09 M6.2/M6.3, R-08).

const _account = '01928c3e-0000-7000-8000-0000000000ff';
final _t = DateTime.utc(2026, 10, 23, 9);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice device;
  late StreamController<String?> accounts;
  late EngineSyncService service;
  late List<String> adopted;

  setUp(() async {
    server = FakeSyncServer(_account);
    device = SyncDevice(server, _t);
    await device.start();
    accounts = StreamController<String?>();
    adopted = [];
    service = EngineSyncService(
      engine: device.engine,
      accounts: accounts.stream,
      adopt: (id) async {
        adopted.add(id);
        return true;
      },
      conflicts: DriftConflictStore(
        db: device.h.db,
        writes: device.h.writes,
        clock: device.h.clock,
      ),
      remoteChanges: server.forDevice().changes(),
      clock: device.h.clock,
      logger: Logger(MemoryLogSink(), device.h.clock),
      settle: Duration.zero,
    );
  });
  tearDown(() async {
    await service.dispose();
    await accounts.close();
    await device.close();
  });

  Future<SyncStatus> settled() async {
    await pumpEventQueue(times: 50);
    return service.watch().first;
  }

  test('signed out: local only, Sync now does nothing', () async {
    accounts.add(null);
    expect((await settled()).state, SyncState.localOnly);
    await service.syncNow();
    expect(server.pushes, 0);
  });

  test('signed in: adopts, syncs, says when', () async {
    await device.write([occurrenceFixture().copyWith(userId: _account)]);
    accounts.add(_account);
    final s = await settled();
    expect(adopted, [_account]);
    expect(s.state, SyncState.synced);
    expect(s.lastSyncedUtc, _t);
    expect(s.pending, 0);
    expect(server.table('occurrences'), hasLength(1));
  });

  // CR-160 criterion 9: the sign-in step failed. Nothing syncs for the
  // account until it succeeds; the status says so; Sync now tries again.
  test('a failed sign-in step: error, no sync, Sync now retries', () async {
    var fail = true;
    final calls = <String>[];
    final retrying = EngineSyncService(
      engine: device.engine,
      accounts: Stream.value(_account),
      adopt: (id) async {
        calls.add(id);
        if (fail) throw StateError('disk full');
        return true;
      },
      conflicts: DriftConflictStore(
        db: device.h.db,
        writes: device.h.writes,
        clock: device.h.clock,
      ),
      remoteChanges: const Stream.empty(),
      clock: device.h.clock,
      logger: Logger(MemoryLogSink(), device.h.clock),
      settle: Duration.zero,
      retryFirst: const Duration(hours: 1),
    );
    addTearDown(retrying.dispose);
    await device.write([occurrenceFixture().copyWith(userId: _account)]);
    await pumpEventQueue(times: 50);
    expect((await retrying.watch().first).state, SyncState.error);
    expect(server.pushes, 0, reason: 'never a round before the step');

    fail = false;
    await retrying.syncNow();
    await pumpEventQueue(times: 50);
    expect(calls, [_account, _account]);
    expect((await retrying.watch().first).state, SyncState.synced);
    expect(server.table('occurrences'), hasLength(1));
  });

  // CR-160: the guest's tasks wait for the person's choice. Nothing syncs
  // and nothing retries by itself meanwhile.
  test('a sign-in waiting for the guest choice: no sync, no retry', () async {
    final waiting = EngineSyncService(
      engine: device.engine,
      accounts: Stream.value(_account),
      adopt: (_) async => false,
      conflicts: DriftConflictStore(
        db: device.h.db,
        writes: device.h.writes,
        clock: device.h.clock,
      ),
      remoteChanges: const Stream.empty(),
      clock: device.h.clock,
      logger: Logger(MemoryLogSink(), device.h.clock),
      settle: Duration.zero,
    );
    addTearDown(waiting.dispose);
    await device.write([occurrenceFixture().copyWith(userId: _account)]);
    await pumpEventQueue(times: 50);
    expect(server.pushes, 0);
    expect((await waiting.watch().first).state, isNot(SyncState.error));
  });

  // Signing in during onboarding: the app under the flow is offstage and
  // Riverpod pauses its listeners. What changed meanwhile must arrive on
  // resume, not leave Settings on "On this device".
  test('a paused listener gets the latest status on resume', () async {
    final seen = <SyncState>[];
    final sub = service.watch().listen((s) => seen.add(s.state))..pause();
    accounts.add(_account);
    await pumpEventQueue(times: 50);
    sub.resume();
    await pumpEventQueue();
    await sub.cancel();
    expect(seen.first, SyncState.localOnly);
    expect(seen.last, SyncState.synced);
  });

  test('offline: the status says so; Sync now reports it', () async {
    accounts.add(_account);
    await settled();
    server.failNext = SyncTrouble.offline;
    final r = await service.syncNow();
    expect(r, isA<Err<void, AppFailure>>());
    expect((await settled()).state, SyncState.offline);
  });

  // CR-160 blocker 5: "Sync now" pressed while a run is under way reports
  // how that run and the one it asked for end, never "Ok" before.
  for (final refused in [true, false]) {
    test('Sync now during a run reports its end (refused: $refused)', () async {
      accounts.add(_account);
      await settled();
      await device.write([occurrenceFixture().copyWith(userId: _account)]);
      server.frozen = refused;
      final first = service.syncNow();
      final second = await service.syncNow();
      expect(
        second,
        refused ? isA<Err<void, AppFailure>>() : isA<Ok<void, AppFailure>>(),
      );
      await first;
      server.frozen = false;
    });
  }

  test('a local write is pushed shortly after', () async {
    accounts.add(_account);
    await settled();
    await device.write([occurrenceFixture().copyWith(userId: _account)]);
    await pumpEventQueue(times: 100);
    expect(server.table('occurrences'), hasLength(1));
    expect((await settled()).pending, 0);
  });

  test('a conflict shows; "keep mine" writes it again and wins', () async {
    accounts.add(_account);
    await settled();
    await device.h.db
        .into(device.h.db.conflicts)
        .insert(
          ConflictsCompanion.insert(
            id: 'c1',
            userId: _account,
            entity: 'occurrences',
            entityId: occurrenceFixture().id,
            field: 'title',
            mine: const Value('"Mine"'),
            theirs: const Value('"Theirs"'),
            createdAt: _t.millisecondsSinceEpoch,
          ),
        );
    await device.write([
      occurrenceFixture().copyWith(userId: _account, title: 'Theirs'),
    ]);
    var s = await settled();
    expect(s.conflicts.single.mine, 'Mine');
    expect(s.conflicts.single.theirs, 'Theirs');
    expect(s.conflicts.single.title, 'Theirs');

    expect(
      await service.resolve('c1', ConflictChoice.mine),
      isA<Ok<void, AppFailure>>(),
    );
    s = await settled();
    expect(s.conflicts, isEmpty);
    expect((await device.occurrence(occurrenceFixture().id))!.title, 'Mine');
    expect(server.table('occurrences').values.single['title'], 'Mine');
  });

  // Nothing runs on a clock (docs/04 §4 "Triggers"): a failed run must come back on
  // its own, or an outage would wait for the next edit (R-08).
  ConflictUndo undoOf(Result<ConflictUndo, AppFailure> r) =>
      (r as Ok<ConflictUndo, AppFailure>).value;

  /// A conflict on [field] of the fixture task, the row holding [row].
  Future<void> conflictOn(
    String field,
    String? mine,
    String? theirs,
    Occurrence row,
  ) async {
    accounts.add(_account);
    await settled();
    await device.h.db
        .into(device.h.db.conflicts)
        .insert(
          ConflictsCompanion.insert(
            id: 'c1',
            userId: _account,
            entity: 'occurrences',
            entityId: occurrenceFixture().id,
            field: field,
            mine: Value(mine),
            theirs: Value(theirs),
            createdAt: _t.millisecondsSinceEpoch,
          ),
        );
    await device.write([row]);
    await settled();
  }

  // Undo after resolving (E-G4-7 C3, C5; ED-194, ED-483).
  test('Undo after "keep theirs" puts mine back as a new edit', () async {
    await conflictOn(
      'title',
      '"Mine"',
      '"Theirs"',
      occurrenceFixture().copyWith(userId: _account, title: 'Theirs'),
    );
    final undo = undoOf(await service.resolve('c1', ConflictChoice.theirs));
    expect((await device.occurrence(occurrenceFixture().id))!.title, 'Theirs');
    expect(await service.undoResolve(undo), isA<Ok<void, AppFailure>>());
    expect((await device.occurrence(occurrenceFixture().id))!.title, 'Mine');
    expect((await settled()).conflicts, isEmpty);
  });

  test('Undo after a change elsewhere opens a new conflict instead', () async {
    await conflictOn(
      'title',
      '"Mine"',
      '"Theirs"',
      occurrenceFixture().copyWith(userId: _account, title: 'Theirs'),
    );
    final undo = undoOf(await service.resolve('c1', ConflictChoice.theirs));
    await device.write([
      occurrenceFixture().copyWith(userId: _account, title: 'Newer'),
    ]);
    expect(await service.undoResolve(undo), isA<Ok<void, AppFailure>>());
    // Nothing overwritten: the newer value stays, and the two meet again.
    expect((await device.occurrence(occurrenceFixture().id))!.title, 'Newer');
    final open = (await settled()).conflicts.single;
    expect((open.mine, open.theirs), ('Mine', 'Newer'));
  });

  // Keep both for notes (ED-195): this device's, the label, the other's.
  test('"keep both" saves the two notes; Undo restores mine', () async {
    await conflictOn(
      'notes',
      '"Pull last quarter."',
      '"Ask Sam."',
      occurrenceFixture().copyWith(userId: _account, notes: 'Ask Sam.'),
    );
    final c = (await settled()).conflicts.single;
    expect((c.mineNotes, c.theirsNotes), ('Pull last quarter.', 'Ask Sam.'));
    final both = combinedNotes(c.mineNotes, c.theirsNotes, '— Other —');
    final undo = undoOf(
      await service.resolve('c1', ConflictChoice.both, combined: both),
    );
    expect(
      (await device.occurrence(occurrenceFixture().id))!.notes,
      'Pull last quarter.\n\n— Other —\nAsk Sam.',
    );
    await service.undoResolve(undo);
    expect(
      (await device.occurrence(occurrenceFixture().id))!.notes,
      'Pull last quarter.',
    );
  });

  test(
    '"keep both" over the notes limit is refused, nothing changes',
    () async {
      await conflictOn(
        'notes',
        '"a"',
        '"b"',
        occurrenceFixture().copyWith(userId: _account, notes: 'b'),
      );
      final r = await service.resolve(
        'c1',
        ConflictChoice.both,
        combined: 'x' * (maxNotesLength + 1),
      );
      expect(r, isA<Err<ConflictUndo, AppFailure>>());
      expect((await device.occurrence(occurrenceFixture().id))!.notes, 'b');
      expect((await settled()).conflicts, hasLength(1));
    },
  );

  test('a failed run is retried until one succeeds, then stops', () async {
    await service.dispose();
    await accounts.close();
    accounts = StreamController<String?>();
    final retrying = EngineSyncService(
      engine: device.engine,
      accounts: accounts.stream,
      adopt: (_) async => true,
      conflicts: DriftConflictStore(
        db: device.h.db,
        writes: device.h.writes,
        clock: device.h.clock,
      ),
      remoteChanges: const Stream.empty(),
      clock: device.h.clock,
      logger: Logger(MemoryLogSink(), device.h.clock),
      settle: Duration.zero,
      retryFirst: const Duration(milliseconds: 1),
    );
    service = retrying;
    await device.write([occurrenceFixture().copyWith(userId: _account)]);
    server.failNext = SyncTrouble.server;
    accounts.add(_account);
    final seen = <SyncState>[];
    final sub = retrying.watch().listen((s) => seen.add(s.state));
    for (var i = 0; i < 200 && !seen.contains(SyncState.synced); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    await sub.cancel();
    expect(seen, containsAllInOrder([SyncState.error, SyncState.synced]));
    expect(server.table('occurrences'), hasLength(1));
    final pushes = server.pushes;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(server.pushes, pushes, reason: 'no retry after a success');
  });

  // A sign-in the server no longer accepts (E-G4-7 A10, CR-158, ED-482):
  // "Session ended", not a generic error, and no timer behind it: only
  // signing in again helps.
  test('a refused sign-in ends the session and is not retried', () async {
    await service.dispose();
    await accounts.close();
    accounts = StreamController<String?>();
    final waiting = EngineSyncService(
      engine: device.engine,
      accounts: accounts.stream,
      adopt: (_) async => true,
      conflicts: DriftConflictStore(
        db: device.h.db,
        writes: device.h.writes,
        clock: device.h.clock,
      ),
      remoteChanges: const Stream.empty(),
      clock: device.h.clock,
      logger: Logger(MemoryLogSink(), device.h.clock),
      settle: Duration.zero,
      retryFirst: const Duration(milliseconds: 1),
    );
    service = waiting;
    await device.write([occurrenceFixture().copyWith(userId: _account)]);
    server.failAlways = SyncTrouble.session;
    accounts.add(_account);
    final seen = <SyncState>[];
    final sub = waiting.watch().listen((s) => seen.add(s.state));
    for (var i = 0; i < 200 && !seen.contains(SyncState.sessionEnded); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    // Let any queued trigger finish, then nothing more may come.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final calls = server.calls;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await sub.cancel();
    expect(seen.last, SyncState.sessionEnded);
    expect(seen, isNot(contains(SyncState.error)));
    expect(server.calls, calls, reason: 'no timer retries an ended session');
  });
}
