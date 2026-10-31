import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter_test/flutter_test.dart';

// The Wake Up alarm's tier per device (docs/15 §2, W1a): one answer every
// surface reads.

void main() {
  const granted = PermissionState.granted;

  test('Mac and the web: rings on the phone', () {
    for (final p in [HealthPlatform.mac, HealthPlatform.web]) {
      expect(
        alarmCapabilities(platform: p, permission: granted),
        const AlarmCapabilities(AlarmTier.none, [AlarmBlocker.notAPhone]),
      );
    }
  });

  test('notifications off: nothing rings, allow is the fix', () {
    for (final p in [HealthPlatform.android, HealthPlatform.iphone]) {
      expect(
        alarmCapabilities(platform: p, permission: PermissionState.denied),
        const AlarmCapabilities(AlarmTier.none, [
          AlarmBlocker.permissionDenied,
        ]),
      );
    }
  });

  test('iPhone on the existing path: time-sensitive', () {
    expect(
      alarmCapabilities(platform: HealthPlatform.iphone, permission: granted),
      const AlarmCapabilities(AlarmTier.timeSensitive),
    );
  });

  test('Android: alarm with the full-screen intent, heads-up without', () {
    expect(
      alarmCapabilities(platform: HealthPlatform.android, permission: granted),
      const AlarmCapabilities(AlarmTier.alarm),
    );
    expect(
      alarmCapabilities(
        platform: HealthPlatform.android,
        permission: granted,
        fullScreenIntent: false,
        exactAlarms: false,
      ),
      const AlarmCapabilities(AlarmTier.headsUp, [
        AlarmBlocker.fullScreenIntentRevoked,
        AlarmBlocker.exactAlarmDenied,
      ]),
    );
  });

  test('exact alarms off is named, but keeps the tier', () {
    expect(
      alarmCapabilities(
        platform: HealthPlatform.android,
        permission: granted,
        exactAlarms: false,
      ),
      const AlarmCapabilities(AlarmTier.alarm, [AlarmBlocker.exactAlarmDenied]),
    );
  });

  test('health: a Wake Up row only for someone who uses it, on a phone', () {
    List<HealthCheck> rows(HealthPlatform p, AlarmCapabilities? wakeUp) =>
        notificationHealth(
          HealthInputs(platform: p, permission: granted, wakeUp: wakeUp),
        ).where((c) => c.kind == HealthCheckKind.wakeUp).toList();
    expect(rows(HealthPlatform.android, null), isEmpty);
    expect(
      rows(HealthPlatform.mac, const AlarmCapabilities(AlarmTier.none)),
      isEmpty,
    );
    expect(
      rows(
        HealthPlatform.android,
        const AlarmCapabilities(AlarmTier.headsUp, [
          AlarmBlocker.fullScreenIntentRevoked,
        ]),
      ).single.level,
      HealthLevel.problem,
    );
    expect(
      rows(
        HealthPlatform.iphone,
        const AlarmCapabilities(AlarmTier.timeSensitive),
      ).single.level,
      HealthLevel.info,
    );
    expect(
      rows(
        HealthPlatform.android,
        const AlarmCapabilities(AlarmTier.alarm),
      ).single.level,
      HealthLevel.ok,
    );
  });
}
