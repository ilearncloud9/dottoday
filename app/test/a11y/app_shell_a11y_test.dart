import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/a11y.dart';
import '../support/test_app.dart';
import '../support/timeline_fakes.dart';

/// Compact (bottom bar) and expanded (rail) × light and dark (docs/08 §3).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final size in [const Size(400, 800), const Size(1000, 700)]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('shell + Today meet a11y guidelines ($size, ${mode.name})', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final router = buildRouter(appScreens);
        addTearDown(router.dispose);
        // Today is the start route; render it with the demo day.
        final now = DateTime.utc(2026, 10, 21, 11);
        await tester.pumpWidget(
          ProviderScope(
            overrides: timelineOverrides(
              now: now,
              occurrences: FakeOccurrenceRepository(
                demoDayRows(DateTime(2026, 10, 21)),
              ),
            ),
            child: testRouterApp(router, themeMode: mode),
          ),
        );
        await tester.pumpAndSettle();

        await expectA11yGuidelines(tester);
      });
    }
  }
}
