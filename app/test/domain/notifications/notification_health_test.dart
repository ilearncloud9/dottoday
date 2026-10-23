import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';
import 'package:flutter_test/flutter_test.dart';

// The notification health rows per platform (docs/09 M6.5.8, 11 A0).
List<HealthCheckKind> _kinds(List<HealthCheck> c) => [
  for (final x in c) x.kind,
];

void main() {
  const granted = PermissionState.granted;

  test('each platform lists what its OS can get in the way', () {
    expect(
      _kinds(
        notificationHealth(
          const HealthInputs(
            platform: HealthPlatform.android,
            permission: granted,
          ),
        ),
      ),
      [
        HealthCheckKind.permission,
        HealthCheckKind.exactAlarms,
        HealthCheckKind.battery,
        HealthCheckKind.doNotDisturb,
        HealthCheckKind.clock,
      ],
    );
    for (final apple in [HealthPlatform.iphone, HealthPlatform.mac]) {
      expect(
        _kinds(
          notificationHealth(
            HealthInputs(platform: apple, permission: granted),
          ),
        ),
        [
          HealthCheckKind.permission,
          HealthCheckKind.focus,
          HealthCheckKind.clock,
        ],
      );
    }
    expect(
      _kinds(
        notificationHealth(
          const HealthInputs(platform: HealthPlatform.web, permission: granted),
        ),
      ),
      [
        HealthCheckKind.permission,
        HealthCheckKind.webPush,
        HealthCheckKind.clock,
      ],
    );
  });

  test('problems are what needs fixing; DND, Focus and push are info', () {
    final checks = notificationHealth(
      HealthInputs(
        platform: HealthPlatform.android,
        permission: PermissionState.notAsked,
        exactAlarms: false,
        batteryRestricted: true,
        doNotDisturb: true,
        clockSkew: ClockSkew.of(const Duration(minutes: 7)),
      ),
    );
    expect(healthProblems(checks), 4);
    expect(
      checks.firstWhere((c) => c.kind == HealthCheckKind.doNotDisturb).level,
      HealthLevel.info,
    );
    expect(checks.last.skew?.minutes, 7);
  });

  test('all good: nothing to fix', () {
    final checks = notificationHealth(
      const HealthInputs(
        platform: HealthPlatform.web,
        permission: granted,
        webPushReady: true,
      ),
    );
    expect(healthProblems(checks), 0);
    expect(checks.every((c) => c.level == HealthLevel.ok), isTrue);
  });
}
