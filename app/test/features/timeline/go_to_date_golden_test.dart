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

import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// Go to date (E-R2-36, ED-342; M19.5 part 5c): the Mac's popover under
/// the date button, light and dark; the iPad's popover; Android tablets'
/// dialog.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> shot(
    WidgetTester tester,
    TargetPlatform p,
    ThemeMode mode,
    Size size,
    String name,
  ) async {
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
            ),
            siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
          ],
        ),
      );
      await tester.pumpAndSettle();
      router.go('/day/2026-10-23');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Oct 23, 2026').hitTestable().first);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/go_to_date_$name.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('golden: Mac popover, ${mode.name}', (tester) async {
      await shot(
        tester,
        TargetPlatform.macOS,
        mode,
        const Size(1280, 800),
        'mac_${mode.name}',
      );
    });
  }
  testWidgets('golden: iPad popover, light', (tester) async {
    await shot(
      tester,
      TargetPlatform.iOS,
      ThemeMode.light,
      const Size(1180, 820),
      'ipad_light',
    );
  });
  testWidgets('golden: Android tablet dialog, light', (tester) async {
    await shot(
      tester,
      TargetPlatform.android,
      ThemeMode.light,
      const Size(1280, 800),
      'android_light',
    );
  });
}
