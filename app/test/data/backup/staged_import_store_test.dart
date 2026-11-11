import 'dart:io';

import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';

// CR-160 Stage B2 (docs/cr-160-multipart-export.md §6): the staging area's
// security requirements, one test each. Writes are fenced to the owner
// session the import began in; owners never see each other's staging;
// account removal deletes it; stale imports are cleaned up; growth is
// bounded; a part stages all or nothing; staging never reaches the outbox.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';
const _i1 = '01928c3e-0000-7000-8000-000000000ca1';
const _i2 = '01928c3e-0000-7000-8000-000000000ca2';
const _run = 'run-1';

Map<String, Object?> _row(String id, {String title = 'x'}) => {
  'id': id,
  'title': title,
};

Map<String, List<Map<String, Object?>>> _rows(List<String> ids) => {
  'occurrences': [for (final id in ids) _row(id)],
};

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  setUp(() async {
    w = GuestBackupWorld();
    await w.app.shown();
    await w.app.signIn(_a);
  });
  tearDown(() => w.dispose());

  AppDatabase db() => w.db;

  Future<StagedImport> begin(
    String owner, {
    String id = _i1,
    int bytes = 1 << 20,
    String run = _run,
    DateTime? at,
  }) => beginStagedImport(
    db(),
    owner,
    importId: id,
    declaredBytes: bytes,
    runId: run,
    nowUtc: at ?? ownerAppNow,
  );

  Matcher refused(StagingRefusal r) => throwsA(
    isA<StagingRefusedException>().having((e) => e.reason, 'reason', r),
  );

  Future<int> stagedCount() async =>
      (await db().select(db().importStaging).get()).length;

  test(
    'staged rows read back in keyset pages; discard removes them all',
    () async {
      final s = await begin(_a);
      await stagePart(
        db(),
        s,
        partIndex: 1,
        profile: {'id': _a},
        rows: _rows(['o3', 'o1', 'o2']),
      );
      final first = await stagedRows(db(), s, 'occurrences', limit: 2);
      expect([for (final r in first) r['id']], ['o1', 'o2']);
      final rest = await stagedRows(db(), s, 'occurrences', afterRowId: 'o2');
      expect([for (final r in rest) r['id']], ['o3']);
      expect((await stagedRows(db(), s, 'profile')).single['id'], _a);
      await discardStagedImport(db(), s);
      expect(await stagedCount(), 0);
      expect(await db().select(db().importSessions).get(), isEmpty);
    },
  );

  group('fencing (owner and generation)', () {
    test('another owner shown: refused to begin, and to stage', () async {
      await expectLater(begin(_b), refused(StagingRefusal.ownerChanged));
      final s = await begin(_a);
      await w.app.signIn(_b);
      await expectLater(
        stagePart(db(), s, partIndex: 1, rows: _rows(['o1'])),
        refused(StagingRefusal.ownerChanged),
      );
      expect(await stagedCount(), 0);
    });

    test('A → B → A: a new session, the old import refused', () async {
      final s = await begin(_a);
      await w.app.signIn(_b);
      await w.app.signIn(_a);
      await expectLater(
        stagePart(db(), s, partIndex: 1, rows: _rows(['o1'])),
        refused(StagingRefusal.ownerChanged),
      );
    });

    test('sealed for deletion, or being removed: refused', () async {
      final s = await begin(_a);
      await sealForDeletion(db(), _a);
      await expectLater(
        stagePart(db(), s, partIndex: 1, rows: _rows(['o1'])),
        refused(StagingRefusal.ownerChanged),
      );
      await expectLater(
        begin(_a, id: _i2),
        refused(StagingRefusal.ownerChanged),
      );
    });

    test('a removal begun: refused', () async {
      final s = await begin(_a);
      await beginAccountRemoval(db(), _a);
      await expectLater(
        stagePart(db(), s, partIndex: 1, rows: _rows(['o1'])),
        refused(StagingRefusal.ownerChanged),
      );
    });
  });

  test(
    'isolation: two owners\' imports at once, each sees only its own',
    () async {
      final a = await begin(_a);
      await stagePart(db(), a, partIndex: 1, rows: _rows(['a1']));
      await w.app.signIn(_b);
      final b = await begin(_b, id: _i2);
      await stagePart(db(), b, partIndex: 1, rows: _rows(['b1']));
      expect(
        [for (final r in await stagedRows(db(), b, 'occurrences')) r['id']],
        ['b1'],
      );
      expect(
        [for (final r in await stagedRows(db(), a, 'occurrences')) r['id']],
        ['a1'],
      );
      // A's import id with B as the owner reads nothing.
      final forged = (importId: _i1, owner: b.owner);
      expect(await stagedRows(db(), forged, 'occurrences'), isEmpty);
      await expectLater(
        stagePart(db(), forged, partIndex: 2, rows: _rows(['b2'])),
        refused(StagingRefusal.unknownImport),
      );
    },
  );

  test('account removal deletes that owner\'s staging only', () async {
    final a = await begin(_a);
    await stagePart(db(), a, partIndex: 1, rows: _rows(['a1']));
    await w.app.signIn(_b);
    final b = await begin(_b, id: _i2);
    await stagePart(db(), b, partIndex: 1, rows: _rows(['b1']));
    await w.app.owners.signOut();
    await w.app.owners.accountDeleted(_a);
    final owners = {
      for (final r in await db().select(db().importStaging).get()) r.owner,
    };
    expect(owners, {_b});
    expect(
      [for (final s in await db().select(db().importSessions).get()) s.owner],
      [_b],
    );
  });

  group('cleanup', () {
    test('another run\'s import, or one older than 24 h, is cleaned up; the '
        'current one is kept', () async {
      final s = await begin(_a);
      await stagePart(db(), s, partIndex: 1, rows: _rows(['o1']));
      expect(
        await cleanUpStaleImports(db(), runId: _run, nowUtc: ownerAppNow),
        0,
      );
      expect(
        await cleanUpStaleImports(
          db(),
          runId: _run,
          nowUtc: ownerAppNow.add(const Duration(hours: 24)),
        ),
        1,
      );
      expect(await stagedCount(), 0);
      await begin(_a, id: _i2);
      expect(
        await cleanUpStaleImports(db(), runId: 'run-2', nowUtc: ownerAppNow),
        1,
      );
    });

    test('a clock set back counts as stale', () async {
      await begin(_a);
      expect(
        await cleanUpStaleImports(
          db(),
          runId: _run,
          nowUtc: ownerAppNow.subtract(const Duration(minutes: 1)),
        ),
        1,
      );
    });

    test('one import per owner; a stale one makes way', () async {
      await begin(_a);
      await expectLater(begin(_a, id: _i2), refused(StagingRefusal.busy));
      await begin(_a, id: _i2, run: 'run-2');
      expect(
        [
          for (final s in await db().select(db().importSessions).get())
            s.importId,
        ],
        [_i2],
      );
    });

    test(
      'killed and reopened: the next run cleans up what was staged',
      () async {
        final dir = await Directory.systemTemp.createTemp('dottoday-b2');
        addTearDown(() => dir.delete(recursive: true));
        final file = File('${dir.path}/db.sqlite');
        final first = AppDatabase(NativeDatabase(file));
        await first.customStatement(
          'INSERT INTO import_sessions (import_id, owner, owner_generation, '
          "run_id, started_at, declared_bytes) VALUES ('$_i1', '$_a', 0, "
          "'$_run', ${ownerAppNow.millisecondsSinceEpoch}, 100)",
        );
        await first.customStatement(
          'INSERT INTO import_staging (import_id, owner, entity, row_id, '
          "part_index, json) VALUES ('$_i1', '$_a', 'occurrences', 'o1', 1, "
          "'{}')",
        );
        await first.close();
        final next = AppDatabase(NativeDatabase(file));
        addTearDown(next.close);
        expect(
          await cleanUpStaleImports(next, runId: 'run-2', nowUtc: ownerAppNow),
          1,
        );
        expect(await next.select(next.importStaging).get(), isEmpty);
      },
    );
  });

  group('bounded and all or nothing', () {
    test('over the accepted total: refused to begin', () async {
      await expectLater(
        begin(_a, bytes: maxStagedImportBytes + 1),
        refused(StagingRefusal.tooLarge),
      );
    });

    test(
      'more than declared: the part is refused, nothing of it staged',
      () async {
        final s = await begin(_a, bytes: 60); // one ~24-byte row fits
        await stagePart(db(), s, partIndex: 1, rows: _rows(['o1']));
        await expectLater(
          stagePart(
            db(),
            s,
            partIndex: 2,
            rows: _rows(['o2', 'o3', 'o4', 'o5']),
          ),
          refused(StagingRefusal.tooLarge),
        );
        expect(
          [for (final r in await stagedRows(db(), s, 'occurrences')) r['id']],
          ['o1'],
        );
      },
    );

    test('an id staged twice, or a row without an id: the part is refused '
        'whole', () async {
      final s = await begin(_a);
      await stagePart(db(), s, partIndex: 1, rows: _rows(['o1']));
      await expectLater(
        stagePart(db(), s, partIndex: 2, rows: _rows(['o2', 'o1'])),
        refused(StagingRefusal.badRow),
      );
      await expectLater(
        stagePart(
          db(),
          s,
          partIndex: 2,
          rows: {
            'occurrences': [
              _row('o3'),
              {'title': 'no id'},
            ],
          },
        ),
        refused(StagingRefusal.badRow),
      );
      expect(
        [for (final r in await stagedRows(db(), s, 'occurrences')) r['id']],
        ['o1'],
      );
      final session = await db().select(db().importSessions).getSingle();
      expect(session.stagedBytes, lessThan(40), reason: 'only o1 counted');
    });
  });

  test('staging never reaches the outbox or the write revision', () async {
    final before = (
      (await db().select(db().changeLog).get()).length,
      await writeRevision(db(), _a),
    );
    final s = await begin(_a);
    await stagePart(
      db(),
      s,
      partIndex: 1,
      profile: {'id': _a},
      rows: _rows(['o1', 'o2']),
    );
    await discardStagedImport(db(), s);
    expect((
      (await db().select(db().changeLog).get()).length,
      await writeRevision(db(), _a),
    ), before);
  });
}
