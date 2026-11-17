/// Recoverable, user-explainable failures (CLAUDE.md §4).
///
/// Every field is an enum or other non-string type so task content can never
/// leak through a failure into logs or crash reports. User-facing text comes
/// from `failureMessage` via l10n; [code] is the stable, loggable identifier.
sealed class AppFailure {
  const AppFailure();

  /// Stable dotted identifier, safe to log (e.g. `network.offline`).
  String get code;
}

/// Local database read/write failed.
final class StorageFailure extends AppFailure {
  const StorageFailure();

  @override
  String get code => 'storage';
}

/// The device ran out of storage while writing: everything the write
/// touched was rolled back. Shown as [StorageFailure] is (CR-160 B8).
final class StorageFullFailure extends AppFailure {
  const StorageFullFailure();

  @override
  String get code => 'storage.full';
}

/// An import or backup restore ran out of storage: it rolled back whole,
/// nothing changed (CR-160 B8: imports fill a disk long before memory runs
/// short), said as such.
final class ImportStorageFullFailure extends AppFailure {
  const ImportStorageFullFailure();

  @override
  String get code => 'import.storage_full';
}

enum NetworkFailureKind { offline, timeout, server }

/// Backend unreachable or erroring. Local data is unaffected (docs/04 §4).
final class NetworkFailure extends AppFailure {
  const NetworkFailure(this.kind);

  final NetworkFailureKind kind;

  @override
  String get code => 'network.${kind.name}';
}

/// "Sign out everywhere" while offline: this device is signed out, the
/// other devices are not (CR-160 blocker 4).
final class SignedOutHereOnlyFailure extends AppFailure {
  const SignedOutHereOnlyFailure();

  @override
  String get code => 'auth.signed_out_here_only';
}

/// Session missing, expired or revoked.
final class AuthFailure extends AppFailure {
  const AuthFailure();

  @override
  String get code => 'auth';
}

/// Input fields that can fail validation (docs/05 "Validation", 06 §7).
enum ValidationField {
  title,
  notes,
  startTime,
  duration,
  recurrence,
  alertOffset,
  color,
  icon,
  sound,
  timeZone,
  alerts,
  subtasks,
  travelBuffer,
  settings,
  label,
  displayName,
  locale,
  quickAddText,
  importFile,
  email,
}

enum ValidationRule { required, tooLong, outOfRange, invalidFormat, tooLarge }

/// Input rejected at a boundary. Carries *which* field and rule, never the
/// offending value.
final class ValidationFailure extends AppFailure {
  const ValidationFailure(this.field, this.rule);

  final ValidationField field;
  final ValidationRule rule;

  @override
  String get code => 'validation.${field.name}.${rule.name}';
}

/// Persisted entity kinds (docs/05).
enum EntityKind {
  series,
  occurrence,
  subtask,
  alert,
  calendarAccount,
  calendarLink,
  profile,
  routine,
  revealHint,
}

/// Entity does not exist or is not visible to the current user.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(this.entity);

  final EntityKind entity;

  @override
  String get code => 'not_found.${entity.name}';
}

/// Same-field edit conflict needing the user's choice (ADR-0002, R-08).
final class ConflictFailure extends AppFailure {
  const ConflictFailure(this.entity);

  final EntityKind entity;

  @override
  String get code => 'conflict.${entity.name}';
}

enum AppPermission { notifications, calendar, microphone }

/// An OS permission the feature needs was denied.
final class PermissionFailure extends AppFailure {
  const PermissionFailure(this.permission);

  final AppPermission permission;

  @override
  String get code => 'permission.${permission.name}';
}

/// Why dictation ended early (ADR-0014). The recognizer's own message is
/// never kept: it can quote what was said.
enum SpeechFailureKind {
  /// No on-device recognizer for the language after all.
  unavailable,

  /// Another app or the OS took the microphone (a call, an alarm).
  interrupted,

  /// The recognizer failed on its own.
  recognizer,
}

/// Dictation stopped for a reason other than the user (docs/09 M14.4).
final class SpeechFailure extends AppFailure {
  const SpeechFailure(this.kind);

  final SpeechFailureKind kind;

  @override
  String get code => 'speech.${kind.name}';
}

/// The 30-second undo window passed (or the app restarted); the change
/// stays, and deleted items can still be restored from Trash (M2.5).
final class UndoExpiredFailure extends AppFailure {
  const UndoExpiredFailure();

  @override
  String get code => 'undo.expired';
}

/// Anything not covered above. Log the cause by type before returning this.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure();

  @override
  String get code => 'unexpected';
}

/// Account deletion stopped (CR-160 policy §4, I7): something was queued
/// for the account (a share, a widget or notification action) after the
/// person reviewed or exported what deleting removes. Nothing was deleted;
/// they export again or confirm again.
final class ReviewChangedFailure extends AppFailure {
  const ReviewChangedFailure();

  @override
  String get code => 'account.review_changed';
}

/// A write, import or restore named a row id another account on this
/// device holds (CR-160 Finding X): refused whole, nothing changed for
/// anyone.
final class ForeignRowsFailure extends AppFailure {
  const ForeignRowsFailure();

  @override
  String get code => 'write.foreign_rows';
}

/// The safety backup an import or restore takes first could not be read
/// back as a restorable copy (over the import limit, invalid, incomplete or
/// not the owner's): the operation stopped before any change (CR-160
/// backup safety).
final class BackupNotRestorableFailure extends AppFailure {
  const BackupNotRestorableFailure();

  @override
  String get code => 'backup.not_restorable';
}

/// A JSON export over the 25 MB import limit: the app couldn't
/// restore it, so no file was made or handed over (CR-160 Stage B0).
final class ExportTooLargeFailure extends AppFailure {
  const ExportTooLargeFailure();

  @override
  String get code => 'export.too_large';
}

/// D1 (CR-160): the person asked for an export that didn't produce a
/// restorable copy (it failed, was too large, was cancelled or is still
/// running), and hasn't chosen to delete without one. Nothing was deleted.
/// [retryable]: exporting again could work (not for a too-large export).
final class ExportNotSavedFailure extends AppFailure {
  const ExportNotSavedFailure({required this.retryable});

  final bool retryable;

  @override
  String get code => 'account.export_not_saved';
}
