import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// Placeholder until the platform scheduler lands (M5.1 mobile/desktop,
/// M5.3 web): nothing is pending and nothing is scheduled.
final class UnwiredNotificationGateway implements NotificationGateway {
  const UnwiredNotificationGateway();

  @override
  Future<Map<int, PlannedNotification>> pending() async => const {};

  @override
  Future<void> apply(NotificationDiff diff) async {}
}

/// Placeholder until home-screen widgets land (M5.4).
final class UnwiredDaySnapshotSink implements DaySnapshotSink {
  const UnwiredDaySnapshotSink();

  @override
  Future<void> write(DaySnapshot snapshot) async {}
}
