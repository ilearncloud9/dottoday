import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/drift_conflict_store.dart';
import 'package:dottoday/data/sync/engine_sync_service.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
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
      adopt: (id) async => adopted.add(id),
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
  test('a failed run is retried until one succeeds, then stops', () async {
    await service.dispose();
    await accounts.close();
    accounts = StreamController<String?>();
    final retrying = EngineSyncService(
      engine: device.engine,
      accounts: accounts.stream,
      adopt: (_) async {},
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
}
