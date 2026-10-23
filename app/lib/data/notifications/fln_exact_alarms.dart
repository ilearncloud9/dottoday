import 'package:dottoday/domain/notifications/exact_alarms.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// [ExactAlarms] on Android via flutter_local_notifications; every other
/// platform reports allowed (M5.6).
final class FlnExactAlarms implements ExactAlarms {
  const FlnExactAlarms(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> allowed() async =>
      await _android?.canScheduleExactNotifications() ?? true;

  @override
  Future<void> request() async => _android?.requestExactAlarmsPermission();
}

/// Platforms without the gate (iOS, macOS, the web, tests).
final class AlwaysExactAlarms implements ExactAlarms {
  const AlwaysExactAlarms();

  @override
  Future<bool> allowed() async => true;

  @override
  Future<void> request() async {}
}
