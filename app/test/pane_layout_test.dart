import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/timeline_fakes.dart';

// Search and Settings in the main pane (docs/09 M3e.7): beside the rail
// at medium and expanded, one readable column centred in the pane.

Future<void> _pump(WidgetTester tester, double width, String route) async {
  tester.view
    ..physicalSize = Size(width, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWithValue(router),
        ...timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 9),
          occurrences: FakeOccurrenceRepository(),
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
      ],
      child: const DottodayApp(),
    ),
  );
  await tester.pumpAndSettle();
  router.go(route);
  await tester.pumpAndSettle();
}

/// [finder]'s width, and how far its centre is from the pane's (the
/// window right of the rail).
(double, double) _measure(WidgetTester tester, Finder finder, double width) {
  final rect = tester.getRect(finder);
  final rail = tester.getRect(find.text('Today').first).right;
  final pane = (rail + width) / 2;
  return (rect.width, (rect.center.dx - pane).abs());
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final width in [700.0, 1280.0]) {
    testWidgets('$width: Search is one centred column beside the rail', (
      tester,
    ) async {
      await _pump(tester, width, '/search');
      final (w, off) = _measure(tester, find.byType(TextField), width);
      expect(w, lessThanOrEqualTo(DotSize.readableColumn));
      expect(off, lessThan(DotSpace.page * 2));
    });

    testWidgets('$width: Settings is one centred column beside the rail', (
      tester,
    ) async {
      await _pump(tester, width, '/settings');
      final (w, off) = _measure(
        tester,
        find.byType(SettingsGroup).first,
        width,
      );
      expect(w, lessThanOrEqualTo(DotSize.readableColumn));
      expect(off, lessThan(DotSpace.page * 2));
    });
  }
}
