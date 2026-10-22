// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

final _overrides = [
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
    profile: testProfile(
      settings: const Settings(use24h: true),
    ).copyWith(displayName: 'Kody'),
  ),
  appVersionProvider.overrideWith((ref) async => '0.1.0 (1)'),
  envProvider.overrideWithValue(
    Env(
      supabaseUrl: Uri.parse('https://example.supabase.co'),
      supabaseAnonKey: 'anon',
    ),
  ),
];

Widget _settings() => const SettingsScreen();

Future<void> _open(WidgetTester tester, String row) async {
  // The list builds lazily: scroll until the row exists.
  await tester.scrollUntilVisible(
    find.text(row),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(row));
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  // P1 (`A-ios-settings`): the first screenful, as the render.
  goldenMatrix(
    'settings',
    height: 844,
    overrides: _overrides,
    build: (_) => _settings(),
  );
  goldenMatrix(
    'settings_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    overrides: _overrides,
    build: (_) => _settings(),
  );
  // The rest of the list (LOOK, DATA, ABOUT), scrolled.
  goldenMatrix(
    'settings_lower',
    height: 844,
    widths: const {'compact', 'expanded'},
    act: (tester) => tester.drag(find.byType(ListView), const Offset(0, -1200)),
    overrides: _overrides,
    build: (_) => _settings(),
  );
  // Derived (§5.3): Different days and Send feedback.
  goldenMatrix(
    'settings_weekdays',
    height: 844,
    widths: const {'compact', 'expanded'},
    act: (t) => _open(t, 'Different days'),
    overrides: _overrides,
    build: (_) => _settings(),
  );
  goldenMatrix(
    'settings_feedback',
    height: 640,
    widths: const {'compact', 'expanded'},
    act: (t) => _open(t, 'Send feedback'),
    overrides: _overrides,
    build: (_) => _settings(),
  );
}
