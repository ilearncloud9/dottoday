import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/test_app.dart';

const _v7 = '01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f90';

Future<GoRouter> _pump(WidgetTester tester) async {
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(testRouterApp(router));
  return router;
}

Future<void> _goAndExpect(
  WidgetTester tester,
  GoRouter router,
  String location,
  String key,
) async {
  router.go(location);
  await tester.pumpAndSettle();
  expect(find.byKey(ValueKey(key)), findsOneWidget, reason: location);
}

void main() {
  testWidgets('starts on /today', (tester) async {
    await _pump(tester);
    expect(find.byKey(const ValueKey('route:today')), findsOneWidget);
  });

  testWidgets('every route resolves to its screen', (tester) async {
    final router = await _pump(tester);
    const statics = ['inbox', 'week', 'search', 'settings', 'month', 'today'];
    for (final name in statics) {
      await _goAndExpect(tester, router, '/$name', 'route:$name');
    }
    await _goAndExpect(
      tester,
      router,
      '/day/2026-10-20',
      'route:day:2026-10-20T00:00:00.000Z',
    );
    await _goAndExpect(tester, router, '/task/$_v7', 'route:task:$_v7');
  });

  testWidgets('off-allow-list locations land on /today', (tester) async {
    final router = await _pump(tester);
    for (final bad in ['/admin', '/day/2026-02-30', '/task/x', '/inbox?q=1']) {
      await _goAndExpect(tester, router, '/inbox', 'route:inbox');
      await _goAndExpect(tester, router, bad, 'route:today');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/today',
        reason: bad,
      );
    }
  });
}
