import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';

/// User-facing, localised text for [failure] (docs/03 §5: plain, never
/// shaming, no exclamation marks).
String failureMessage(AppLocalizations l10n, AppFailure failure) {
  return switch (failure) {
    StorageFailure() => l10n.failureStorage,
    NetworkFailure(kind: NetworkFailureKind.offline) =>
      l10n.failureNetworkOffline,
    NetworkFailure(kind: NetworkFailureKind.timeout) =>
      l10n.failureNetworkTimeout,
    NetworkFailure(kind: NetworkFailureKind.server) =>
      l10n.failureNetworkServer,
    AuthFailure() => l10n.failureAuth,
    ValidationFailure(:final rule) => _validation(l10n, rule),
    NotFoundFailure() => l10n.failureNotFound,
    ConflictFailure() => l10n.failureConflict,
    PermissionFailure(permission: AppPermission.notifications) =>
      l10n.failurePermissionNotifications,
    PermissionFailure(permission: AppPermission.calendar) =>
      l10n.failurePermissionCalendar,
    UndoExpiredFailure() => l10n.failureUndoExpired,
    UnexpectedFailure() => l10n.failureUnexpected,
  };
}

String _validation(AppLocalizations l10n, ValidationRule rule) {
  return switch (rule) {
    ValidationRule.required => l10n.failureValidationRequired,
    ValidationRule.tooLong => l10n.failureValidationTooLong,
    ValidationRule.outOfRange => l10n.failureValidationOutOfRange,
    ValidationRule.invalidFormat => l10n.failureValidationInvalidFormat,
    ValidationRule.tooLarge => l10n.failureValidationTooLarge,
  };
}
