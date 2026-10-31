import 'package:dottoday/data/notifications/sound_files.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/exact_alarms.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:flutter/services.dart';

/// [AlarmGateway] over the permissions Dottoday already reads and the
/// `dottoday/alarm` channel (docs/15 W1, ADR-0017): on Android
/// `WakeUpAlarms` (exact alarm clock, ringing service, full-screen screen),
/// on iPhone `AlarmBridge` (AlarmKit, iOS 26+). A missing handler (macOS,
/// the web, tests, a background engine) arms nothing and reads as allowed,
/// so no screen shows a problem it can't explain.
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
    alarmKit: await _alarmKit(),
  );

  @override
  Future<Set<DateTime>?> sync(List<WakeUpAlarm> alarms) async {
    if (!_native) return const {};
    try {
      final armed = await _channel.invokeListMethod<int>('sync', [
        for (final a in alarms) _toChannel(a),
      ]);
      return {
        for (final ms in armed ?? const <int>[])
          DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
      };
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<void> disarmAll() async {
    if (!_native) return;
    try {
      await _channel.invokeMethod<void>('disarmAll');
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<bool> test(WakeUpAlarm alarm) async {
    if (!_native) return false;
    try {
      return await _channel.invokeMethod<bool>('test', _toChannel(alarm)) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Only phones arm; the Mac and the web keep the notification path.
  bool get _native => platform.isPhone;

  Map<String, Object> _toChannel(WakeUpAlarm a) => {
    'id': a.id,
    'fireAtMs': a.fireAtUtc.millisecondsSinceEpoch,
    'sound': platform == HealthPlatform.iphone
        ? appleSoundFile(a.sound)
        : androidSoundResource(a.sound),
    'title': a.title,
    'body': a.body,
    'stop': a.stopLabel,
    'snooze': a.snoozeLabel,
    'snoozeMin': a.snoozeMinutes,
    'snoozeLimit': a.snoozeLimit,
    'rampSec': a.rampSeconds,
    'minimal': a.minimal,
  };

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
      case AlarmBlocker.alarmsDenied:
        await _channel.invokeMethod<void>('allowAlarms');
      case AlarmBlocker.osTooOld:
        await _channel.invokeMethod<void>('openSoftwareUpdate');
    }
  }

  @override
  Future<void> requestAuthorization() async {
    if (await _alarmKit() != AlarmKitStatus.notAsked) return;
    await _channel.invokeMethod<void>('allowAlarms');
  }

  Future<AlarmKitStatus> _alarmKit() async {
    if (platform != HealthPlatform.iphone) return AlarmKitStatus.unsupported;
    try {
      final name = await _channel.invokeMethod<String>('alarmKitStatus');
      return AlarmKitStatus.values.asNameMap()[name] ??
          AlarmKitStatus.unsupported;
    } on MissingPluginException {
      return AlarmKitStatus.unsupported;
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
