@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Mac and web Now pane with the Day column beside E-Minimal frames 1
/// (Mac) and 2 (web, through `debugWebChromeOverride`) at 1280 × 800;
/// M19.6 part 6c.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

  Occurrence task(
    String id,
    String color,
    String icon,
    int h,
    int min, [
    int m = 0,
  ]) => occurrenceFixture().copyWith(
    id: id,
    title: id,
    colorKey: color,
    iconKey: icon,
    startUtc: at(h, m),
    tzId: 'Europe/Berlin',
    durationMin: min,
    status: OccurrenceStatus.planned,
  );

  // The board's day (Berlin): Deep work 10–12, Call 11:30–12, Lunch at
  // 1:30, then four more.
  final day = [
    task('Deep work: roadmap', 'indigo', 'focus_block', 9, 120),
    task('Call with Sam', 'teal', 'call', 9, 30, 30),
    task('Lunch', 'rose', 'meal', 11, 45, 30),
    task('Pick up parcel', 'olive', 'call', 14, 45),
    task('Gym', 'violet', 'focus_block', 17, 60),
    task('Read', 'brown', 'meal', 20, 30, 30),
    task('Dentist', 'slate', 'call', 13, 30),
  ];

  Future<void> shot(
    WidgetTester tester,
    TargetPlatform p,
    String name, {
    ThemeMode mode = ThemeMode.light,
  }) async {
    debugDefaultTargetPlatformOverride = p;
    try {
      tester.view
        ..physicalSize = const Size(1280, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = buildRouter(appScreens);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        testRouterApp(
          router,
          themeMode: mode,
          overrides: [
            ...timelineOverrides(
              now: at(9, 42),
              occurrences: FakeOccurrenceRepository(day),
              profile: testProfile(
                settings: const Settings(
                  uiLayout: UiLayout.minimal,
                  use24h: false,
                ),
              ),
            ),
            siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/now_wide_$name.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('golden: Mac', (tester) async {
    await shot(tester, TargetPlatform.macOS, 'mac');
  });

  testWidgets('golden: Mac, dark', (tester) async {
    await shot(tester, TargetPlatform.macOS, 'mac_dark', mode: ThemeMode.dark);
  });

  testWidgets('golden: web chrome', (tester) async {
    debugWebChromeOverride = true;
    addTearDown(() => debugWebChromeOverride = null);
    await shot(tester, TargetPlatform.linux, 'web');
  });
}
