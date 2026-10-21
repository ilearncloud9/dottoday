import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/widgets/widget_snapshot.dart';

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
final class UnwiredWidgetSnapshotSink implements WidgetSnapshotSink {
  const UnwiredWidgetSnapshotSink();

  @override
  Future<void> write(WidgetSnapshot snapshot) async {}
}
