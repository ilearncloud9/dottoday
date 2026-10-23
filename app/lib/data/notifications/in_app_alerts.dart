import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'in_app_alerts.g.dart';

/// Reminders shown inside the app instead of by the OS: on the web without
/// notification permission, and quiet-hours ones (docs/07 Web, M5.3).
/// Newest last; the banner shows it until acted on or dismissed.
@Riverpod(keepAlive: true)
class InAppAlerts extends _$InAppAlerts {
  @override
  List<OsNotification> build() => const [];

  void add(OsNotification n) => state = [
    for (final o in state)
      if (o.id != n.id) o,
    n,
  ];

  void dismiss(int id) => state = [
    for (final o in state)
      if (o.id != id) o,
  ];
}
