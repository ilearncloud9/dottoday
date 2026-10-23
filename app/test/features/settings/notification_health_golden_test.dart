// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';
import 'package:dottoday/features/settings/pages/notification_health_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// Notification health's four states (derived — 11 A0, docs/09 M6.5.8):
// all good · permission off · exact alarms/battery off · clock off.

const _ok = HealthLevel.ok;
const _problem = HealthLevel.problem;

final _states = <String, List<HealthCheck>>{
  'all_good': const [
    HealthCheck(HealthCheckKind.permission, _ok),
    HealthCheck(HealthCheckKind.exactAlarms, _ok),
    HealthCheck(HealthCheckKind.battery, _ok),
    HealthCheck(HealthCheckKind.doNotDisturb, _ok),
    HealthCheck(HealthCheckKind.clock, _ok),
  ],
  'permission_off': const [
    HealthCheck(HealthCheckKind.permission, _problem),
    HealthCheck(HealthCheckKind.focus, HealthLevel.info),
    HealthCheck(HealthCheckKind.clock, _ok),
  ],
  'android_off': const [
    HealthCheck(HealthCheckKind.permission, _ok),
    HealthCheck(HealthCheckKind.exactAlarms, _problem),
    HealthCheck(HealthCheckKind.battery, _problem),
    HealthCheck(HealthCheckKind.doNotDisturb, HealthLevel.info),
    HealthCheck(HealthCheckKind.clock, _ok),
  ],
  'clock_off': [
    const HealthCheck(HealthCheckKind.permission, _ok),
    const HealthCheck(HealthCheckKind.webPush, HealthLevel.info),
    HealthCheck(
      HealthCheckKind.clock,
      _problem,
      skew: ClockSkew.of(const Duration(minutes: 7)),
    ),
  ],
};

void main() {
  setUpAll(loadAppFonts);
  for (final MapEntry(key: name, value: checks) in _states.entries) {
    goldenMatrix(
      'settings_health_$name',
      height: 760,
      overrides: [
        notificationHealthChecksProvider.overrideWith((ref) async => checks),
      ],
      build: (_) => const NotificationHealthPage(),
    );
  }
}
