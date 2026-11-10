import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_privacy.dart';
import 'package:dottoday/data/backup/backup_retention.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/daos/profiles_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/writes/foreign_rows.dart';
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
    IdGenerator ids = const UuidV7Generator(),
    this.afterRead,
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
  }

  /// [body] under [guestBackupFence], after [prepareFencedBackupWork]
  /// (CR-160 guest-backup privacy).
  Future<T> _fenced<T>(Future<T> Function() body) =>
      guestBackupFence.run(() async {
        await prepareFencedBackupWork(_db, _backups, nowUtc: _clock.nowUtc());
        return body();
      });

  /// [verify]: the safety backup before an import or restore (CR-160
  /// backup safety). It is stored only if within the import limit, then
  /// read back and checked the way a restore would read it, complete
  /// against the account it was taken of; otherwise it is removed and
  /// [BackupNotRestorableFailure] stops the operation before any live
  /// change. Pruning runs only after that check passed.
  Future<Result<BackupInfo, AppFailure>> _create(
    String userId,
    BackupReason reason, {
    required bool verify,
  }) async {
    final now = _clock.nowUtc();
    try {
      final bundle = await _db.transaction(
        () => readUserData(_db, userId, now),
      );
      if (bundle == null) return const Err(StorageFailure());
      final json = encodeExportJson(bundle);
      if (verify && exceedsImportLimit(json)) return _notRestorable();
      await afterRead?.call();
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
      if (verify &&
          !await storedBackupRestorable(_backups, id, userId, bundle)) {
        await (_backups.delete(
          _backups.backups,
        )..where((b) => b.id.equals(id))).go();
        return _notRestorable();
      }
      await pruneKeepingRestorable(
        _backups,
        userId,
        reason.name,
        retention[reason]!,
        hidden: (await guestBackupVisibility(_db, userId)).hides,
      );
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

  Result<BackupInfo, AppFailure> _notRestorable() {
    _logger.warn('backup.not_restorable');
    return const Err(BackupNotRestorableFailure());
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
  /// revealed either.
  @override
  Future<Result<void, AppFailure>> restore(String userId, int backupId) =>
      _fenced(() => _restore(userId, backupId));

  Future<Result<void, AppFailure>> _restore(String userId, int backupId) async {
    if (await _shownOwner() != userId) return const Err(StorageFailure());
    if ((await guestBackupVisibility(_db, userId)).hides(backupId)) {
      return const Err(StorageFailure());
    }
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
      _fenced(() => _replaceFrom(userId, json, BackupReason.preImport));

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
    // A row id another account here holds: refused before the safety
    // backup or any change (CR-160 Finding X). The write path checks again
    // inside its transaction.
    final foreign = await foreignRowTable(_db, userId, {
      'series': [for (final s in incoming.series) s.id],
      'occurrences': [for (final o in incoming.occurrences) o.id],
      'subtasks': [for (final s in incoming.subtasks) s.id],
      'routines': [for (final r in incoming.routines) r.id],
    });
    if (foreign != null) {
      _logger.warn('backup.foreign_rows');
      return const Err(ForeignRowsFailure());
    }
    // A safety backup that a restore could actually read, or nothing
    // changes (CR-160 backup safety).
    if (await _create(userId, safety, verify: true) case Err(:final failure)) {
      return Err(failure);
    }
    final now = _clock.nowUtc();
    final current = await readUserData(_db, userId, now);
    if (current == null) return const Err(StorageFailure());
    final applied = await _writes.apply(
      restorePlan(current: current, backup: incoming, userId: userId, now: now),
    );
    if (applied case Err()) return applied;
    // D1's calendar-series settings (CR-160 Stage A): kept pending under
    // this account, attached only when a calendar here provably matches.
    // After the restore, so a refused restore leaves none behind; a failure
    // here is reported, and importing the file again is safe.
    return stashCalendarSeriesTemplates(
      _db,
      userId,
      incoming.calendarSeries,
      _ids,
    );
  }

  /// The profile the app shows, whose backups [list] and [restore] see.
  Future<String?> _shownOwner() async =>
      (await ProfilesDao(_db).findActive())?.id;
}
