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

enum NetworkFailureKind { offline, timeout, server }

/// Backend unreachable or erroring. Local data is unaffected (docs/04 §4).
final class NetworkFailure extends AppFailure {
  const NetworkFailure(this.kind);

  final NetworkFailureKind kind;

  @override
  String get code => 'network.${kind.name}';
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
