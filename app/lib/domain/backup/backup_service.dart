import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';

/// Why a local backup was taken (retention differs per reason).
enum BackupReason {
  /// The rolling daily backup (keep 7, docs/04 §4).
  daily,

  /// Taken before importing a JSON file (R-11).
  preImport,

  /// Taken before restoring another backup, so a restore is undoable.
  preRestore,
}

/// A stored local backup, without its content.
final class BackupInfo {
  const BackupInfo({
    required this.id,
    required this.createdAtUtc,
    required this.reason,
    required this.sizeBytes,
  });

  final int id;
  final DateTime createdAtUtc;
  final BackupReason reason;
  final int sizeBytes;
}

/// Local, encrypted JSON backups of one user's data (docs/09 M2.4, R-08,
/// R-11). Restores and imports go through the write path, so they sync like
/// edits and never hard-delete: rows missing from the backup are moved to
/// Trash.
abstract interface class BackupService {
  /// Takes the daily backup unless one exists from the last 24 h.
  /// Returns whether a backup was taken.
  Future<Result<bool, AppFailure>> runDailyIfDue(String userId);

  /// When [runDailyIfDue] will next take one: 24 h after the last daily
  /// backup, or now when there is none (the open app arms its housekeeping
  /// for that moment, docs/04 §4 "Triggers").
  Future<DateTime> nextDailyDueUtc(String userId);

  /// Takes a backup now and applies retention.
  Future<Result<BackupInfo, AppFailure>> create(
    String userId,
    BackupReason reason,
  );

  /// Stored backups, newest first.
  Future<List<BackupInfo>> list();

  /// Replaces [userId]'s data with backup [backupId], after a
  /// [BackupReason.preRestore] backup of the current state.
  Future<Result<void, AppFailure>> restore(String userId, int backupId);

  /// Replaces [userId]'s data with an export file (JSON v1), after a
  /// [BackupReason.preImport] backup. Invalid files change nothing.
  Future<Result<void, AppFailure>> importJson(String userId, String json);
}
