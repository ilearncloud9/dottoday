import 'package:dottoday/core/router/phone_week.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Phones have no Week (Concept E): their /week opens Today on that date
/// (M19.1); wider windows keep the Week.
void main() {
  Future<GoRouter> pump(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/week',
      routes: [
        GoRoute(
          path: '/week',
          builder: (_, _) => const PhoneWeek(
            to: '/day/2026-10-23',
            child: Text('week'), // l10n-ignore: test fixture
          ),
        ),
        GoRoute(
          path: '/day/:date',
          builder: (_, _) => const Text('day'), // l10n-ignore: test fixture
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('a phone goes to the day', (tester) async {
    final router = await pump(tester, const Size(390, 844));
    expect(find.text('day'), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/day/2026-10-23',
    );
  });

  testWidgets('a wide window keeps the Week', (tester) async {
    await pump(tester, const Size(1280, 800));
    expect(find.text('week'), findsOneWidget);
  });
}
