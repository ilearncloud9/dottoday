import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to /today', (tester) async {
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routerProvider.overrideWithValue(router)],
        child: const DottodayApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('route:today')), findsOneWidget);
  });
}
