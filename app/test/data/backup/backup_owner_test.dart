import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// CR-160 I2: backups belong to the owner they were taken for. Owner A is
// the fixture user; owner B is a second profile on the same device.

const _a = userId;
const _b = '01928c3e-0000-7000-8000-0000000000f2';
const _bTask = '01928c3e-0000-7000-8000-0000000000f3';

T _ok<T>(Result<T, AppFailure> r) =>
    r.when(ok: (v) => v, err: (f) => fail('unexpected ${f.code}'));

AppFailure? _err(Result<void, AppFailure> r) =>
    r.when(ok: (_) => null, err: (f) => f);

void main() {
  late WriteHarness h;
  late BackupDatabase backups;
  late DriftBackupService service;
  late DriftOccurrenceRepository occurrences;

  Future<void> show(String owner) => h.db.customStatement(
    'INSERT OR REPLACE INTO local_meta (key, value) VALUES (?, ?)',
    [activeOwnerKey, owner],
  );

  Future<int> stored() async =>
      (await backups.select(backups.backups).get()).length;

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
        userId: _a,
        profile: profileFixture(),
        occurrences: [occurrenceFixture()],
      ),
    );
    await h.writes.apply(
      WriteBatch(
        userId: _b,
        profile: profileFixture().copyWith(id: _b, displayName: 'Bo'),
        occurrences: [
          occurrenceFixture().copyWith(id: _bTask, userId: _b, title: 'Gym'),
        ],
      ),
    );
    await show(_a);
  });
  tearDown(() async {
    await h.dispose();
    await backups.close();
  });

  test("A's backups are invisible while B is shown", () async {
    _ok(await service.create(_a, BackupReason.daily));
    expect(await service.list(), hasLength(1));
    await show(_b);
    expect(await service.list(), isEmpty);
    _ok(await service.create(_b, BackupReason.preImport));
    expect((await service.list()).single.reason, BackupReason.preImport);
  });

  test("restoring A's backup while B is shown is refused", () async {
    final aBackup = _ok(await service.create(_a, BackupReason.daily));
    await show(_b);
    final before = await stored();

    expect(_err(await service.restore(_b, aBackup.id)), isA<StorageFailure>());
    expect(_err(await service.restore(_a, aBackup.id)), isA<StorageFailure>());

    expect(await stored(), before, reason: 'no safety backup taken');
    expect((await occurrences.findById(_b, _bTask))!.title, 'Gym');
    expect(await occurrences.findById(_b, occurrenceFixture().id), isNull);
    expect(
      (await occurrences.findById(_a, occurrenceFixture().id))!.title,
      'Dentist',
    );
  });

  test('a backup whose content is another owner is refused', () async {
    final info = _ok(await service.create(_a, BackupReason.daily));
    // A row mislabelled as B's but holding A's profile: never restored.
    await (backups.update(backups.backups)..where((b) => b.id.equals(info.id)))
        .write(const BackupsCompanion(owner: Value(_b)));
    await show(_b);
    expect(_err(await service.restore(_b, info.id)), isA<StorageFailure>());
    expect(await occurrences.findById(_b, occurrenceFixture().id), isNull);
  });

  test('daily due and retention are counted per owner', () async {
    expect(_ok(await service.runDailyIfDue(_a)), isTrue);
    expect(
      _ok(await service.runDailyIfDue(_b)),
      isTrue,
      reason: "A's daily backup does not count for B",
    );
    expect(await service.nextDailyDueUtc(_b), isNot(h.clock.nowUtc()));
    for (var day = 0; day < 9; day++) {
      h.clock.advance(const Duration(hours: 25));
      _ok(await service.runDailyIfDue(_a));
    }
    final keep = DriftBackupService.retention[BackupReason.daily]!;
    expect(await service.list(), hasLength(keep));
    await show(_b);
    expect(
      await service.list(),
      hasLength(1),
      reason: "A's backups never push out B's",
    );
    expect(await service.nextDailyDueUtc(_b), isNot(h.clock.nowUtc()));
  });

  test('deleteBackupsOf removes only that owner and is repeatable', () async {
    _ok(await service.create(_a, BackupReason.daily));
    _ok(await service.create(_a, BackupReason.preImport));
    _ok(await service.create(_b, BackupReason.daily));

    await backups.deleteBackupsOf(_a);
    await backups.deleteBackupsOf(_a);
    await backups.deleteBackupsOf('nobody');

    expect(await service.list(), isEmpty);
    await show(_b);
    expect(await service.list(), hasLength(1));
    expect(await stored(), 1);
  });

  test('ownerless (legacy) backups are never listed or restored', () async {
    final info = _ok(await service.create(_a, BackupReason.daily));
    await (backups.update(backups.backups)..where((b) => b.id.equals(info.id)))
        .write(const BackupsCompanion(owner: Value(null)));
    expect(await service.list(), isEmpty);
    expect(_err(await service.restore(_a, info.id)), isA<StorageFailure>());
    expect(await stored(), 1);
  });
}
