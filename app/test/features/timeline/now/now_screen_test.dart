import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/shared/dot/done_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Minimal's Now on phones (E-PhonesMinimal frames 1, 4, 5; E-R2-26;
/// ED-329; M19.6 part 6b): Minimal opens on it; the horizon opens Today;
/// running, between tasks, an open day and the day's end.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  // Tue 3 Nov 2026, Berlin is UTC+1.
  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

  Occurrence task(String id, int h, int minutes, [int m = 0]) =>
      occurrenceFixture().copyWith(
        id: id,
        title: id,
        startUtc: at(h, m),
        tzId: 'Europe/Berlin',
        durationMin: minutes,
        status: OccurrenceStatus.planned,
      );

  // 10–12, 10:30–11:30 and 13:00–13:45 Berlin; Wind Down at 10 PM.
  final day = [
    task('Deep work', 9, 120),
    task('Call', 9, 60, 30),
    task('Lunch', 12, 45),
  ];

  Future<GoRouter> pump(
    WidgetTester tester,
    DateTime now, {
    List<Occurrence>? blocks,
    UiLayout layout = UiLayout.minimal,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: now,
          occurrences: FakeOccurrenceRepository(blocks ?? day),
          profile: testProfile(
            settings: Settings(uiLayout: layout, use24h: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  String where(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

  testWidgets('Minimal opens on Now; Full on Today', (tester) async {
    expect(where(await pump(tester, at(9, 42))), '/now');
    await tester.pumpWidget(const SizedBox());
    final full = await pump(tester, at(9, 42), layout: UiLayout.full);
    expect(where(full), '/today');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('running: the orb, Done, Need more time?, Also now, Next', (
    tester,
  ) async {
    await pump(tester, at(9, 42));
    expect(find.text('Now 10:42 AM · Wind Down at 10:00 PM'), findsOneWidget);
    expect(find.bySemanticsLabel('Deep work, 78 min left'), findsOneWidget);
    expect(find.text('10:00 AM–12:00 PM'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Need more time?'), findsOneWidget);
    expect(find.text('Also now'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    await expectA11yGuidelines(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Done marks the task done, with Undo', (tester) async {
    await pump(tester, at(9, 42));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
    // The call, begun later, now leads.
    expect(find.bySemanticsLabel('Call, 48 min left'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('between tasks: Next up with the free time', (tester) async {
    await pump(tester, at(11, 15));
    expect(find.text('NEXT UP'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('1:00 PM–1:45 PM'), findsOneWidget);
    expect(find.textContaining('45 min'), findsOneWidget);
    // Both ended unticked: Earlier, "· not done", each with its circle.
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.text('· not done'), findsNWidgets(2));
    await tester.ensureVisible(find.byType(DoneCircle).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DoneCircle).last);
    await tester.pumpAndSettle();
    expect(find.text('· not done'), findsOneWidget, reason: 'ticked off');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('an open day: the hours free and Add to the day', (tester) async {
    await pump(tester, at(9, 42), blocks: const []);
    expect(find.text('An open day'), findsOneWidget);
    expect(find.text('Free until Wind Down at 10:00 PM.'), findsOneWidget);
    expect(find.text('Add to the day'), findsOneWidget);
    await expectA11yGuidelines(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the day done: Nothing else today', (tester) async {
    await pump(tester, at(15));
    expect(find.text('Nothing else today'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('the horizon opens Today', (tester) async {
    final router = await pump(tester, at(9, 42));
    await tester.tap(find.bySemanticsLabel(RegExp('^Day horizon')));
    await tester.pumpAndSettle();
    expect(where(router), '/today');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
