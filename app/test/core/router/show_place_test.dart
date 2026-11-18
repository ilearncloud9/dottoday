import 'package:dottoday/core/router/show_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _v7 = '01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f90';

void main() {
  late GoRouter router;

  Future<void> pump(WidgetTester tester, String start) async {
    router = GoRouter(
      initialLocation: start,
      routes: [
        for (final path in ['/today', '/day/:date'])
          GoRoute(path: path, builder: (_, _) => const SizedBox()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  String address() => router.routerDelegate.currentConfiguration.uri.toString();

  testWidgets('stepping a day keeps the open task (ED-097)', (tester) async {
    await pump(tester, '/today?task=$_v7');
    showPlace(router, '/day/2026-10-22');
    await tester.pumpAndSettle();
    expect(address(), '/day/2026-10-22?task=$_v7');
  });

  testWidgets('the same place again changes nothing', (tester) async {
    await pump(tester, '/day/2026-10-22');
    showPlace(router, '/day/2026-10-22');
    await tester.pumpAndSettle();
    expect(address(), '/day/2026-10-22');
  });
}
