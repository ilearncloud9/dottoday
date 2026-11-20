@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/now/wide/day_edge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Minimal on a narrow Mac (E-G4-3-Narrow, ED-170; M19.6 part 6e-1): the
/// Day column folded at 840 × 640 and its panel open, either side of the
/// fold point (1041, 1042), and 840 × 640 at 130 % and 200 % text.
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
    double text = 1,
    bool openPanel = false,
  }) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = text;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final router = buildRouter(appScreens);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        testRouterApp(
          router,
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
      if (openPanel) {
        await tester.tap(
          find.descendant(
            of: find.byType(DayEdge),
            matching: find.byType(InkWell),
          ),
        );
        await tester.pumpAndSettle();
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/now_narrow_$name.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('golden: 840 × 640, folded', (tester) async {
    await shot(tester, const Size(840, 640), '840_folded');
  });

  testWidgets('golden: 840 × 640, the Day panel open', (tester) async {
    await shot(tester, const Size(840, 640), '840_panel', openPanel: true);
  });

  testWidgets('golden: 1041, folded', (tester) async {
    await shot(tester, const Size(1041, 640), '1041');
  });

  testWidgets('golden: 1042, unfolded', (tester) async {
    await shot(tester, const Size(1042, 640), '1042');
  });

  testWidgets('golden: 840 × 640 at 130 % text', (tester) async {
    await shot(tester, const Size(840, 640), '840_130', text: 1.3);
  });

  testWidgets('golden: 840 × 640 at 200 % text', (tester) async {
    await shot(tester, const Size(840, 640), '840_200', text: 2);
  });
}
