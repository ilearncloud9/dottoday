// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/pages/sounds_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// Settings › Reminders › Sounds (derived — docs/12 §6, §7): the default
// (unset = Dot), a chosen sound with the device muted, and the Start list
// with Insistent's caption.

List<Override> _overrides(Settings settings, {bool muted = false}) => [
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
    profile: testProfile(settings: settings),
  ),
  deviceMutedProvider.overrideWith((ref) async => muted),
  envProvider.overrideWithValue(
    Env(
      supabaseUrl: Uri.parse('https://example.supabase.co'),
      supabaseAnonKey: 'anon',
    ),
  ),
];

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'settings_sounds_default',
    // The whole page and no more: a tall golden costs CI minutes.
    height: 2300,
    widths: const {'compact', 'expanded'},
    overrides: _overrides(const Settings()),
    build: (_) => const SoundsPage(),
  );
  goldenMatrix(
    'settings_sounds_muted',
    // The banner at the top (1x, 2x), then at 200 % text the Also group,
    // whose rows reflow, scrolled to rather than a 4600 px page.
    height: 1400,
    widths: const {'compact'},
    a11yVariants: true,
    act: (t) async {
      final page = t.element(find.byType(SoundsPage));
      if (MediaQuery.textScalerOf(page).scale(1) <= 1) return;
      await t.scrollUntilVisible(
        find.text('Sounds in app'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.pumpAndSettle();
    },
    overrides: _overrides(
      const Settings(
        reminderSound: 'clear.lift',
        startSoundId: 'start.swing',
        doneSoundId: 'done.checked',
        inAppSoundsEnabled: false,
      ),
      muted: true,
    ),
    build: (_) => const SoundsPage(),
  );
  goldenMatrix(
    'settings_sounds_start',
    height: 1400,
    widths: const {'compact'},
    overrides: _overrides(const Settings(startSoundId: 'start.insistent')),
    act: (t) async {
      await t.scrollUntilVisible(
        find.text('Start sound'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(find.text('Start sound'));
      await t.pumpAndSettle();
    },
    build: (_) => const SoundsPage(),
  );
}
