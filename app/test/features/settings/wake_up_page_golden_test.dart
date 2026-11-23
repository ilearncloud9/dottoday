// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/features/settings/pages/wake_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart' hide Device;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// Settings › Wake Up alarm › Sound and snooze (derived — docs/15 §9, §10,
// M17.2; Alarm sounds on, ED-084): on with every row, on with alarms not allowed yet (the fix in
// the switch row), and minimal mode's short form.

List<Override> _overrides(
  Settings settings, {
  AlarmCapabilities caps = const AlarmCapabilities(AlarmTier.alarm),
  MissionSensors? sensors,
}) => [
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
    missionSensors: sensors,
    profile: testProfile(settings: settings.copyWith(alarmDeviceId: 'self')),
    wakeUpAlarm: caps,
    // This iPhone rings Wake Up (ED-084): "Alarm sounds on" reads Ready.
    devices: [
      Device(
        id: 'self',
        userId: testUserId,
        platform: DevicePlatform.ios,
        form: DeviceForm.phone,
        canRing: true,
        alarmOn: true,
        rings: true,
        armedWakeUtc: DateTime.utc(2026, 10, 22, 5),
        lastSeenUtc: DateTime.utc(2026, 10, 21, 8),
      ),
    ],
  ),
  envProvider.overrideWithValue(
    Env(
      supabaseUrl: Uri.parse('https://example.supabase.co'),
      supabaseAnonKey: 'anon',
    ),
  ),
];

const _on = Settings(wakeUpAlarm: true, startSoundId: 'start.sunrise');

void main() {
  setUpAll(loadAppFonts);
  setUpAll(tz_data.initializeTimeZones);
  goldenMatrix(
    'settings_wake_up_on',
    height: 1600,
    a11yVariants: true,
    act: (t) async {
      final page = t.element(find.byType(WakeUpPage));
      if (MediaQuery.textScalerOf(page).scale(1) <= 1) return;
      await t.scrollUntilVisible(
        find.text('Snooze limit'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.pumpAndSettle();
    },
    overrides: _overrides(_on),
    build: (_) => const WakeUpPage(),
  );
  goldenMatrix(
    'settings_wake_up_alarms_off',
    height: 900,
    widths: const {'compact'},
    overrides: _overrides(
      _on,
      caps: const AlarmCapabilities(AlarmTier.timeSensitive, [
        AlarmBlocker.alarmsDenied,
      ]),
    ),
    build: (_) => const WakeUpPage(),
  );
  goldenMatrix(
    'settings_wake_up_minimal',
    height: 1000,
    widths: const {'compact'},
    overrides: _overrides(_on.copyWith(uiLayout: UiLayout.minimal)),
    build: (_) => const WakeUpPage(),
  );
  // E-R2-28 (M20.6 part 5): the mission picker, each with its task icon;
  // Walk has no sensor here and Light is blocked: listed, dimmed, why.
  goldenMatrix(
    'settings_mission_picker',
    height: 900,
    widths: const {'compact'},
    act: (t) async {
      await t.scrollUntilVisible(
        find.text('Mission'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(find.text('Mission'));
      await t.pumpAndSettle();
    },
    overrides: _overrides(
      _on.copyWith(missionMode: MissionMode.always),
      sensors: FakeMissionSensors(
        supports: const {
          MissionKind.walk: MissionSupport.missing,
          MissionKind.light: MissionSupport.denied,
        },
      ),
    ),
    build: (_) => const WakeUpPage(),
  );
}
