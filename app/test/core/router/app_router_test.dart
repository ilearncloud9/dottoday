import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

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
  // bootstrap() loads it in the app; real screens (Search) need it.
  setUpAll(tz_data.initializeTimeZones);

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
      'route:day:2026-10-20',
    );
    // Week and Month on a date or month, the Workspace's 3 days (M19.2)
    // and /now, a place not built yet (owner, M18.7 part 3).
    await _goAndExpect(tester, router, '/week/2026-10-20', 'route:week');
    await _goAndExpect(tester, router, '/month/2026-10', 'route:month');
    await _goAndExpect(tester, router, '/now', 'route:today');
    await _goAndExpect(
      tester,
      router,
      '/3-days/2026-10-20',
      'route:3-days:2026-10-20',
    );
    router.go('/settings/privacy');
    await tester.pumpAndSettle();
    expect(find.text('Privacy'), findsOneWidget, reason: 'M3f.7 sub-page');
  });

  testWidgets('off-allow-list locations land on /today', (tester) async {
    final router = await _pump(tester);
    for (final bad in [
      '/admin',
      '/day/2026-02-30',
      '/task/x',
      '/month/2026-13',
    ]) {
      await _goAndExpect(tester, router, '/inbox', 'route:inbox');
      await _goAndExpect(tester, router, bad, 'route:today');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/today',
        reason: bad,
      );
    }
  });

  // M5.0: iOS and Android hand the router the whole link, scheme and all;
  // macOS's DeepLinkBridge does the same.
  testWidgets('a pushed dottoday:// link opens its screen', (tester) async {
    final router = await _pump(tester);
    for (final (link, key) in [
      // No task place here: a task link opens Today.
      ('dottoday://task/$_v7', 'route:today'),
      ('dottoday://inbox', 'route:inbox'),
      ('dottoday://day/2026-10-20', 'route:day:2026-10-20'),
      ('dottoday://task/not-an-id', 'route:today'),
      ('https://evil.example/task/$_v7', 'route:today'),
    ]) {
      await _pushRoute(tester, link);
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: link);
    }
    expect(router.routeInformationProvider.value.uri.path, '/today');
  });

  // M6.1: the sign-in page's callback is handed over, never routed; any
  // other query is dropped and its path kept (ED-097).
  testWidgets('a sign-in callback goes to the account, shows Account', (
    tester,
  ) async {
    final got = <Uri>[];
    final router = buildRouter(appScreens, onAuthCallback: got.add);
    addTearDown(router.dispose);
    await tester.pumpWidget(testRouterApp(router));
    await _pushRoute(tester, 'dottoday://auth-callback?code=abc');
    expect(got.single.queryParameters['code'], 'abc');
    expect(router.routeInformationProvider.value.uri.path, '/settings/account');
    await _pushRoute(tester, 'dottoday://inbox?code=abc');
    expect(got, hasLength(1));
    expect(router.routeInformationProvider.value.uri.toString(), '/inbox');
  });

  // Rule T (ED-097): a task link opens over its place, replacing the link.
  testWidgets('a task link opens its task over its date, no Back step', (
    tester,
  ) async {
    final router = buildRouter(
      appScreens,
      taskPlace: (id) async => '/day/2026-10-20?task=$id',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(testRouterApp(router, overrides: _withTask()));
    router.go('/task/$_v7');
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/day/2026-10-20?task=$_v7',
    );
    // One page, the day: the link itself left nothing to go Back to.
    expect(router.routerDelegate.currentConfiguration.matches, hasLength(1));
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('a view keeps its ?task=; other queries are dropped', (
    tester,
  ) async {
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(testRouterApp(router, overrides: _withTask()));
    router.go('/inbox?task=$_v7');
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/inbox?task=$_v7',
    );
    router.go('/inbox?q=1&task=$_v7');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.toString(), '/inbox');
    router.go('/settings?task=$_v7');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.toString(), '/settings');
  });

  // M9.2c: the Add task shortcut opens Quick Add over Today; `/add` is
  // never a screen of its own.
  testWidgets('dottoday://add shows Today and asks for Quick Add', (
    tester,
  ) async {
    var adds = 0;
    final router = buildRouter(appScreens, onAdd: () => adds++);
    addTearDown(router.dispose);
    await tester.pumpWidget(testRouterApp(router));
    await _pushRoute(tester, 'dottoday://add');
    expect(adds, 1);
    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.byKey(const ValueKey('route:today')), findsOneWidget);
  });
}

Future<void> _pushRoute(WidgetTester tester, String location) async {
  final message = const JSONMethodCodec().encodeMethodCall(
    MethodCall('pushRouteInformation', {'location': location, 'state': null}),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    message,
    (_) {},
  );
  await tester.pumpAndSettle();
}

/// The timeline with one task whose id is [_v7], so its link opens it
/// (an unknown id opens Today, D2).
List<Override> _withTask() {
  final rows = demoDayRows(DateTime(2026, 10, 20));
  return timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 11),
    occurrences: FakeOccurrenceRepository([
      rows.first.copyWith(id: _v7),
      ...rows.skip(1),
    ]),
  );
}
