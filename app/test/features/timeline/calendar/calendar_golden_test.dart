@Tags(['golden'])
library;

import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'calendar_world.dart';

/// The Calendar tab beside its boards (docs/09 M20.1): E-Phones Calendar
/// on iPhone and Android, E-R2-12 frame 2 on an iPad at medium width.
void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  const cases = [
    ('iphone', Size(390, 844), TargetPlatform.iOS),
    ('android', Size(412, 892), TargetPlatform.android),
    ('ipad_medium', Size(820, 1180), TargetPlatform.iOS),
    ('android_tablet_medium', Size(800, 1280), TargetPlatform.android),
  ];
  testWidgets('ipad_medium week', (tester) async {
    final router = await pumpCalendar(tester, size: const Size(820, 1180));
    router.go(AppRoutes.week);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/calendar_ipad_medium_week_light.png'),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  for (final (name, size, platform) in cases) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('$name ${mode.name}', (tester) async {
        await pumpCalendar(tester, size: size, mode: mode);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/calendar_${name}_${mode.name}.png'),
        );
      }, variant: TargetPlatformVariant.only(platform));
    }
  }
}
