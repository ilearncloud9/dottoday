@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
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

/// Minimal's task screen (ED-089, ED-216; M19.6 part 6d-1) beside
/// E-PhonesMinimal's "Task sheet (minimal)" row and E-Minimal's task in
/// the Day column: running and ahead on phones; open in the Mac and web
/// column.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

  // UUID v7s: a task link only carries one (D2).
  const deep = '0192f000-0000-7000-8000-00000000d001';
  const lunch = '0192f000-0000-7000-8000-00000000d002';

  Occurrence task(String id, String color, String icon, int h, int min) =>
      occurrenceFixture().copyWith(
        id: id,
        title: id == deep ? 'Deep work: roadmap' : 'Lunch',
        colorKey: color,
        iconKey: icon,
        startUtc: at(h),
        tzId: 'Europe/Berlin',
        durationMin: min,
        status: OccurrenceStatus.planned,
      );

  // Deep work 10–noon (running at 10:42), Lunch 1:30–2:15 PM, Berlin.
  final day = [
    task(deep, 'indigo', 'focus_block', 9, 120),
    task(lunch, 'rose', 'meal', 12, 45),
  ];

  Future<void> shot(
    WidgetTester tester,
    TargetPlatform p,
    Size size,
    String place,
    String name, {
    ThemeMode mode = ThemeMode.light,
  }) async {
    debugDefaultTargetPlatformOverride = p;
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
      router.go(place);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/task_m_$name.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  const phone = Size(390, 844);
  const android = Size(412, 915);
  const mac = Size(1280, 800);

  testWidgets('golden: iPhone, running', (tester) async {
    await shot(
      tester,
      TargetPlatform.iOS,
      phone,
      AppRoutes.withTask(AppRoutes.today, deep),
      'iphone_running',
    );
  });

  testWidgets('golden: iPhone, ahead, dark', (tester) async {
    await shot(
      tester,
      TargetPlatform.iOS,
      phone,
      AppRoutes.withTask(AppRoutes.today, lunch),
      'iphone_ahead_dark',
      mode: ThemeMode.dark,
    );
  });

  testWidgets('golden: Android, running', (tester) async {
    await shot(
      tester,
      TargetPlatform.android,
      android,
      AppRoutes.withTask(AppRoutes.today, deep),
      'android_running',
    );
  });

  testWidgets('golden: Mac, in the Day column', (tester) async {
    await shot(
      tester,
      TargetPlatform.macOS,
      mac,
      AppRoutes.withTask(AppRoutes.now, deep),
      'mac_column',
    );
  });

  testWidgets('golden: web chrome, in the Day column, dark', (tester) async {
    await shot(
      tester,
      TargetPlatform.linux,
      mac,
      AppRoutes.withTask(AppRoutes.now, lunch),
      'web_column_dark',
      mode: ThemeMode.dark,
    );
  });
}
