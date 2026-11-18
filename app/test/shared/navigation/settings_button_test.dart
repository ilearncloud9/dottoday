import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// ED-238: on phones Settings opens from the profile in the top row, and
/// its Back returns to the screen it was opened from.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<GoRouter> pump(WidgetTester tester, String start) async {
    tester.view
      ..physicalSize = const Size(390, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 7, 22),
          occurrences: FakeOccurrenceRepository(
            demoDayRows(DateTime(2026, 10, 21)),
          ),
          profile: testProfile(
            settings: const Settings(use24h: false),
          ).copyWith(displayName: 'Kody'),
        ),
      ),
    );
    router.go(start);
    await tester.pumpAndSettle();
    return router;
  }

  String address(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  testWidgets('the profile opens Settings; Back returns to the same day', (
    tester,
  ) async {
    final router = await pump(tester, '/day/2026-10-23');
    final button = find.bySemanticsLabel('Settings and account');
    expect(button, findsOneWidget);
    // 44 pt on iPhone, 48 dp elsewhere.
    expect(tester.getSize(button).shortestSide, greaterThanOrEqualTo(44));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(address(router), '/settings');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(address(router), '/day/2026-10-23');
  });

  testWidgets('wider windows have no profile button: Settings is at the '
      'foot of the rail or sidebar', (tester) async {
    tester.view
      ..physicalSize = const Size(1280, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 7, 22),
          profile: testProfile(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Settings and account'), findsNothing);
    expect(find.text('Settings'), findsWidgets);
  });
}
