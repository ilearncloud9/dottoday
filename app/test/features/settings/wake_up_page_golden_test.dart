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
import 'package:dottoday/features/settings/wake_wind/alarm_device_page.dart';
import 'package:dottoday/features/settings/wake_wind/missions_page.dart';
import 'package:dottoday/features/settings/wake_wind/vary_sound_page.dart';
import 'package:dottoday/features/settings/wake_wind/wake_up_options_page.dart';
import 'package:dottoday/features/settings/wake_wind/wake_wind_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart' hide Device;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// Wake Up and Wind Down's alarm and reminders (E-Phones, ED-084) and the
// pages they open: Wake Up options (E-R2-32), Missions (E-R2-28) and Vary
// the sound (owner 2026-11-24).

List<Override> _overrides(
  Settings settings, {
  AlarmCapabilities caps = const AlarmCapabilities(AlarmTier.alarm),
  MissionSensors? sensors,
  List<Device> more = const [],
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
      ...more,
    ],
  ),
  envProvider.overrideWithValue(
    Env(
      supabaseUrl: Uri.parse('https://example.supabase.co'),
      supabaseAnonKey: 'anon',
    ),
  ),
];

Device _other(
  String id,
  DevicePlatform platform,
  DeviceForm form, {
  bool alarmOn = true,
  DateTime? seen,
}) => Device(
  id: id,
  userId: testUserId,
  platform: platform,
  form: form,
  canRing: form != DeviceForm.desktop,
  alarmOn: alarmOn,
  lastSeenUtc: seen ?? DateTime.utc(2026, 10, 21, 8),
);

const _on = Settings(wakeUpAlarm: true, startSoundId: 'start.sunrise');

void main() {
  setUpAll(loadAppFonts);
  setUpAll(tz_data.initializeTimeZones);
  // E-Phones "iPhone · alarm on" (ED-084): the page down to Reminders.
  goldenMatrix(
    'settings_wake_up_on',
    height: 2600,
    a11yVariants: true,
    act: (t) async {
      final page = t.element(find.byType(WakeWindDownPage));
      if (MediaQuery.textScalerOf(page).scale(1) <= 1) return;
      await t.scrollUntilVisible(
        find.text('Snooze limit'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.pumpAndSettle();
    },
    overrides: _overrides(_on),
    build: (_) => const WakeWindDownPage(),
  );
  // E-Phones "iPhone · alarm off": the switch, the test and the footers.
  goldenMatrix(
    'settings_wake_up_off',
    height: 2000,
    widths: const {'compact'},
    overrides: _overrides(const Settings(startSoundId: 'start.sunrise')),
    build: (_) => const WakeWindDownPage(),
  );
  goldenMatrix(
    'settings_wake_up_alarms_off',
    height: 2400,
    widths: const {'compact'},
    overrides: _overrides(
      _on,
      caps: const AlarmCapabilities(AlarmTier.timeSensitive, [
        AlarmBlocker.alarmsDenied,
      ]),
    ),
    build: (_) => const WakeWindDownPage(),
  );
  goldenMatrix(
    'settings_wake_up_minimal',
    height: 2200,
    widths: const {'compact'},
    overrides: _overrides(_on.copyWith(uiLayout: UiLayout.minimal)),
    build: (_) => const WakeWindDownPage(),
  );
  // E-R2-32 / E-R2-38 (ED-337, ED-344): How it works, the card, the check.
  goldenMatrix(
    'settings_wake_up_options',
    height: 1100,
    overrides: _overrides(_on),
    build: (_) => const WakeUpOptionsPage(),
  );
  // E-R2-28 (ED-331): the missions, each with its task icon; Walk has no
  // sensor here and Light is blocked: listed, dimmed, why.
  goldenMatrix(
    'settings_missions',
    height: 1200,
    overrides: _overrides(
      _on.copyWith(missionMode: MissionMode.always),
      sensors: FakeMissionSensors(
        supports: const {
          MissionKind.walk: MissionSupport.missing,
          MissionKind.light: MissionSupport.denied,
        },
      ),
    ),
    build: (_) => const MissionsPage(),
  );
  // E-Phones "iPhone · Alarm sounds on" (ED-084): this iPhone ready, an
  // iPad with alarms off, an Android phone not seen for 3 days; a Mac and
  // the web can't ring. Named by kind (owner 2026-11-24).
  goldenMatrix(
    'settings_alarm_device',
    height: 1000,
    overrides: _overrides(
      _on,
      more: [
        _other('ipad', DevicePlatform.ios, DeviceForm.tablet, alarmOn: false),
        _other(
          'pixel',
          DevicePlatform.android,
          DeviceForm.phone,
          seen: DateTime.utc(2026, 10, 18, 8),
        ),
        _other('mac', DevicePlatform.macos, DeviceForm.desktop),
        _other('web', DevicePlatform.web, DeviceForm.desktop),
      ],
    ),
    build: (_) => const AlarmDevicePage(),
  );
  // Vary the sound (owner 2026-11-24): the switch and the rotation.
  goldenMatrix(
    'settings_vary_sound',
    height: 1200,
    widths: const {'compact'},
    overrides: _overrides(_on.copyWith(wakeUpVarySound: true)),
    build: (_) => const VarySoundPage(),
  );
}
