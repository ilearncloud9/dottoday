// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../timeline/calendar/calendar_world.dart';

/// Settings in two panes beside its boards (docs/09 M20.7 part 5a): the
/// E-R2-11 iPad and Android tablet frames, E-R2-18's pushed sub-page and
/// E-FullA-v2's "Web · Settings, two panes" (the Mac shares it).
void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  const ipad = Size(1180, 820);
  const wide = Size(1280, 800);
  final cases = [
    ('ipad_your_day', ipad, TargetPlatform.iOS, SettingsPage.yourDay),
    ('ipad_wake_wind', ipad, TargetPlatform.iOS, SettingsPage.wakeWindDown),
    ('ipad_appearance', ipad, TargetPlatform.iOS, SettingsPage.appearance),
    (
      'android_tablet_wake_wind',
      wide,
      TargetPlatform.android,
      SettingsPage.wakeWindDown,
    ),
    (
      'android_tablet_appearance',
      wide,
      TargetPlatform.android,
      SettingsPage.appearance,
    ),
    ('mac_appearance', wide, TargetPlatform.macOS, SettingsPage.appearance),
  ];

  for (final (name, size, platform, page) in cases) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('$name ${mode.name}', (tester) async {
        final router = await pumpCalendar(tester, size: size, mode: mode);
        if (page == SettingsPage.wakeWindDown) {
          // Pushed from Your day, as E-R2-18 draws it.
          router.go(AppRoutes.settingsPage(SettingsPage.yourDay));
          await tester.pumpAndSettle();
          unawaited(router.push(AppRoutes.settingsPage(page)));
        } else {
          router.go(AppRoutes.settingsPage(page));
        }
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/settings_panes_${name}_${mode.name}.png'),
        );
      }, variant: TargetPlatformVariant.only(platform));
    }
  }

  testWidgets('ipad minimal light', (tester) async {
    final router = await pumpCalendar(
      tester,
      size: ipad,
      layout: UiLayout.minimal,
    );
    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/settings_panes_ipad_minimal_light.png'),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('ipad your day at 200 % text', (tester) async {
    final router = await pumpCalendar(tester, size: ipad, text: 2);
    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/settings_panes_ipad_your_day_t2.png'),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
