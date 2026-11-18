@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Mac Workspace (E-FullA-v2, M19.2 part 1a): sidebar and toolbar over
/// Week and 3 days on the hour grid and Day on hours (part 2), light and
/// dark.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester,
    ThemeMode mode, {
    String place = '/week/2026-10-21',
  }) async {
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
            now: DateTime.utc(2026, 10, 21, 8),
            occurrences: FakeOccurrenceRepository(
              demoDayRows(DateTime(2026, 10, 21)),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go(place);
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('golden: the Mac Workspace, Week, ${mode.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_week_mac_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    testWidgets('golden: the Mac Workspace, Day, ${mode.name}', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode, place: '/today/2026-10-21');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_day_mac_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    testWidgets('golden: the Mac Workspace, 3 days, ${mode.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode, place: '/3-days/2026-10-21');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_3days_mac_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
