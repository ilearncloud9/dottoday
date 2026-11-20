@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
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

/// Minimal on tablets (E-R2-1 2a, 2b, 4a; ED-266; M19.6 part 6e-2): the
/// Now pane and Day column with the apps' toolbar when expanded; the Day
/// under Now at medium.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

  Occurrence task(String id, String color, String icon, int h, int min) =>
      occurrenceFixture().copyWith(
        id: id,
        title: id,
        colorKey: color,
        iconKey: icon,
        startUtc: at(h),
        tzId: 'Europe/Berlin',
        durationMin: min,
        status: OccurrenceStatus.planned,
      );

  final day = [
    task('Deep work: roadmap', 'indigo', 'focus_block', 9, 120),
    task('Lunch', 'rose', 'meal', 12, 45),
    task('Gym', 'violet', 'focus_block', 17, 60),
  ];

  Future<void> shot(
    WidgetTester tester,
    Size size,
    String name, {
    TargetPlatform platform = TargetPlatform.iOS,
    ThemeMode mode = ThemeMode.light,
  }) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      tester.view
        ..physicalSize = size
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
        matchesGoldenFile('goldens/now_tablet_$name.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('golden: iPad Air landscape, expanded', (tester) async {
    await shot(tester, const Size(1180, 820), 'ipad_expanded');
  });

  testWidgets('golden: iPad Air portrait, medium', (tester) async {
    await shot(tester, const Size(820, 1180), 'ipad_medium');
  });

  testWidgets('golden: Android tablet landscape, expanded, dark', (
    tester,
  ) async {
    await shot(
      tester,
      const Size(1280, 800),
      'android_expanded_dark',
      platform: TargetPlatform.android,
      mode: ThemeMode.dark,
    );
  });

  testWidgets('golden: Android tablet portrait, medium', (tester) async {
    await shot(
      tester,
      const Size(800, 1280),
      'android_medium',
      platform: TargetPlatform.android,
    );
  });
}
