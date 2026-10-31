import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/exact_alarms.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/services.dart';

/// [AlarmGateway] over the permissions Dottoday already reads, plus the
/// Android full-screen-intent check on MainActivity's `dottoday/alarm`
/// channel (docs/15 W1a). A missing handler (iOS, macOS, tests) reads as
/// allowed, so no screen shows a problem it can't explain.
final class OsAlarmGateway implements AlarmGateway {
  const OsAlarmGateway({
    required this.platform,
    required this.permission,
    required this.exactAlarms,
    MethodChannel channel = const MethodChannel('dottoday/alarm'),
  }) : _channel = channel;

  final HealthPlatform platform;
  final NotificationPermission permission;
  final ExactAlarms exactAlarms;
  final MethodChannel _channel;

  @override
  Future<AlarmCapabilities> capabilities() async => alarmCapabilities(
    platform: platform,
    permission: await permission.status(),
    fullScreenIntent: await _fullScreenIntent(),
    exactAlarms: await exactAlarms.allowed(),
  );

  @override
  Future<void> fix(AlarmBlocker blocker) async {
    switch (blocker) {
      case AlarmBlocker.notAPhone:
        return;
      case AlarmBlocker.permissionDenied:
        if (await permission.status() == PermissionState.notAsked) {
          await permission.request();
        } else {
          await permission.openSettings();
        }
      case AlarmBlocker.fullScreenIntentRevoked:
        await _channel.invokeMethod<void>('openFullScreenIntentSettings');
      case AlarmBlocker.exactAlarmDenied:
        await exactAlarms.request();
    }
  }

  Future<bool> _fullScreenIntent() async {
    if (platform != HealthPlatform.android) return true;
    try {
      return await _channel.invokeMethod<bool>('canUseFullScreenIntent') ??
          true;
    } on MissingPluginException {
      return true;
    }
  }
}
