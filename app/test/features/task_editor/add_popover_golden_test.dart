@Tags(['golden'])
library;

import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/features/task_editor/add/popover/add_popover.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/routine_samples.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// The Mac and web Add popover (E-R2-36, ED-342; M19.3 part 3b) over the
/// Workspace: just opened, typing with live chips, an overlap and a pasted
/// list on the Mac; the web's Add n button; light and dark.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester,
    ThemeMode mode, {
    String place = '/week/2026-10-21',
    String typed = '',
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
        onQuickAdd: () => openQuickAdd(router),
        overrides: timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 8),
          occurrences: FakeOccurrenceRepository(
            demoDayRows(DateTime(2026, 10, 21)),
          ),
          routines: sampleRoutines(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go(place);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add a task').hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(AddPopover), findsOneWidget);
    if (typed.isNotEmpty) {
      await tester.enterText(
        find.descendant(
          of: find.byType(AddPopover),
          matching: find.byType(EditableText),
        ),
        typed,
      );
      await tester.pumpAndSettle();
    }
  }

  Future<void> on(TargetPlatform p, Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = p;
    // Real shadows, as dot_golden draws them: flutter_test's are hard
    // edges. Restored in the body, before flutter_test checks the flag.
    debugDisableShadows = false;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
      debugDisableShadows = true;
    }
  }

  final cases = {
    'open': '',
    'chips': 'Gym tomorrow 6pm 45m',
    'overlap': 'Call Mum 9am',
    'paste': 'Email Sam\nTaxes 45m\nCall the bank 4pm',
  };
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final m = mode.name;
    for (final MapEntry(key: name, value: typed) in cases.entries) {
      testWidgets('golden: Mac Add popover, $name, $m', (tester) async {
        await on(TargetPlatform.macOS, () async {
          await pump(tester, mode, typed: typed);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/add_popover_${name}_mac_$m.png'),
          );
        });
      });
    }
    // A mouse-driven browser: the toolbar's Add n (Windows stands in for
    // the web's pointer layout in tests; kIsWeb can't be set).
    testWidgets('golden: web Add popover on Day, $m', (tester) async {
      await on(TargetPlatform.windows, () async {
        await pump(
          tester,
          mode,
          place: '/today/2026-10-21',
          typed: 'Gym tomorrow 6pm 45m',
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/add_popover_web_day_$m.png'),
        );
      });
    });
  }
}
