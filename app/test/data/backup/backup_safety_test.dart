import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// CR-160 backup safety: an import or restore goes ahead only after its
// safety backup has been read back as a complete, restorable copy; and
// retention never deletes an owner's last restorable backup because newer
// ones can't be restored.

const _day = Duration(hours: 25);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late WriteHarness h;
  late BackupDatabase backups;
  late DriftBackupService service;
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 11, 10, 6));
    backups = BackupDatabase(NativeDatabase.memory());
    service = DriftBackupService(
      db: h.db,
      backups: backups,
      writes: h.writes,
      clock: h.clock,
      logger: h.logger,
    );
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [occurrenceFixture()],
      ),
    );
  });
  tearDown(() async {
    await h.dispose();
    await backups.close();
  });

  /// Everything a refused operation must leave alone: every task row (as
  /// a digest, so a failure doesn't print 30 MB), the outbox and the write
  /// revision.
  Future<String> live() async {
    final rows = await (h.db.select(
      h.db.occurrences,
    )..orderBy([(o) => OrderingTerm(expression: o.id)])).get();
    final digest = sha256.convert(
      utf8.encode(jsonEncode([for (final r in rows) r.toJson()])),
    );
    return '$digest|${(await h.changeLog()).length}|'
        '${await writeRevision(h.db, userId)}';
  }

  Future<List<int>> stored() async => [
    for (final b in await backups.select(backups.backups).get()) b.id,
  ];

  String smallFile() => encodeExportJson(
    ExportBundle(
      exportedAt: h.clock.nowUtc(),
      profile: profileFixture(),
      occurrences: [occurrenceFixture().copyWith(title: 'From the file')],
    ),
  );

  Matcher refusedAs<F>() => isA<Err<void, AppFailure>>().having(
    (e) => e.failure,
    'failure',
    isA<F>(),
  );

  // CR-160 B4/B5: an account too large for one backup file gets its safety
  // backup as verified parts, and the import or restore goes ahead (B4
  // refused both until B5 made the restore, and so Undo, read parts).
  // Limits shrunk so the account is small.
  group('an account over the single-file limit', () {
    late DriftBackupService small;
    setUp(() {
      small = DriftBackupService(
        db: h.db,
        backups: backups,
        writes: h.writes,
        clock: h.clock,
        logger: h.logger,
        limits: (singleFile: 200000, part: 64000),
      );
    });
    Future<void> grow() => DriftOccurrenceRepository(h.db).upsertAll([
      for (var i = 0; i < 50; i++)
        occurrenceFixture().copyWith(
          id: '01928c3e-0000-7000-9000-${i.toString().padLeft(12, '0')}',
          notes: 'n' * 10000,
        ),
    ]);
    Future<int> safety(BackupReason reason) async {
      final row = await (backups.select(
        backups.backups,
      )..where((b) => b.reason.equals(reason.name))).getSingle();
      expect(await verifyStoredMultipart(backups, row.id, userId), isTrue);
      expect(
        (await (backups.select(
          backups.backupParts,
        )..where((p) => p.backupId.equals(row.id))).get()).length,
        greaterThan(1),
      );
      return row.id;
    }

    Set<String> live(List<OccurrenceRow> rows) => {
      for (final o in rows)
        if (o.deletedAt == null) o.title,
    };

    test('importing a file, then Undo from its parts', () async {
      await grow();
      final before = live(await h.db.select(h.db.occurrences).get());
      expect(
        await small.importJson(userId, smallFile()),
        isA<Ok<void, AppFailure>>(),
      );
      expect(live(await h.db.select(h.db.occurrences).get()), {
        'From the file',
      });
      final id = await safety(BackupReason.preImport);
      expect(await small.restore(userId, id), isA<Ok<void, AppFailure>>());
      expect(live(await h.db.select(h.db.occurrences).get()), before);
    });

    test('restoring an earlier backup: verified parts first, then the '
        'restore', () async {
      final earlier = (await small.create(
        userId,
        BackupReason.daily,
      )).when(ok: (b) => b.id, err: (f) => fail(f.code));
      await grow();
      expect(await small.restore(userId, earlier), isA<Ok<void, AppFailure>>());
      await safety(BackupReason.preRestore);
    });
  });

  group('a safety backup that could not be restored stops the operation', () {
    test('a backup that stores but fails restore validation', () async {
      // Within the database's rules, not the app's: the backup of it would
      // be refused by every restore.
      await h.db.customStatement(
        "UPDATE occurrences SET color_key = 'not-a-key'",
      );
      final before = await live();
      expect(
        await service.importJson(userId, smallFile()),
        refusedAs<BackupNotRestorableFailure>(),
      );
      expect(await live(), before);
      expect(await stored(), isEmpty, reason: 'the bad copy is not kept');
    });

    test('the disk is full: no backup, no change', () async {
      // About 500 KB to back up: it needs pages the cap below refuses.
      await DriftOccurrenceRepository(h.db).upsertAll([
        for (var i = 0; i < 50; i++)
          occurrenceFixture().copyWith(
            id: '01928c3e-0000-7000-9000-${i.toString().padLeft(12, '0')}',
            notes: 'n' * 10000,
          ),
      ]);
      final pages = await backups
          .customSelect('PRAGMA page_count')
          .getSingle()
          .then((r) => r.data.values.first! as int);
      await backups.customStatement('PRAGMA max_page_count = $pages');
      final before = await live();
      expect(
        await service.importJson(userId, smallFile()),
        refusedAs<StorageFailure>(),
      );
      expect(await live(), before);
    });

    test('pruning fails after a good backup: still refused, the backup '
        'kept', () async {
      for (var i = 0; i < 5; i++) {
        await service.create(userId, BackupReason.preImport);
      }
      await backups.customStatement(
        'CREATE TRIGGER no_delete BEFORE DELETE ON backups '
        "BEGIN SELECT RAISE(ABORT, 'no'); END",
      );
      final before = await live();
      expect(
        await service.importJson(userId, smallFile()),
        refusedAs<StorageFailure>(),
      );
      expect(await live(), before);
      expect(await stored(), hasLength(6));
    });
  });

  test('ordinary import, then Undo by restoring its safety backup', () async {
    expect(
      await service.importJson(userId, smallFile()),
      isA<Ok<void, AppFailure>>(),
    );
    final safety = (await service.list()).single;
    expect(safety.reason, BackupReason.preImport);
    expect(
      await service.restore(userId, safety.id),
      isA<Ok<void, AppFailure>>(),
    );
    final titles = {
      for (final r in await h.db.select(h.db.occurrences).get())
        if (r.deletedAt == null) r.title,
    };
    expect(titles, {occurrenceFixture().title});
  });

  test('daily backups too large for one file are verified parts and count '
      'as restorable: retention keeps 7, the older single file goes '
      '(CR-160 Stage B4)', () async {
    final small = DriftBackupService(
      db: h.db,
      backups: backups,
      writes: h.writes,
      clock: h.clock,
      logger: h.logger,
      limits: (singleFile: 200000, part: 64000),
    );
    final last = (await small.create(
      userId,
      BackupReason.daily,
    )).when(ok: (b) => b.id, err: (f) => fail(f.code));
    await DriftOccurrenceRepository(h.db).upsertAll([
      for (var i = 0; i < 50; i++)
        occurrenceFixture().copyWith(
          id: '01928c3e-0000-7000-9000-${i.toString().padLeft(12, '0')}',
          notes: 'n' * 10000,
        ),
    ]);
    for (var day = 0; day < 8; day++) {
      h.clock.advance(_day);
      expect(await small.runDailyIfDue(userId), isA<Ok<bool, AppFailure>>());
    }
    final ids = await stored();
    expect(ids, hasLength(7));
    expect(ids, isNot(contains(last)));
    for (final id in ids) {
      expect(await verifyStoredMultipart(backups, id, userId), isTrue);
    }
  });
}
