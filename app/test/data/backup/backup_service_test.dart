import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

T _ok<T>(Result<T, AppFailure> r) =>
    r.when(ok: (v) => v, err: (f) => fail('unexpected ${f.code}'));

void main() {
  late WriteHarness h;
  late BackupDatabase backups;
  late DriftBackupService service;
  late DriftOccurrenceRepository occurrences;

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    backups = BackupDatabase(NativeDatabase.memory());
    occurrences = DriftOccurrenceRepository(h.db);
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

  Future<String> title(String id) async =>
      (await occurrences.findById(userId, id))!.title;

  test('daily backup at most once per 24 h, keeps the last 7', () async {
    expect(_ok(await service.runDailyIfDue(userId)), isTrue);
    h.clock.advance(const Duration(hours: 23));
    expect(_ok(await service.runDailyIfDue(userId)), isFalse);
    for (var day = 0; day < 9; day++) {
      h.clock.advance(const Duration(hours: 25));
      expect(_ok(await service.runDailyIfDue(userId)), isTrue);
    }
    final list = await service.list();
    expect(list, hasLength(DriftBackupService.retention[BackupReason.daily]));
    expect(list.first.createdAtUtc, h.clock.nowUtc());
    expect(list.every((b) => b.sizeBytes > 0), isTrue);
  });

  test('a backup holds the user data as JSON v1', () async {
    final info = _ok(await service.create(userId, BackupReason.daily));
    final row = await backups.select(backups.backups).getSingle();
    expect(row.id, info.id);
    final bundle = decodeExportJson(
      row.json,
    ).when(ok: (b) => b, err: (f) => fail(f.code));
    expect(bundle.occurrences.single.id, occurrenceFixture().id);
  });

  test('restore brings back the backup and is itself undoable', () async {
    final o = occurrenceFixture();
    final backup = _ok(await service.create(userId, BackupReason.daily));
    h.clock.advance(const Duration(minutes: 5));
    final added = o.copyWith(id: 'added', title: 'New');
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [
          o.copyWith(title: 'Renamed'),
          added,
        ],
      ),
    );

    _ok(await service.restore(userId, backup.id));
    expect(await title(o.id), 'Dentist');
    final trashed = await occurrences.findById(userId, added.id);
    expect(trashed!.deletedAt, isNotNull, reason: 'never hard-deleted');

    // The pre-restore backup undoes the restore.
    final safety = (await service.list()).firstWhere(
      (b) => b.reason == BackupReason.preRestore,
    );
    _ok(await service.restore(userId, safety.id));
    expect(await title(o.id), 'Renamed');
    expect((await occurrences.findById(userId, added.id))!.deletedAt, isNull);
  });

  test('invalid import changes nothing and takes no backup', () async {
    final result = await service.importJson(userId, '{"version": 99}');
    expect(
      result.when(ok: (_) => null, err: (f) => f),
      isA<ValidationFailure>(),
    );
    expect(await service.list(), isEmpty);
    expect(await title(occurrenceFixture().id), 'Dentist');
  });

  test('import re-owns rows and backs up first', () async {
    final other = encodeExportJson(
      (await _exportOf(service, backups)).reownedTo('someone-else'),
    );
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [occurrenceFixture().copyWith(title: 'Changed')],
      ),
    );
    _ok(await service.importJson(userId, other));
    expect(await title(occurrenceFixture().id), 'Dentist');
    expect(
      (await service.list()).map((b) => b.reason),
      contains(BackupReason.preImport),
    );
  });

  test('restoring an unknown id fails', () async {
    expect(
      (await service.restore(userId, 999)).when(ok: (_) => null, err: (f) => f),
      isA<StorageFailure>(),
    );
  });
}

Future<ExportBundle> _exportOf(
  DriftBackupService service,
  BackupDatabase backups,
) async {
  final info = _ok(await service.create(userId, BackupReason.daily));
  final row = await (backups.select(
    backups.backups,
  )..where((b) => b.id.equals(info.id))).getSingle();
  await (backups.delete(
    backups.backups,
  )..where((b) => b.id.equals(info.id))).go();
  return decodeExportJson(
    row.json,
  ).when(ok: (b) => b, err: (f) => fail(f.code));
}
