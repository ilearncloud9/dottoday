@Tags(['golden'])
library;

import 'package:dottoday/app.dart';
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

import '../../domain/fixtures.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// Minimal Add over Now (E-PhonesMinimal frames 3 and 6; M19.6 part
/// 6d-2): "Gym 6pm 1h" typed, landing at 6–7 PM on the mini horizon.
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
    task('Run', 'coral', 'run', 6, 30),
    task('Deep work', 'indigo', 'focus_block', 9, 120),
    task('Lunch', 'rose', 'meal', 12, 45),
    task('Read', 'brown', 'meal', 20, 30),
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
        ..physicalSize = p == TargetPlatform.iOS
            ? const Size(390, 844)
            : const Size(412, 915)
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
      openQuickAdd(router);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'Gym 6pm 1h');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/minimal_add_$name.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('golden: iPhone', (tester) async {
    await shot(tester, TargetPlatform.iOS, 'iphone');
  });

  testWidgets('golden: iPhone, dark', (tester) async {
    await shot(tester, TargetPlatform.iOS, 'iphone_dark', mode: ThemeMode.dark);
  });

  testWidgets('golden: Android', (tester) async {
    await shot(tester, TargetPlatform.android, 'android');
  });
}
