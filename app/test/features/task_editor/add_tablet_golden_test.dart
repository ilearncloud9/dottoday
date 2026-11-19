@Tags(['golden'])
library;

import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/routine_samples.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

/// Add on tablets (E-R2-3, ED-271; M19.3 part 3c) over the Workspace at
/// 1180 × 820: the iPad's Create task popover and its hold menu, Android's
/// + menu and New task side sheet; light and dark.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester,
    ThemeMode mode,
    Future<void> Function(Finder plus) act,
  ) async {
    tester.view
      ..physicalSize = const Size(1180, 820)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        themeMode: mode,
        onQuickAdd: () => openQuickAdd(router),
        onAddMode: (m) => openQuickAdd(router, mode: m),
        overrides: [
          ...timelineOverrides(
            now: addNow,
            occurrences: FakeOccurrenceRepository(demoTimed()),
            profile: testProfile(settings: const Settings(use24h: false)),
            routines: sampleRoutines(),
          ),
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go('/week/2026-10-21');
    await tester.pumpAndSettle();
    await act(find.byTooltip('Add a task').hitTestable().first);
    await tester.pumpAndSettle();
  }

  Future<void> on(TargetPlatform p, Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = p;
    // Real shadows, as dot_golden draws them.
    debugDisableShadows = false;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
      debugDisableShadows = true;
    }
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final m = mode.name;
    final cases = <String, (TargetPlatform, bool)>{
      // name: platform, hold
      'ipad': (TargetPlatform.iOS, false),
      'ipad_hold': (TargetPlatform.iOS, true),
      'android_menu': (TargetPlatform.android, false),
    };
    for (final MapEntry(key: name, value: (p, hold)) in cases.entries) {
      testWidgets('golden: tablet Add, $name, $m', (tester) async {
        await on(p, () async {
          await pump(
            tester,
            mode,
            (plus) => hold ? tester.longPress(plus) : tester.tap(plus),
          );
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/add_tablet_${name}_$m.png'),
          );
        });
      });
    }
    testWidgets('golden: tablet Add, android_sheet, $m', (tester) async {
      await on(TargetPlatform.android, () async {
        await pump(tester, mode, (plus) async {
          await tester.tap(plus);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Task').last);
        });
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/add_tablet_android_sheet_$m.png'),
        );
      });
    });
  }
}
