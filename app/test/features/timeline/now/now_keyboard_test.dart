import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/now/now_actions.dart';
import 'package:dottoday/features/timeline/now/wide/day_column.dart';
import 'package:dottoday/shared/dot/day_horizon.dart';
import 'package:dottoday/shared/navigation/landing_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Wide Minimal's keyboard paths (ED-248 A, E-DF3): Tab goes sidebar →
/// toolbar → horizon → Now actions → Next, Add, Hide → Day column; the
/// horizon is one stop whose arrows move along the dots and whose Return
/// opens one; an opened task takes focus on its title, and Esc gives
/// focus back to what opened it.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);
  const deep = '0192f000-0000-7000-8000-00000000d001';
  const call = '0192f000-0000-7000-8000-00000000d002';
  const lunch = '0192f000-0000-7000-8000-00000000d003';

  final day = [
    for (final (id, title, h, m, length) in [
      (deep, 'Deep work', 9, 0, 120),
      (call, 'Call with Sam', 11, 30, 30),
      (lunch, 'Lunch', 12, 30, 45),
    ])
      occurrenceFixture().copyWith(
        id: id,
        title: title,
        startUtc: at(h, m),
        tzId: 'Europe/Berlin',
        durationMin: length,
        status: OccurrenceStatus.planned,
      ),
  ];

  Future<void> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
  }

  /// Whether focus is inside the first match of [finder].
  bool focusIn(Finder finder) {
    final target = finder.evaluate().first;
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    if (context == target) return true;
    var inside = false;
    context.visitAncestorElements((e) {
      inside = e == target;
      return !inside;
    });
    return inside;
  }

  Future<void> tab(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
  }

  /// Tabs until focus is inside [finder]; how many presses that took.
  Future<int> tabTo(WidgetTester tester, Finder finder) async {
    for (var i = 1; i <= 60; i++) {
      await tab(tester);
      if (focusIn(finder)) return i;
    }
    fail('Tab never reached $finder');
  }

  final horizon = find.byType(DayHorizon);
  final column = find.byType(DayColumn);

  testWidgets(
    'Tab: horizon, the three actions, Next, Add, Hide, then the Day',
    (tester) async {
      await pump(tester);
      await tabTo(tester, horizon);
      for (final label in ['Done', 'Focus', 'Need more time?']) {
        await tab(tester);
        expect(
          focusIn(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(NowActions),
            ),
          ),
          isTrue,
          reason: label,
        );
      }
      for (final text in ['Next', 'Add a task', 'Hide the Day column']) {
        await tab(tester);
        expect(focusIn(column), isFalse, reason: '$text comes before the Day');
      }
      await tab(tester);
      expect(focusIn(column), isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets('the horizon: arrows and Home/End move, Return opens the dot', (
    tester,
  ) async {
    await pump(tester);
    await tabTo(tester, horizon);
    final h = tester.semantics.find(horizon);
    // It starts on the task under way.
    expect(h.value, startsWith('Deep work'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(tester.semantics.find(horizon).value, startsWith('Call with Sam'));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(tester.semantics.find(horizon).value, startsWith('Lunch'));
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(tester.semantics.find(horizon).value, startsWith('Deep work'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(column));
    expect(container.read(editingTaskProvider), call);
    // Focus lands on the opened task's title.
    expect(focusIn(find.byType(LandingTitle)), isTrue);
    // Esc gives it back to the horizon.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(container.read(editingTaskProvider), isNull);
    expect(focusIn(horizon), isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('a screen reader adjusts the horizon and opens a dot', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    expect(
      tester.semantics.find(horizon),
      isSemantics(
        label: 'Day horizon, 7:00 AM to 10:00 PM, now 10:42 AM',
        value: 'Deep work, 10:00 AM – 12:00 PM',
        increasedValue: 'Call with Sam, 12:30 PM – 1:00 PM',
        hasIncreaseAction: true,
        customActions: [const CustomSemanticsAction(label: 'Open')],
      ),
    );
    tester.binding.renderViews.first.owner!.semanticsOwner!.performAction(
      tester.semantics.find(horizon).id,
      SemanticsAction.increase,
    );
    await tester.pumpAndSettle();
    expect(tester.semantics.find(horizon).value, startsWith('Call with Sam'));
    semantics.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('the Day column: ↓ moves to the next row', (tester) async {
    await pump(tester);
    await tabTo(tester, column);
    // Past the header's Day ▾ and ✕ to the first row.
    await tab(tester);
    await tab(tester);
    final before = FocusManager.instance.primaryFocus;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, isNot(before));
    expect(focusIn(column), isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
