import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/backup/backup_restorability.dart';
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

  /// About 30 MB of JSON: 3,000 tasks with the longest notes allowed.
  Future<void> grow() => DriftOccurrenceRepository(h.db).upsertAll([
    for (var i = 0; i < 3000; i++)
      occurrenceFixture().copyWith(
        id: '01928c3e-0000-7000-9000-${i.toString().padLeft(12, '0')}',
        notes: 'n' * 10000,
      ),
  ]);

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

  group('a safety backup that could not be restored stops the operation', () {
    test('a 30 MB account importing a file', () async {
      await grow();
      final before = await live();
      final kept = await stored();
      expect(
        await service.importJson(userId, smallFile()),
        refusedAs<BackupNotRestorableFailure>(),
      );
      expect(await live(), before, reason: 'no live change');
      expect(await stored(), kept, reason: 'nothing stored or pruned');
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('a 30 MB account restoring an earlier backup', () async {
      final earlier = (await service.create(
        userId,
        BackupReason.daily,
      )).when(ok: (b) => b.id, err: (f) => fail(f.code));
      await grow();
      final before = await live();
      expect(
        await service.restore(userId, earlier),
        refusedAs<BackupNotRestorableFailure>(),
      );
      expect(await live(), before);
      expect(await stored(), [earlier]);
    }, timeout: const Timeout(Duration(minutes: 2)));

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

  test('the last restorable backup survives 8 oversized daily rotations, '
      'then goes once a newer one can be restored', () async {
    final last = (await service.create(
      userId,
      BackupReason.daily,
    )).when(ok: (b) => b.id, err: (f) => fail(f.code));
    await grow();
    for (var day = 0; day < 8; day++) {
      h.clock.advance(_day);
      expect(await service.runDailyIfDue(userId), isA<Ok<bool, AppFailure>>());
    }
    final ids = await stored();
    expect(ids, contains(last), reason: 'the only one a restore can read');
    expect(ids, hasLength(8), reason: '7 daily + the restorable one');
    final kept = await (backups.select(
      backups.backups,
    )..where((b) => b.id.equals(last))).getSingle();
    expect(isRestorableBackup(kept.json, userId), isTrue);

    // Back under the limit: a new restorable daily replaces it.
    await h.db.customStatement(
      "DELETE FROM occurrences WHERE id LIKE '01928c3e-0000-7000-9000-%'",
    );
    h.clock.advance(_day);
    await service.runDailyIfDue(userId);
    expect(await stored(), isNot(contains(last)));
    expect(await stored(), hasLength(7));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
