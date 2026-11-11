import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_audit.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_retention.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/backup/multipart_backup_store.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/backup/backup_recovery.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// CR-160 Stage B4 gate (docs/cr-160-multipart-export.md §8): a backup too
// large for one file is stored as parts, all or nothing; one that doesn't
// read back whole is never kept; retention never loses the last restorable
// copy; today's in-memory restore refuses parts cleanly. Limits shrunk so
// a 500 KB account is "too large".

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
      limits: (singleFile: 200000, part: 64000),
    );
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [occurrenceFixture()],
      ),
    );
    await DriftOccurrenceRepository(h.db).upsertAll([
      for (var i = 0; i < 50; i++)
        occurrenceFixture().copyWith(
          id: '01928c3e-0000-7000-9000-${i.toString().padLeft(12, '0')}',
          notes: 'n' * 10000,
        ),
    ]);
  });
  tearDown(() async {
    await h.dispose();
    await backups.close();
  });

  /// Every task row (as a digest), the outbox and the write revision.
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

  Future<int> count(String table) => backups
      .customSelect('SELECT COUNT(*) AS n FROM $table')
      .getSingle()
      .then((r) => r.read<int>('n'));

  Future<int> create() async => (await service.create(
    userId,
    BackupReason.daily,
  )).when(ok: (b) => b.id, err: (f) => fail(f.code));

  test('a backup over the limit is stored as verified parts, sized by '
      'them', () async {
    final id = await create();
    expect(await count('backup_parts'), greaterThan(1));
    expect(await verifyStoredMultipart(backups, id, userId), isTrue);
    final info = (await service.list()).single;
    final parts = await backups
        .customSelect('SELECT SUM(bytes) AS n FROM backup_parts')
        .getSingle();
    expect(info.sizeBytes, parts.read<int>('n'));
  });

  test('a failure part-way through writing leaves no backup and no '
      'part', () async {
    await backups.customStatement(
      'CREATE TRIGGER fail_part_2 BEFORE INSERT ON backup_parts '
      "WHEN NEW.part_index = 2 BEGIN SELECT RAISE(ABORT, 'disk'); END",
    );
    expect(
      await service.create(userId, BackupReason.daily),
      isA<Err<BackupInfo, AppFailure>>(),
    );
    expect(await count('backups'), 0);
    expect(await count('backup_parts'), 0);
  });

  test('parts that do not read back whole are removed and the backup '
      'refused', () async {
    await backups.customStatement(
      'CREATE TRIGGER damage_part_2 AFTER INSERT ON backup_parts '
      'WHEN NEW.part_index = 2 BEGIN UPDATE backup_parts SET json = '
      """'{"x":1}' WHERE backup_id = NEW.backup_id AND part_index = 2; END""",
    );
    expect(
      await service.create(userId, BackupReason.daily),
      isA<Err<BackupInfo, AppFailure>>().having(
        (e) => e.failure,
        'failure',
        isA<BackupNotRestorableFailure>(),
      ),
    );
    expect(await count('backups'), 0);
    expect(await count('backup_parts'), 0);
  });

  test('retention keeps the last restorable backup when every newer one '
      'has damaged parts', () async {
    final good = await create();
    // Eight newer copies whose part 1 no longer matches its hash: the
    // newest 7 by count, none restorable.
    for (var k = 1; k <= 8; k++) {
      await backups.customStatement(
        'INSERT INTO backups (created_at, reason, app_schema_version, json, '
        'owner) SELECT created_at + $k, reason, app_schema_version, json, '
        'owner FROM backups WHERE id = $good',
      );
      await backups.customStatement(
        'INSERT INTO backup_parts SELECT (SELECT MAX(id) FROM backups), '
        "part_index, sha256, bytes, CASE part_index WHEN 1 THEN '{\"x\":1}' "
        'ELSE json END FROM backup_parts WHERE backup_id = $good',
      );
    }
    await pruneKeepingRestorable(backups, userId, 'daily', 7);
    final ids = [
      for (final b in await backups.select(backups.backups).get()) b.id,
    ];
    expect(ids, contains(good));
    expect(ids, hasLength(8), reason: 'the oldest damaged copy went');
    expect(await verifyStoredMultipart(backups, good, userId), isTrue);
  });

  test("today's in-memory restore refuses a multipart backup and changes "
      'nothing', () async {
    final id = await create();
    h.clock.advance(_day);
    final before = await live();
    expect(await service.restore(userId, id), isA<Err<void, AppFailure>>());
    expect(await live(), before);
    expect(await verifyStoredMultipart(backups, id, userId), isTrue);
  });

  test('the audit counts a multipart backup restorable, sized by its '
      'parts', () async {
    final id = await create();
    final entry = (await auditBackups(
      h.db,
      backups,
    )).singleWhere((e) => e.id == id);
    expect(entry.recovery, BackupRecovery.restorable);
    expect(entry.bytes, greaterThan(200000));
  });

  test('a damaged multipart backup is malformed to the audit', () async {
    final id = await create();
    await backups.customStatement(
      "UPDATE backup_parts SET json = '{\"x\":1}' WHERE part_index = 1",
    );
    final entry = (await auditBackups(
      h.db,
      backups,
    )).singleWhere((e) => e.id == id);
    expect(entry.recovery, BackupRecovery.malformed);
  });
}
