import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/now/wide/day_column.dart';
import 'package:dottoday/features/timeline/now/wide/day_edge.dart';
import 'package:dottoday/features/timeline/task_m/task_m_screen.dart';
import 'package:dottoday/shared/dot/now_orb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Minimal on a narrow Mac (ED-170; M19.6 part 6e-1): the Day column
/// folds below the computed point behind the "Day" edge button, whose
/// panel Esc closes with focus back on the button; the narrow toolbar;
/// the short window's 72 % orb, full size above 130 % text.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);
  const deep = '0192f000-0000-7000-8000-00000000d001';

  final day = [
    occurrenceFixture().copyWith(
      id: deep,
      title: 'Deep work',
      startUtc: at(9),
      tzId: 'Europe/Berlin',
      durationMin: 120,
      status: OccurrenceStatus.planned,
    ),
  ];

  Future<GoRouter> pump(
    WidgetTester tester,
    Size size, {
    double text = 1,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = text;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: at(9, 42),
          occurrences: FakeOccurrenceRepository(day),
          profile: testProfile(
            settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  final summary = find.textContaining('Wind Down at');

  testWidgets('1042 shows the column; 1041 folds it behind "Day"', (
    tester,
  ) async {
    await pump(tester, const Size(1042, 800));
    expect(find.byType(DayColumn), findsOneWidget);
    expect(find.byType(DayEdge), findsNothing);
    tester.view.physicalSize = const Size(1041, 800);
    await tester.pumpAndSettle();
    expect(find.byType(DayColumn), findsNothing);
    expect(find.byType(DayEdge), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('larger text folds it sooner (computed, not fixed)', (
    tester,
  ) async {
    await pump(tester, const Size(1160, 800), text: 1.5);
    expect(find.byType(DayEdge), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('"Day" opens the panel; Esc closes it, focus on "Day"', (
    tester,
  ) async {
    await pump(tester, const Size(840, 640));
    await tester.tap(
      find.descendant(of: find.byType(DayEdge), matching: find.byType(InkWell)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DayColumn), findsOneWidget);
    await expectA11yGuidelines(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(DayColumn), findsNothing);
    final edge = tester.widget<DayEdge>(find.byType(DayEdge));
    expect(edge.focusNode.hasFocus, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('a task opened while folded shows in the panel', (tester) async {
    final router = await pump(tester, const Size(840, 640));
    router.go(AppRoutes.withTask(AppRoutes.now, deep));
    await tester.pumpAndSettle();
    expect(find.byType(TaskMScreen), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('the toolbar narrows below 1000', (tester) async {
    await pump(tester, const Size(1042, 800));
    expect(summary, findsOneWidget);
    tester.view.physicalSize = const Size(999, 800);
    await tester.pumpAndSettle();
    expect(summary, findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('under 720 tall the orb is 72 %; above 130 % text, full', (
    tester,
  ) async {
    double orb() => tester.widget<NowOrb>(find.byType(NowOrb)).size;
    await pump(tester, const Size(1280, 800));
    expect(orb(), 280);
    tester.view.physicalSize = const Size(1280, 719);
    await tester.pumpAndSettle();
    expect(orb(), closeTo(280 * 0.72, 0.01));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    await tester.pumpAndSettle();
    expect(orb(), 280);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
