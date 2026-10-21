import 'package:dottoday/domain/notifications/planned_notification.dart';

/// The OS notification scheduler (docs/04 §6). The local DB is the source
/// of truth; the OS pending set is a cache reconciled by diffing (R-10).
/// Implemented per platform in M5.1/M5.3.
abstract interface class NotificationGateway {
  /// Notifications currently pending in the OS, by id.
  Future<Map<int, PlannedNotification>> pending();

  /// Cancels then schedules exactly what [diff] lists.
  Future<void> apply(NotificationDiff diff);
}
