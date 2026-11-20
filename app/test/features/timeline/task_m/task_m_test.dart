import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/task_d/task_d_sheet.dart';
import 'package:dottoday/features/timeline/task_m/task_m_screen.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Minimal's task screen (ED-089, ED-216; M19.6 part 6d-1): on phones the
/// sheet with Starts, Duration, Done, Tomorrow · Later, Need more time?
/// and More options (option D); on the Mac and web it opens in the Day
/// column instead of the side panel, and Esc brings the Day back.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);
  const deep = '0192f000-0000-7000-8000-00000000d001';
  const lunch = '0192f000-0000-7000-8000-00000000d002';

  Occurrence task(String id, String title, int h, int min) =>
      occurrenceFixture().copyWith(
        id: id,
        title: title,
        startUtc: at(h),
        tzId: 'Europe/Berlin',
        durationMin: min,
        status: OccurrenceStatus.planned,
      );

  // Deep work 10–noon (running at 10:42), Lunch at 1 PM, Berlin.
  Future<(GoRouter, FakeOccurrenceRepository)> pump(
    WidgetTester tester,
    String place, {
    Size size = const Size(390, 844),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final rows = FakeOccurrenceRepository([
      task(deep, 'Deep work', 9, 120),
      task(lunch, 'Lunch', 12, 45),
    ]);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: at(9, 42),
          occurrences: rows,
          profile: testProfile(
            settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go(place);
    await tester.pumpAndSettle();
    return (router, rows);
  }

  testWidgets('phones: the running task, every decision on one screen', (
    tester,
  ) async {
    await pump(tester, AppRoutes.withTask(AppRoutes.today, deep));
    expect(find.byType(TaskMScreen), findsOneWidget);
    for (final s in [
      'Starts',
      'Duration',
      'Done',
      'Tomorrow',
      'Later',
      'Need more time?',
      '+15 min',
      'More options',
      'Delete task',
    ]) {
      expect(find.text(s), findsWidgets, reason: s);
    }
    expect(find.text('Now, 78 min left'), findsWidgets);
    await expectA11yGuidelines(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('phones: a task ahead has no Need more time?', (tester) async {
    await pump(tester, AppRoutes.withTask(AppRoutes.today, lunch));
    expect(find.byType(TaskMScreen), findsOneWidget);
    expect(find.text('Need more time?'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('+15 min lengthens it, with Undo', (tester) async {
    final (_, rows) = await pump(
      tester,
      AppRoutes.withTask(AppRoutes.today, deep),
    );
    await tester.tap(find.text('+15 min'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
    final row = (await rows.findById(testUserId, deep))!;
    expect(row.durationMin, 135);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('More options opens the full editor (option D)', (tester) async {
    await pump(tester, AppRoutes.withTask(AppRoutes.today, lunch));
    await tester.tap(find.text('More options'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskMScreen), findsNothing);
    expect(find.byType(TaskDBody), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('the Mac: the task opens in the Day column; Esc, the Day', (
    tester,
  ) async {
    await pump(
      tester,
      AppRoutes.withTask(AppRoutes.now, deep),
      size: const Size(1280, 800),
    );
    expect(find.byType(TaskMScreen), findsOneWidget);
    expect(find.byType(TaskEditorPanel), findsNothing, reason: 'no panel');
    expect(find.byType(DayPage), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(TaskMScreen), findsNothing);
    expect(find.byType(DayPage), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('the column: + adds 15 min', (tester) async {
    final (_, rows) = await pump(
      tester,
      AppRoutes.withTask(AppRoutes.now, lunch),
      size: const Size(1280, 800),
    );
    await tester.tap(find.byTooltip('15 min longer'));
    await tester.pumpAndSettle();
    expect((await rows.findById(testUserId, lunch))!.durationMin, 60);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
