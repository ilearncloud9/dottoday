import 'package:dottoday/data/notifications/notification_platform.dart';

/// An in-memory OS scheduler: what is pending, and every call made.
final class FakeNotificationPlatform implements NotificationPlatform {
  final pendingById = <int, OsNotification>{};
  final scheduled = <OsNotification>[];
  final cancelled = <int>[];

  /// Shown in the notification centre: what [deliver] posted.
  final delivered = <int, OsNotification>{};

  /// How many times [clearAll] ran.
  int clearedAll = 0;
  void Function(NotificationTap)? onTap;
  NotificationTap? launch;

  /// What [mutedSoundIds] reports: channels muted in the OS settings.
  final muted = <String>{};

  @override
  Future<void> initialize(void Function(NotificationTap) onTap) async =>
      this.onTap = onTap;

  @override
  Future<Set<String>> mutedSoundIds() async => {...muted};

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

  /// The OS shows pending [id] now, as at its fire time.
  void deliver(int id) {
    final n = pendingById.remove(id);
    if (n != null) delivered[id] = n;
  }

  @override
  Future<void> clearAll() async {
    clearedAll++;
    pendingById.clear();
    delivered.clear();
  }
}
