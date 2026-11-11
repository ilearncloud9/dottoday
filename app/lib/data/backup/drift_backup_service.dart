import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/backup_creation.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_privacy.dart';
import 'package:dottoday/data/backup/backup_retention.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/staged_import.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/daos/profiles_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/writes/drift_write_use_case.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// [BackupService] storing backups in [BackupDatabase] (JSON v1, or parts
/// above the import limit) and importing or restoring through the staged
/// pipeline (CR-160 Stage B5).
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
    IdGenerator ids = const UuidV7Generator(),
    this.afterRead,
    @visibleForTesting this.limits = defaultBackupLimits,
  }) : _db = db,
       _backups = backups,
       _writes = writes,
       _clock = clock,
       _logger = logger,
       _ids = ids;

  /// Backups kept per reason; the oldest beyond this are deleted, except
  /// the owner's last restorable one ([pruneKeepingRestorable]).
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
  final IdGenerator _ids;

  /// Tests only: runs between reading the account and storing its backup,
  /// to race a guest-work move against it (guest_backup_cutoff.dart).
  final Future<void> Function()? afterRead;

  /// The single-file limit and the part target (tests shrink them).
  final BackupLimits limits;

  @override
  Future<Result<bool, AppFailure>> runDailyIfDue(String userId) async {
    await _maintain();
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
  ) => _fenced(() => _create(userId, reason, verify: false));

  /// Maintenance on start and resume ([runBackupMaintenance], CR-160 I1):
  /// a failure never stops the daily backup and is retried next run.
  Future<void> _maintain() async {
    try {
      await _fenced(
        () => runBackupMaintenance(
          _db,
          _backups,
          nowUtc: _clock.nowUtc(),
          logger: _logger,
        ),
      );
    } on Exception catch (e, st) {
      _logger.error('backup.guest_scrub_failed', error: e, stackTrace: st);
    }
    // Staging left by an earlier run (a crash, a kill) or begun too long
    // ago: removed here, on the main isolate, never an import of this run
    // (CR-160 B5, decision 1). A failure is retried next run.
    try {
      final gone = await _fenced(
        () => cleanUpStaleImports(
          _db,
          runId: importRunId,
          nowUtc: _clock.nowUtc(),
        ),
      );
      if (gone > 0) _logger.info('import.stale_removed', fields: {'n': gone});
    } on Exception catch (e, st) {
      _logger.error('import.stale_cleanup_failed', error: e, stackTrace: st);
    }
  }

  /// [body] under [guestBackupFence], after [prepareFencedBackupWork]
  /// (CR-160 guest-backup privacy).
  Future<T> _fenced<T>(Future<T> Function() body) =>
      guestBackupFence.run(() async {
        await prepareFencedBackupWork(_db, _backups, nowUtc: _clock.nowUtc());
        return body();
      });

  /// One backup, single file or parts, verified when [verify] (the safety
  /// backup before an import or restore): backup_creation.dart.
  Future<Result<BackupInfo, AppFailure>> _create(
    String userId,
    BackupReason reason, {
    required bool verify,
  }) async {
    try {
      return await createBackup(
        _db,
        _backups,
        userId,
        reason,
        now: _clock.nowUtc(),
        keep: retention[reason]!,
        verify: verify,
        ids: _ids,
        logger: _logger,
        limits: limits,
        afterRead: afterRead,
      );
    } on Exception catch (e, st) {
      _logger.error('backup.create_failed', error: e, stackTrace: st);
      return const Err(StorageFailure());
    }
  }

  /// The shown owner's backups only; ownerless (legacy) ones never appear,
  /// nor a guest's taken before its work moved into an account.
  @override
  Future<List<BackupInfo>> list() => _fenced(() async {
    final owner = await _shownOwner();
    if (owner == null) return const <BackupInfo>[];
    final hidden = await guestBackupVisibility(_db, owner);
    return [
      for (final b in await backupInfosOf(_backups, owner))
        if (!hidden.hides(b.id)) b,
    ];
  });

  /// Refuses, changing nothing, unless [userId] is the owner shown and the
  /// backup is [userId]'s and not hidden. Another owner's backup, or a
  /// hidden one, fails exactly like an unknown id, so its existence is not
  /// revealed either. Through the staged pipeline (CR-160 B5), which takes
  /// [guestBackupFence] itself: a backup of any size or form restores.
  @override
  Future<Result<void, AppFailure>> restore(String userId, int backupId) async {
    final importer = _importer();
    if (importer == null) return const Err(StorageFailure());
    return importer.restoreBackup(
      userId,
      _backups,
      backupId,
      safety: () => _safety(userId, BackupReason.preRestore),
    );
  }

  /// A JSON v1 file, through the staged pipeline (CR-160 B5) under
  /// [guestBackupFence]: staged and checked whole, then the verified
  /// pre-import backup, then one commit.
  @override
  Future<Result<void, AppFailure>> importJson(String userId, String json) =>
      _fenced(() async {
        final importer = _importer();
        if (importer == null) return const Err(StorageFailure());
        return importer.importText(
          userId,
          json,
          safety: () => _safety(userId, BackupReason.preImport),
        );
      });

  /// The verified safety backup an import or restore needs, inside the
  /// fence (the pipeline's safety step).
  Future<Result<void, AppFailure>> _safety(
    String userId,
    BackupReason reason,
  ) async => (await _create(userId, reason, verify: true)).map((_) {});

  /// The staged importer over this service's database; null (logged) when
  /// the write path isn't the database's own, which alone can commit an
  /// import (fakes in UI tests never import).
  StagedImporter? _importer() {
    final writes = _writes;
    if (writes is! DriftWriteUseCase) {
      _logger.error('import.no_write_path');
      return null;
    }
    return StagedImporter(
      db: _db,
      writes: writes,
      effects: writes.effects,
      clock: _clock,
      ids: _ids,
      logger: _logger,
      runId: importRunId,
    );
  }

  /// The profile the app shows, whose backups [list] and [restore] see.
  Future<String?> _shownOwner() async =>
      (await ProfilesDao(_db).findActive())?.id;
}
