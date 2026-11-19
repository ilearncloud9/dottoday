@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Workspace at touch sizes on expanded tablets (E-R2-2, ED-269,
/// M19.2 part 3a): an iPad Air and an Android tablet in landscape, light
/// and dark.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester,
    ThemeMode mode, {
    required Size size,
    required String place,
  }) async {
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
            now: DateTime.utc(2026, 10, 21, 8),
            occurrences: FakeOccurrenceRepository(
              demoDayRows(DateTime(2026, 10, 21)),
            ),
            subtasks: FakeSubtaskRepository(
              demoDaySubtasks(DateTime(2026, 10, 21)),
            ),
          ),
          // iOS asks for the one-time Siri card; not on this board.
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go(place);
    await tester.pumpAndSettle();
  }

  const ipad = Size(1180, 820);
  const android = Size(1280, 800);

  Future<void> on(TargetPlatform platform, Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('golden: iPad Week at touch sizes, ${mode.name}', (
      tester,
    ) async {
      await on(TargetPlatform.iOS, () async {
        await pump(tester, mode, size: ipad, place: '/week/2026-10-21');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/tablet_week_ipad_${mode.name}.png'),
        );
      });
    });
    testWidgets('golden: Android tablet Week at touch sizes, ${mode.name}', (
      tester,
    ) async {
      await on(TargetPlatform.android, () async {
        await pump(tester, mode, size: android, place: '/week/2026-10-21');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/tablet_week_android_${mode.name}.png'),
        );
      });
    });
    testWidgets('golden: iPad Day at 96 an hour, ${mode.name}', (tester) async {
      await on(TargetPlatform.iOS, () async {
        await pump(tester, mode, size: ipad, place: '/today/2026-10-21');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/tablet_day_ipad_${mode.name}.png'),
        );
      });
    });
    // ED-269: a tap opens the inspector over the grid; it never docks.
    testWidgets('golden: iPad floating inspector, ${mode.name}', (
      tester,
    ) async {
      await on(TargetPlatform.iOS, () async {
        await pump(tester, mode, size: ipad, place: '/3-days/2026-10-21');
        await tester.tap(find.textContaining('Deep work').first);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/tablet_inspector_ipad_${mode.name}.png'),
        );
      });
    });
  }
}
