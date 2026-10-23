import 'package:dottoday/data/notifications/notification_platform.dart';

/// An in-memory OS scheduler: what is pending, and every call made.
final class FakeNotificationPlatform implements NotificationPlatform {
  final pendingById = <int, OsNotification>{};
  final scheduled = <OsNotification>[];
  final cancelled = <int>[];
  void Function(NotificationTap)? onTap;
  NotificationTap? launch;

  @override
  Future<void> initialize(void Function(NotificationTap) onTap) async =>
      this.onTap = onTap;

  @override
  Future<NotificationTap?> launchTap() async => launch;

  @override
  Future<List<(int, String?)>> pending() async => [
    for (final n in pendingById.values) (n.id, n.payload),
  ];

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    pendingById.remove(id);
  }

  @override
  Future<void> schedule(OsNotification n) async {
    scheduled.add(n);
    pendingById[n.id] = n;
  }
}
