import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/daos/profiles_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/backup/restore_plan.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:drift/drift.dart';

/// [BackupService] storing JSON v1 bundles in [BackupDatabase].
///
/// Every backup belongs to the owner it was taken for (CR-160 I2): the
/// daily check, retention, listing and restore each see one owner's
/// backups only, so a restore can never bring another owner's tasks into
/// the one shown.
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
                    b.owner.equals(userId) &
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
              ..where(
                _backups.backups.owner.equals(userId) &
                    _backups.backups.reason.equals(BackupReason.daily.name),
              ))
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
              owner: Value(userId),
            ),
          );
      await _prune(userId, reason);
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

  /// The shown owner's backups only; ownerless (legacy) ones never appear.
  @override
  Future<List<BackupInfo>> list() async {
    final owner = await _shownOwner();
    if (owner == null) return const [];
    final rows = await _backups
        .customSelect(
          'SELECT id, created_at, reason, length(json) AS size FROM backups '
          'WHERE owner = ? ORDER BY created_at DESC, id DESC',
          variables: [Variable.withString(owner)],
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

  /// Refuses, changing nothing, unless [userId] is the owner shown and the
  /// backup is [userId]'s. Another owner's backup fails exactly like an
  /// unknown id, so its existence is not revealed either.
  @override
  Future<Result<void, AppFailure>> restore(String userId, int backupId) async {
    if (await _shownOwner() != userId) return const Err(StorageFailure());
    final row =
        await (_backups.select(_backups.backups)
              ..where((b) => b.id.equals(backupId) & b.owner.equals(userId)))
            .getSingleOrNull();
    if (row == null) return const Err(StorageFailure());
    return _replaceFrom(
      userId,
      row.json,
      BackupReason.preRestore,
      requireOwner: true,
    );
  }

  @override
  Future<Result<void, AppFailure>> importJson(String userId, String json) =>
      _replaceFrom(userId, json, BackupReason.preImport);

  /// Decodes [json], backs up the current state, then writes the restore.
  Future<Result<void, AppFailure>> _replaceFrom(
    String userId,
    String json,
    BackupReason safety, {
    bool requireOwner = false,
  }) async {
    final ExportBundle incoming;
    switch (decodeExportJson(json)) {
      case Ok(:final value):
        incoming = value;
      case Err(:final failure):
        return Err(failure);
    }
    // A stored backup's content must be its owner's own profile too (the
    // owner column says so already; this guards a row written wrongly).
    // Imports are exempt: a file is deliberately re-owned to [userId].
    if (requireOwner && incoming.profile.id != userId) {
      return const Err(StorageFailure());
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

  /// The profile the app shows, whose backups [list] and [restore] see.
  Future<String?> _shownOwner() async =>
      (await ProfilesDao(_db).findActive())?.id;

  /// Retention per owner: one owner's backups never push out another's.
  Future<void> _prune(String owner, BackupReason reason) =>
      _backups.customStatement(
        'DELETE FROM backups WHERE owner = ? AND reason = ? AND id NOT IN '
        '(SELECT id FROM backups WHERE owner = ? AND reason = ? '
        'ORDER BY created_at DESC, id DESC LIMIT ?)',
        [owner, reason.name, owner, reason.name, retention[reason]],
      );
}
