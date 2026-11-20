@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/test_app.dart';
import '../support/timeline_fakes.dart';

/// Minimal's places (ED-068, ED-266, ED-207; M19.6 part 6a): the
/// iPhone's and Android's Now · Today · Inbox, an Android tablet's rail
/// and the Mac's 200 sidebar with Now · Inbox · Calendar · Search.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> shot(
    WidgetTester tester,
    TargetPlatform p,
    Size size,
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
              now: DateTime.utc(2026, 10, 21, 8),
              occurrences: FakeOccurrenceRepository(
                demoDayRows(DateTime(2026, 10, 21)),
              ),
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
      router.go('/now');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/minimal_places_$name.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('golden: iPhone, ${mode.name}', (tester) async {
      await shot(
        tester,
        TargetPlatform.iOS,
        const Size(390, 844),
        'iphone_${mode.name}',
        mode: mode,
      );
    });
  }
  testWidgets('golden: Android phone', (tester) async {
    await shot(tester, TargetPlatform.android, const Size(412, 915), 'android');
  });
  testWidgets('golden: Android tablet, medium', (tester) async {
    await shot(
      tester,
      TargetPlatform.android,
      const Size(800, 1280),
      'android_tablet',
    );
  });
  testWidgets('golden: Mac', (tester) async {
    await shot(tester, TargetPlatform.macOS, const Size(1280, 800), 'mac');
  });
}
