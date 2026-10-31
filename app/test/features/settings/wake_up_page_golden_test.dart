// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/features/settings/pages/wake_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// Settings › Wake Up alarm › Sound and snooze (derived — docs/15 §9, §10,
// M17.2): on with every row, on with alarms not allowed yet (the fix in
// the switch row), and minimal mode's short form.

List<Override> _overrides(
  Settings settings, {
  AlarmCapabilities caps = const AlarmCapabilities(AlarmTier.alarm),
}) => [
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
    profile: testProfile(settings: settings),
    wakeUpAlarm: caps,
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
}
