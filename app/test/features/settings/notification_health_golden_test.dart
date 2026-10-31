// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/features/settings/pages/notification_health_page.dart';
import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

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
  setUpAll(tz_data.initializeTimeZones);
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
  // A muted reminder sound, named (derived — docs/12 §4, §7): none, one
  // and three muted, at 200 % text and right-to-left too.
  for (final (name, muted) in [
    ('sounds_0', const <String>[]),
    ('sounds_1', const ['clear.lift']),
    ('sounds_3', const ['clear.lift', 'play.rooster', 'start.swing']),
  ]) {
    goldenMatrix(
      'settings_health_$name',
      // Tall enough for the muted row and its button at 200 % text.
      height: 1500,
      platform: TargetPlatform.android,
      a11yVariants: true,
      overrides: [
        notificationHealthChecksProvider.overrideWith(
          (ref) async => [
            const HealthCheck(HealthCheckKind.permission, _ok),
            const HealthCheck(HealthCheckKind.exactAlarms, _ok),
            const HealthCheck(HealthCheckKind.battery, _ok),
            const HealthCheck(HealthCheckKind.doNotDisturb, _ok),
            HealthCheck(
              HealthCheckKind.sounds,
              muted.isEmpty ? _ok : _problem,
              mutedSounds: muted,
            ),
            const HealthCheck(HealthCheckKind.clock, _ok),
          ],
        ),
      ],
      build: (_) => const NotificationHealthPage(),
    );
  }
  // The Wake Up alarm's row per tier (derived — docs/15 §2, W1a): alarm
  // and full-screen intent revoked on Android, time-sensitive on iPhone,
  // at 200 % text and right-to-left too.
  for (final (name, platform, level, wakeUp) in [
    (
      'wake_up_alarm',
      TargetPlatform.android,
      _ok,
      const AlarmCapabilities(AlarmTier.alarm),
    ),
    (
      'wake_up_fsi_off',
      TargetPlatform.android,
      _problem,
      const AlarmCapabilities(AlarmTier.headsUp, [
        AlarmBlocker.fullScreenIntentRevoked,
      ]),
    ),
    (
      'wake_up_time_sensitive',
      TargetPlatform.iOS,
      HealthLevel.info,
      const AlarmCapabilities(AlarmTier.timeSensitive),
    ),
    // iOS 26+ with alarms not allowed, and an iPhone that could update
    // to it (W1b).
    (
      'wake_up_alarms_off',
      TargetPlatform.iOS,
      HealthLevel.info,
      const AlarmCapabilities(AlarmTier.timeSensitive, [
        AlarmBlocker.alarmsDenied,
      ]),
    ),
    (
      'wake_up_needs_update',
      TargetPlatform.iOS,
      HealthLevel.info,
      const AlarmCapabilities(AlarmTier.timeSensitive, [AlarmBlocker.osTooOld]),
    ),
  ]) {
    goldenMatrix(
      'settings_health_$name',
      height: 1500,
      platform: platform,
      a11yVariants: true,
      overrides: [
        notificationHealthChecksProvider.overrideWith(
          (ref) async => [
            const HealthCheck(HealthCheckKind.permission, _ok),
            HealthCheck(HealthCheckKind.wakeUp, level, wakeUp: wakeUp),
            const HealthCheck(HealthCheckKind.clock, _ok),
          ],
        ),
        lastWakeUpProvider.overrideWith((ref) async => null),
      ],
      build: (_) => const NotificationHealthPage(),
    );
  }
  // The Wake Up row with the last morning under it (docs/15 §4, M17.3).
  goldenMatrix(
    'settings_health_wake_up_last',
    height: 900,
    widths: const {'compact'},
    overrides: [
      ...timelineOverrides(
        now: DateTime.utc(2026, 11, 2, 7),
        wakeUpDays: FakeWakeUpDayRepository([
          WakeUpDay(
            date: '2026-11-02',
            rangAtUtc: DateTime.utc(2026, 11, 2, 5, 30),
            stoppedAtUtc: DateTime.utc(2026, 11, 2, 5, 41),
            snoozes: 1,
          ),
        ]),
      ),
      notificationHealthChecksProvider.overrideWith(
        (ref) async => [
          const HealthCheck(HealthCheckKind.permission, _ok),
          const HealthCheck(
            HealthCheckKind.wakeUp,
            _ok,
            wakeUp: AlarmCapabilities(AlarmTier.alarm),
          ),
        ],
      ),
    ],
    build: (_) => const NotificationHealthPage(),
  );
  // The test alarm's waiting and asking steps (M6.5.9, derived).
  for (final step in [TestAlarmStep.waiting, TestAlarmStep.ask]) {
    goldenMatrix(
      'settings_test_alarm_${step.name}',
      height: 300,
      build: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: TestAlarmCard(
          initial: step,
          onSend: () async => DateTime.utc(2026),
          onCancel: () async {},
          now: () => DateTime.utc(2026, 10, 23, 9),
          afterNo: '',
        ),
      ),
    );
  }
}
