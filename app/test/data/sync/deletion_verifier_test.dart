import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/sync/deletion_verifier.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';

// D1's verification (CR-160 W0, W2): what it returns as verified at server
// revision R is on this device, all of it; anything it can't establish is
// unverified, never a guess.

const _account = '01928c3e-0000-7000-8000-0000000000ff';
const _other = '01928c3e-0000-7000-8000-0000000000ee';
final _t = DateTime.utc(2026, 10, 23, 9);

Occurrence _task(String id, String title) =>
    occurrenceFixture().copyWith(id: id, userId: _account, title: title);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice a;
  late SyncDevice b;
  late DeletionVerifier verifier;

  DeletionVerifier verifierFor(SyncEngine engine, {SyncGateway? gateway}) =>
      DeletionVerifier(
        engine: engine,
        gateway: gateway ?? server.forDevice(),
        db: a.h.db,
        logger: a.h.logger,
      );

  setUp(() async {
    server = FakeSyncServer(_account);
    a = SyncDevice(server, _t, name: 'a');
    b = SyncDevice(server, _t, name: 'b');
    await a.start();
    await b.start();
    verifier = verifierFor(a.engine);
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  Future<String?> title(String id) async => (await a.occurrence(id))?.title;
  Future<void> remoteWrite(List<Occurrence> tasks) async {
    await b.write(tasks);
    await b.sync();
  }

  DeletionVerified verified(DeletionCheck c) {
    expect(c, isA<DeletionVerified>());
    return c as DeletionVerified;
  }

  AppFailure unverified(DeletionCheck c) {
    expect(c, isA<DeletionUnverified>());
    return (c as DeletionUnverified).failure;
  }

  test('W0: a device that never pulled gets everything first; verified at '
      "the server's revision", () async {
    await remoteWrite([for (var i = 1; i <= 7; i++) _task('o$i', 'task $i')]);
    final c = verified(await verifier.verify(_account));
    expect(c.serverRevision, server.revision);
    for (var i = 1; i <= 7; i++) {
      expect(await title('o$i'), 'task $i', reason: 'every page (size 3)');
    }
  });

  test('its own unsynced edit goes up first; the outbox ends empty', () async {
    await a.write([_task('mine', 'local only')]);
    final c = verified(await verifier.verify(_account));
    expect(server.table('occurrences')['mine']?['title'], 'local only');
    expect(await a.outboxSize(), 0);
    expect(c.serverRevision, server.revision);
  });

  test('a remote change between the two revision reads is pulled on the '
      'next attempt; verified at the newer revision', () async {
    await remoteWrite([_task('o1', 'before')]);
    await a.sync();
    server.beforeRevisionRead = () {
      // First read: nothing. Second read: another device writes first.
      server.beforeRevisionRead = () =>
          server.edit('occurrences', 'o1', {'title': 'during'});
    };
    final c = verified(await verifier.verify(_account));
    expect(c.serverRevision, server.revision);
    expect(await title('o1'), 'during');
  });

  test('a row that committed late (its updated_at before this device\'s '
      'cursor) is still pulled: the check starts from the beginning', () async {
    await remoteWrite([_task('o1', 'first'), _task('o2', 'second')]);
    await a.sync(); // the cursor is now past both
    // A transaction that started earlier commits now: its updated_at is
    // older than the cursor, so a cursor pull never sees it.
    final late = {...server.table('occurrences')['o1']!}
      ..['id'] = 'late'
      ..['title'] = 'committed late'
      ..['updated_at'] = '2026-10-23T00:00:00.000Z';
    server.table('occurrences')['late'] = late;
    server.revision++;
    await a.sync();
    expect(await title('late'), isNull, reason: 'the normal pull misses it');
    verified(await verifier.verify(_account));
    expect(await title('late'), 'committed late');
  });

  test('a local edit between the two reads goes up before it counts as '
      'verified', () async {
    await remoteWrite([_task('o1', 'x')]);
    server.beforeRevisionRead = () {
      server.beforeRevisionRead = () => a.write([_task('mine', 'meanwhile')]);
    };
    final c = verified(await verifier.verify(_account));
    expect(server.table('occurrences')['mine']?['title'], 'meanwhile');
    expect(await a.outboxSize(), 0);
    expect(c.serverRevision, server.revision);
  });

  test(
    'a server that keeps changing: unverified after the bounded tries',
    () async {
      await remoteWrite([_task('o1', 'x')]);
      var n = 0;
      void churn() {
        server.edit('occurrences', 'o1', {'title': 'churn ${n++}'});
        server.beforeRevisionRead = churn;
      }

      server.beforeRevisionRead = () => server.beforeRevisionRead = churn;
      expect(
        unverified(await verifier.verify(_account)),
        isA<ReviewChangedFailure>(),
      );
    },
  );

  test('offline: unverified, nothing claimed', () async {
    server.failNext = SyncTrouble.offline;
    expect(
      unverified(await verifier.verify(_account)),
      isA<NetworkFailure>().having(
        (f) => f.kind,
        'kind',
        NetworkFailureKind.offline,
      ),
    );
  });

  test('a fast clock (pushes wait): unverified', () async {
    final fast = SyncEngine(
      db: a.h.db,
      gateway: server.forDevice(),
      hlc: a.h.hlc,
      clock: a.h.clock,
      clockOffset: () => const Duration(minutes: 10),
    );
    await a.write([_task('mine', 'waiting for the clock')]);
    expect(
      unverified(await verifierFor(fast).verify(_account)),
      isA<NetworkFailure>().having(
        (f) => f.kind,
        'kind',
        NetworkFailureKind.server,
      ),
    );
  });

  test(
    'an open conflict (a local value not in the rows): unverified',
    () async {
      await a.h.db
          .into(a.h.db.conflicts)
          .insert(
            ConflictsCompanion.insert(
              id: 'c1',
              userId: _account,
              entity: 'occurrences',
              entityId: 'o1',
              field: 'title',
              createdAt: 0,
            ),
          );
      expect(
        unverified(await verifier.verify(_account)),
        isA<ConflictFailure>(),
      );
    },
  );

  test('a soft delete on the server arrives as a tombstone', () async {
    await remoteWrite([_task('o1', 'to delete')]);
    await a.sync();
    server.edit('occurrences', 'o1', {
      'deleted_at': DateTime.utc(2026, 10, 23, 10).toIso8601String(),
    });
    verified(await verifier.verify(_account));
    expect((await a.occurrence('o1'))?.deletedAt, isNotNull);
  });

  test('a hard delete on the server: this copy keeps the row (the export '
      'holds at least the server state, never less)', () async {
    await remoteWrite([_task('o1', 'purged later')]);
    await a.sync();
    server.hardDelete('occurrences', 'o1');
    final c = verified(await verifier.verify(_account));
    expect(c.serverRevision, server.revision);
    expect(await title('o1'), 'purged later');
  });

  test('verifying again with nothing new leaves the local revision', () async {
    await remoteWrite([_task('o1', 'same')]);
    verified(await verifier.verify(_account));
    final before = await writeRevision(a.h.db, _account);
    verified(await verifier.verify(_account));
    expect(await writeRevision(a.h.db, _account), before);
  });

  test('the account switched during the verification: unverified', () async {
    await remoteWrite([_task('o1', 'x')]);
    server.beforeRevisionRead = () async {
      await a.signIn(_other);
    };
    expect(
      unverified(await verifier.verify(_account)),
      isA<ReviewChangedFailure>(),
    );
  });

  test('A → B → A after the full pull, before the answer: unverified (the '
      'result belongs to an ended session)', () async {
    await remoteWrite([_task('o1', 'x')]);
    server.beforeRevisionRead = () {
      server.beforeRevisionRead = () async {
        await a.signIn(_other);
        await a.signIn(_account);
      };
    };
    expect(
      unverified(await verifier.verify(_account)),
      isA<ReviewChangedFailure>(),
    );
  });

  test(
    'a background pull at the same time changes nothing about the result',
    () async {
      await remoteWrite([_task('o1', 'one'), _task('o2', 'two')]);
      final background = SyncEngine(
        db: a.h.db,
        gateway: server.forDevice(),
        hlc: a.h.hlc,
        clock: a.h.clock,
      );
      final results = await Future.wait([
        verifier.verify(_account),
        background.run(_account).then((_) => null),
      ]);
      final c = verified(results.first!);
      expect(c.serverRevision, server.revision);
      expect(
        await DriftOccurrenceRepository(a.h.db).findById(_account, 'o2'),
        isNotNull,
      );
    },
  );
}
