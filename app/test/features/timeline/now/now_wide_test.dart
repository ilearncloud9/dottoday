import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/now/wide/day_column.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/dot/day_horizon.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Mac and web Now pane beside the Day column (E-Minimal frames 1 and
/// 2, ED-232; M19.6 part 6c): the orb, Done · Focus · Need more time?,
/// "· 4 more"; the Day column with ✕ and ⌥⌘I; a horizon dot's
/// right-click menu; medium widths keep the day until 6e.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  // Tue 3 Nov 2026, Berlin is UTC+1; Wake Up 7 AM, Wind Down 10 PM.
  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

  Occurrence task(String id, int h, int min) => occurrenceFixture().copyWith(
    id: id,
    title: id,
    startUtc: at(h),
    tzId: 'Europe/Berlin',
    durationMin: min,
    status: OccurrenceStatus.planned,
  );

  // 10 AM–noon, then Lunch, Gym and Read.
  final day = [
    task('Deep work', 9, 120),
    task('Lunch', 12, 45),
    task('Gym', 17, 60),
    task('Read', 20, 30),
  ];

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    // The Flutter menu stands in where the native one isn't there.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dottoday/context_menu'),
      (_) => throw MissingPluginException(),
    );
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
  }

  testWidgets('the pane: the orb, the three actions and "· 4 more"', (
    tester,
  ) async {
    await pump(tester);
    expect(find.bySemanticsLabel('Deep work, 78 min left'), findsOneWidget);
    for (final a in ['Done', 'Focus', 'Need more time?']) {
      expect(find.text(a), findsOneWidget, reason: a);
    }
    expect(find.textContaining('· 2 more'), findsOneWidget);
    expect(find.byType(DayColumn), findsOneWidget);
    await expectA11yGuidelines(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('✕ hides the Day column; Show Day Column brings it back', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byTooltip('Hide the Day column'));
    await tester.pumpAndSettle();
    expect(find.byType(DayColumn), findsNothing);
    await tester.tap(find.text('Show Day Column'));
    await tester.pumpAndSettle();
    expect(find.byType(DayColumn), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('⌥⌘I hides and shows the Day column in Minimal', (tester) async {
    await pump(tester);
    Future<void> toggle() async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();
    }

    await toggle();
    expect(find.byType(DayColumn), findsNothing);
    await toggle();
    expect(find.byType(DayColumn), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets("a right-click on a horizon dot: the task's menu", (
    tester,
  ) async {
    await pump(tester);
    // Lunch, 1 PM: 6 of the waking day's 15 hours along the line.
    final r = tester.getRect(find.byType(DayHorizon));
    const cap = 8.0;
    final x = r.left + cap + (6 / 15) * (r.width - 2 * cap);
    await tester.tapAt(
      Offset(x, r.top + cap),
      buttons: kSecondaryMouseButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    for (final e in ['Open', 'Mark Done', 'Move To…', 'Duplicate']) {
      expect(find.text(e), findsOneWidget, reason: e);
    }
    await tester.tap(find.text('Mark Done'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('a medium window keeps the day until 6e', (tester) async {
    await pump(tester, size: const Size(800, 1000));
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(DayColumn), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
