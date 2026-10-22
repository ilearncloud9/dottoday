import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/sample_search.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a result opens its task page (/task/:id)', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: searchNow,
          occurrences: FakeOccurrenceRepository(sampleSearchRows()),
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
      ),
    );
    router.go(AppRoutes.search);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'one-pager');
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('one-pager', findRichText: true).last);
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey('route:task:0199f0b0-0000-7000-8000-000000000002'),
      ),
      findsOneWidget,
    );
  });
}
