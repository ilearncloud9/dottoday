import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/backup/restore_plan.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:drift/drift.dart';

/// [BackupService] storing JSON v1 bundles in [BackupDatabase].
final class DriftBackupService implements BackupService {
  DriftBackupService({
    required AppDatabase db,
    required BackupDatabase backups,
    required WriteUseCase writes,
    required Clock clock,
    required Logger logger,
  }) : _db = db,
       _backups = backups,
       _writes = writes,
       _clock = clock,
       _logger = logger;

  /// Backups kept per reason; the oldest beyond this are deleted.
  static const retention = {
    BackupReason.daily: 7,
    BackupReason.preImport: 5,
    BackupReason.preRestore: 5,
  };

  static const dailyInterval = Duration(hours: 24);

  final AppDatabase _db;
  final BackupDatabase _backups;
  final WriteUseCase _writes;
  final Clock _clock;
  final Logger _logger;

  @override
  Future<Result<bool, AppFailure>> runDailyIfDue(String userId) async {
    final since = _clock.nowUtc().subtract(dailyInterval);
    final recent =
        await (_backups.select(_backups.backups)
              ..where(
                (b) =>
                    b.reason.equals(BackupReason.daily.name) &
                    b.createdAt.isBiggerThanValue(since.millisecondsSinceEpoch),
              )
              ..limit(1))
            .getSingleOrNull();
    if (recent != null) return const Ok(false);
    return (await create(userId, BackupReason.daily)).map((_) => true);
  }

  @override
  Future<DateTime> nextDailyDueUtc(String userId) async {
    final last = _backups.backups.createdAt.max();
    final row =
        await (_backups.selectOnly(_backups.backups)
              ..addColumns([last])
              ..where(_backups.backups.reason.equals(BackupReason.daily.name)))
            .getSingle();
    final ms = row.read(last);
    if (ms == null) return _clock.nowUtc();
    return DateTime.fromMillisecondsSinceEpoch(
      ms,
      isUtc: true,
    ).add(dailyInterval);
  }

  @override
  Future<Result<BackupInfo, AppFailure>> create(
    String userId,
    BackupReason reason,
  ) async {
    final now = _clock.nowUtc();
    try {
      final bundle = await _db.transaction(
        () => readUserData(_db, userId, now),
      );
      if (bundle == null) return const Err(StorageFailure());
      final json = encodeExportJson(bundle);
      final id = await _backups
          .into(_backups.backups)
          .insert(
            BackupsCompanion.insert(
              createdAt: now.millisecondsSinceEpoch,
              reason: reason.name,
              appSchemaVersion: AppDatabase.latestSchemaVersion,
              json: json,
            ),
          );
      await _prune(reason);
      return Ok(
        BackupInfo(
          id: id,
          createdAtUtc: now,
          reason: reason,
          sizeBytes: json.length,
        ),
      );
    } on Exception catch (e, st) {
      _logger.error('backup.create_failed', error: e, stackTrace: st);
      return const Err(StorageFailure());
    }
  }

  @override
  Future<List<BackupInfo>> list() async {
    final rows = await _backups
        .customSelect(
          'SELECT id, created_at, reason, length(json) AS size FROM backups '
          'ORDER BY created_at DESC, id DESC',
          readsFrom: {_backups.backups},
        )
        .get();
    return [
      for (final r in rows)
        BackupInfo(
          id: r.read<int>('id'),
          createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('created_at'),
            isUtc: true,
          ),
          reason: BackupReason.values.byName(r.read<String>('reason')),
          sizeBytes: r.read<int>('size'),
        ),
    ];
  }

  @override
  Future<Result<void, AppFailure>> restore(String userId, int backupId) async {
    final row = await (_backups.select(
      _backups.backups,
    )..where((b) => b.id.equals(backupId))).getSingleOrNull();
    if (row == null) return const Err(StorageFailure());
    return _replaceFrom(userId, row.json, BackupReason.preRestore);
  }

  @override
  Future<Result<void, AppFailure>> importJson(String userId, String json) =>
      _replaceFrom(userId, json, BackupReason.preImport);

  /// Decodes [json], backs up the current state, then writes the restore.
  Future<Result<void, AppFailure>> _replaceFrom(
    String userId,
    String json,
    BackupReason safety,
  ) async {
    final ExportBundle incoming;
    switch (decodeExportJson(json)) {
      case Ok(:final value):
        incoming = value;
      case Err(:final failure):
        return Err(failure);
    }
    if (await create(userId, safety) case Err(:final failure)) {
      return Err(failure);
    }
    final now = _clock.nowUtc();
    final current = await readUserData(_db, userId, now);
    if (current == null) return const Err(StorageFailure());
    return _writes.apply(
      restorePlan(current: current, backup: incoming, userId: userId, now: now),
    );
  }

  Future<void> _prune(BackupReason reason) => _backups.customStatement(
    'DELETE FROM backups WHERE reason = ? AND id NOT IN '
    '(SELECT id FROM backups WHERE reason = ? '
    'ORDER BY created_at DESC, id DESC LIMIT ?)',
    [reason.name, reason.name, retention[reason]],
  );
}
