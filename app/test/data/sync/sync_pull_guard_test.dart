import 'dart:async';
import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';
import '../writes/write_harness.dart';

// CR-160 W1/W4: a pulled page writes only for the owner shown in the
// session the pull began in, never while that owner is sealed for deletion
// or being removed, never a row of another owner, and moves the owner's
// write revision exactly when a row really changed. A refused or failed
// page rolls back with its cursor.

const _account = '01928c3e-0000-7000-8000-0000000000ff';
const _other = '01928c3e-0000-7000-8000-0000000000ee';
final _t = DateTime.utc(2026, 10, 23, 9);

Occurrence _task(String id, String title) =>
    occurrenceFixture().copyWith(id: id, userId: _account, title: title);

/// A gateway that can hold a pull right before its page is written (the
/// page is fetched; its field versions are being read).
final class _Held implements SyncGateway {
  _Held(this._inner);

  final SyncGateway _inner;
  Completer<void>? _go; // armed: the next occurrences page waits on it
  Completer<void>? _release = Completer();
  Completer<void>? _reached;

  /// The next page waits at [atPage] until [release].
  void holdNextPage() {
    _go = _release = Completer();
    _reached = Completer();
  }

  Future<void> get atPage => _reached!.future;
  void release() => _release!.complete();

  @override
  Future<Map<String, Map<String, String>>> fieldVersions(
    String entity,
    List<String> ids,
  ) async {
    final go = _go;
    if (go != null && entity == 'occurrences') {
      _go = null;
      _reached!.complete();
      await go.future;
    }
    return _inner.fieldVersions(entity, ids);
  }

  @override
  Future<void> push(List<PushChange> changes) => _inner.push(changes);
  @override
  Future<List<Map<String, Object?>>> pull(
    String entity,
    PullCursor after, {
    required int limit,
  }) => _inner.pull(entity, after, limit: limit);
  @override
  Future<int> count(String entity, DateTime sinceUtc) =>
      _inner.count(entity, sinceUtc);
  @override
  Stream<void> changes() => _inner.changes();
  @override
  Future<({int revision, bool frozen})> accountRevision() =>
      _inner.accountRevision();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice a;
  late SyncDevice b;
  late _Held held;
  late SyncEngine engine;

  setUp(() async {
    server = FakeSyncServer(_account);
    a = SyncDevice(server, _t, name: 'a');
    b = SyncDevice(server, _t, name: 'b');
    await a.start();
    await b.start();
    held = _Held(server.forDevice());
    engine = SyncEngine(
      db: a.h.db,
      gateway: held,
      hlc: a.h.hlc,
      clock: a.h.clock,
      pageSize: 3,
    );
    await b.sync();
    await engine.run(_account); // the baseline: cursors and B's profile
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  Future<int> rev(String owner) => writeRevision(a.h.db, owner);
  Future<List<String>> cursors() async => [
    for (final c in await a.h.db.select(a.h.db.syncCursors).get())
      '${c.ownerId}/${c.entity}@${c.sinceAt}/${c.sinceId}',
  ];

  /// Cursors and the account's revision, for "nothing moved".
  Future<String> snapshot() async =>
      '${await cursors()} rev=${await rev(_account)}';
  Future<int> rows(String owner) async => (await (a.h.db.select(
    a.h.db.occurrences,
  )..where((o) => o.userId.equals(owner))).get()).length;
  Future<void> remoteWrite(List<Occurrence> tasks) async {
    await b.write(tasks);
    await b.sync();
  }

  test(
    'a change pulled after the export moves the revision (D1 sees it)',
    () async {
      final reviewed = await rev(_account);
      await remoteWrite([_task('o1', 'From the phone')]);
      await engine.run(_account);
      expect(await rev(_account), greaterThan(reviewed));
    },
  );

  test('pulling the same rows again (no change) leaves the revision', () async {
    await remoteWrite([_task('o1', 'Same')]);
    await engine.run(_account);
    final before = await rev(_account);
    await a.h.db.delete(a.h.db.syncCursors).go(); // everything again
    await engine.run(_account);
    expect(await rev(_account), before);
    expect(await rows(_account), 1);
  });

  test('a page of several changed rows moves this owner only', () async {
    final guest = await rev('device-local');
    final before = await rev(_account);
    await remoteWrite([
      _task('o1', 'one'),
      _task('o2', 'two'),
      _task('o3', 'three'),
    ]);
    await engine.run(_account);
    expect(await rev(_account), greaterThan(before));
    expect(await rev('device-local'), guest, reason: 'the guest is untouched');
    expect(await rows(_account), 3);
  });

  test('sealed for deletion: the page is refused, no row, no cursor, no '
      'revision', () async {
    await remoteWrite([_task('o1', 'late')]);
    final before = await snapshot();
    await sealForDeletion(a.h.db, _account);
    await expectLater(
      engine.run(_account),
      throwsA(
        isA<PullRefusedException>().having(
          (e) => e.reason,
          'reason',
          PullRefusal.sealed,
        ),
      ),
    );
    expect(await snapshot(), before);
    expect(await rows(_account), 0);
    await unsealDeletion(a.h.db, _account);
    await engine.run(_account);
    expect(await rows(_account), 1, reason: 'unsealed, the next pull takes it');
  });

  test(
    'a pull in flight across the account removal re-creates nothing',
    () async {
      await remoteWrite([_task('o1', 'in flight')]);
      held.holdNextPage();
      final run = engine.run(_account);
      await held.atPage;
      await beginAccountRemoval(a.h.db, _account);
      await finishAccountRemoval(a.h.db, _account);
      held.release();
      await expectLater(run, throwsA(isA<PullRefusedException>()));
      expect(await rows(_account), 0);
      expect(
        await (a.h.db.select(
          a.h.db.syncCursors,
        )..where((c) => c.ownerId.equals(_account))).get(),
        isEmpty,
        reason: 'no cursor came back',
      );
      expect(await rev(_account), 0, reason: 'no revision came back either');
    },
  );

  test(
    'A → B → A while a pull is in flight: the old session writes nothing',
    () async {
      await remoteWrite([_task('o1', 'old session')]);
      final before = await snapshot();
      held.holdNextPage();
      final run = engine.run(_account);
      await held.atPage;
      await a.signIn(_other);
      await a.signIn(_account);
      expect(await activeOwnerId(a.h.db), _account, reason: 'A is shown again');
      held.release();
      await expectLater(
        run,
        throwsA(
          isA<PullRefusedException>().having(
            (e) => e.reason,
            'reason',
            PullRefusal.ownerChanged,
          ),
        ),
      );
      expect(await snapshot(), before);
      expect(await rows(_account), 0);
      await engine.run(_account);
      expect(
        await rows(_account),
        1,
        reason: 'a pull in the new session works',
      );
    },
  );

  test('removal pending while still shown (defensive; the app signs out '
      'first): refused', () async {
    await remoteWrite([_task('o1', 'pending removal')]);
    final before = await snapshot();
    await a.h.db
        .into(a.h.db.localMeta)
        .insert(
          LocalMetaCompanion.insert(
            key: removalPendingKey(_account),
            value: '1',
          ),
        );
    await expectLater(
      engine.run(_account),
      throwsA(
        isA<PullRefusedException>().having(
          (e) => e.reason,
          'reason',
          PullRefusal.removalPending,
        ),
      ),
    );
    expect(await snapshot(), before);
    expect(await rows(_account), 0);
  });

  test('a row naming another owner refuses the whole page', () async {
    await remoteWrite([_task('o1', 'mine'), _task('o2', 'not mine')]);
    server.table('occurrences')['o2']!['user_id'] = _other;
    final before = await snapshot();
    await expectLater(
      engine.run(_account),
      throwsA(
        isA<PullRefusedException>().having(
          (e) => e.reason,
          'reason',
          PullRefusal.foreignRow,
        ),
      ),
    );
    expect(await snapshot(), before);
    expect(
      await rows(_account),
      0,
      reason: 'not even the own row of that page',
    );
    expect(await rows(_other), 0, reason: 'never attributed to anyone');
  });

  test('a pulled id already held by another owner here: refused, theirs '
      'untouched', () async {
    await DriftOccurrenceRepository(a.h.db).upsertAll([
      occurrenceFixture().copyWith(
        id: 'o1',
        userId: 'device-local',
        title: 'guest',
      ),
    ]);
    await remoteWrite([_task('o1', 'account')]);
    await expectLater(
      engine.run(_account),
      throwsA(
        isA<PullRefusedException>().having(
          (e) => e.reason,
          'reason',
          PullRefusal.foreignRow,
        ),
      ),
    );
    final kept = await DriftOccurrenceRepository(
      a.h.db,
    ).findById('device-local', 'o1');
    expect(kept?.title, 'guest');
    expect(await rows(_account), 0);
  });

  test(
    'a page that fails half way rolls back rows, revision and cursor',
    () async {
      await remoteWrite([_task('o1', 'fine')]);
      final broken = {...server.table('occurrences')['o1']!}
        ..['id'] = 'o9'
        ..['title'] = null
        ..['updated_at'] = '2099-01-01T00:00:00.000Z';
      server.table('occurrences')['o9'] = broken;
      final before = await snapshot();
      await expectLater(engine.run(_account), throwsA(anything));
      expect(await snapshot(), before);
      expect(await rows(_account), 0, reason: 'the good row of that page too');
    },
  );

  test(
    'the background isolate\'s own connection follows the same rules',
    () async {
      final dir = await Directory.systemTemp.createTemp('dottoday-pull-guard');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');
      final app = WriteHarness(_t, db: AppDatabase(NativeDatabase(file)));
      addTearDown(app.dispose);
      final device = SyncDevice.on(app, server);
      await device.start();
      final bgDb = AppDatabase(NativeDatabase(file));
      addTearDown(bgDb.close);
      final bgHeld = _Held(server.forDevice());
      final background = SyncEngine(
        db: bgDb,
        gateway: bgHeld,
        hlc: SharedHlc(bgDb, app.clock),
        clock: app.clock,
        pageSize: 3,
      );
      await background.run(_account);
      await remoteWrite([_task('o1', 'background')]);

      // Committed before the seal: the seal's revision includes it.
      final reviewed = await writeRevision(app.db, _account);
      await background.run(_account);
      final sealed = await sealForDeletion(app.db, _account);
      expect(sealed, greaterThan(reviewed), reason: 'D1 would stop');

      await unsealDeletion(app.db, _account);

      // Its page reached while the app's connection seals: refused.
      await remoteWrite([_task('o2', 'after the seal')]);
      bgHeld.holdNextPage();
      final run = background.run(_account);
      await bgHeld.atPage;
      final atSeal = await sealForDeletion(app.db, _account);
      bgHeld.release();
      await expectLater(run, throwsA(isA<PullRefusedException>()));
      expect(
        await (app.db.select(
          app.db.occurrences,
        )..where((o) => o.id.equals('o2'))).get(),
        isEmpty,
      );
      expect(await writeRevision(app.db, _account), atSeal);
    },
  );
}
