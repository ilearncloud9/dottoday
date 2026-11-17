import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/today_harness.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('opens on today: date title, day dot, numbers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpToday(tester);
    expect(
      find.textContaining('October 21, 2026', findRichText: true),
      findsOneWidget,
    );
    // The day's numbers sit under the title (ADR-0015).
    expect(find.textContaining(RegExp(r'^\d+ of \d+ · ')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Day \d+ % through')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'Deep work: roadmap, live, \d+ minutes left'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('the week starts on the profile setting', (tester) async {
    await pumpToday(tester, firstDayOfWeek: 1);
    final mon = tester.getCenter(find.text('Mon')).dx;
    final sun = tester.getCenter(find.text('Sun')).dx;
    expect(mon, lessThan(sun));
    expect(weekStart(DateTime(2026, 10, 21), 1), DateTime(2026, 10, 19));
    expect(weekStart(DateTime(2026, 10, 21), 7), DateTime(2026, 10, 18));
  });

  testWidgets('a strip tap pages to that day; the header follows', (
    tester,
  ) async {
    await pumpToday(tester);
    await tester.tap(find.text('Fri'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('October 23, 2026', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('swiping the pager changes the day', (tester) async {
    await pumpToday(tester);
    await tester.fling(find.byType(DayCard).first, const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('October 22, 2026', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('/day/:date opens that day', (tester) async {
    await pumpToday(tester, date: DateTime(2026, 12, 14));
    expect(
      find.textContaining('December 14, 2026', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('/day/<today> is today: no Today pill', (tester) async {
    await pumpToday(tester, date: parseRouteDate('2026-10-21'));
    expect(
      find.textContaining('October 21, 2026', findRichText: true),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Today'), findsNothing);
  });

  testWidgets('/day/:date past the pager\'s reach opens today', (tester) async {
    await pumpToday(tester, date: parseRouteDate('2028-01-01'));
    expect(
      find.textContaining('October 21, 2026', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(DayCard), findsWidgets);
  });

  testWidgets('the caption chevron and the strip handle open the month', (
    tester,
  ) async {
    await pumpToday(tester);
    await tester.tap(
      find.textContaining('October 21, 2026', findRichText: true),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
    expect(find.byType(WeekStrip), findsNothing);
    // The month's own handle, then the one on the day sheet (ADR-0015).
    await tester.tap(find.byType(PullHandle).first);
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsNothing);
    await tester.drag(find.byType(PullHandle).first, const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
  });

  testWidgets('month: data dots, footer, Today link; nav to another month', (
    tester,
  ) async {
    await pumpToday(tester, size: const Size(390, 1000));
    await tester.tap(
      find.textContaining('October 21, 2026', findRichText: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('October · 1 of 31 days planned'), findsOneWidget);
    expect(find.text('Sep · Oct · Nov'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Wednesday, October 21, \d+ of 13 done$')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('November 2026', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Oct · Nov · Dec'), findsOneWidget);
  });

  testWidgets('a future free day: Today pill and the empty-day actions', (
    tester,
  ) async {
    await pumpToday(
      tester,
      date: DateTime(2026, 12, 14),
      size: const Size(390, 1000),
    );
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Add to this day'), findsWidgets);
    expect(find.text('Copy a day…'), findsWidgets);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('October 21, 2026', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('Copy a day copies the picked day’s one-offs, with Undo', (
    tester,
  ) async {
    await pumpToday(
      tester,
      date: DateTime(2026, 10, 24),
      size: const Size(390, 1000),
    );
    final copy = find.text('Copy a day…').hitTestable();
    await tester.ensureVisible(copy.first);
    await tester.tap(copy.first);
    await tester.pumpAndSettle();
    expect(find.text('Copy which day?'), findsOneWidget);
    await tester.tap(
      find.descendant(of: find.byType(BottomSheet), matching: find.text('21')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Copied 12 tasks'), findsOneWidget);
    expect(find.text('Morning run'), findsWidgets);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Add to this day'), findsWidgets);
  });

  testWidgets('reduced motion: the month opens without animating', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpToday(tester);
    await tester.tap(
      find.textContaining('October 21, 2026', findRichText: true),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(MonthGrid), findsOneWidget);
    // No AnimatedSize at all: a zero-duration one asserts during layout.
    expect(find.byType(AnimatedSize), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('done and live (M3b.3)', () {
    testWidgets('the done circle marks done with Undo', (tester) async {
      await pumpToday(tester);
      await tester.tap(find.bySemanticsLabel('Team standup'));
      await tester.pumpAndSettle();
      expect(find.text('Team standup done'), findsOneWidget);
      expect(find.bySemanticsLabel('Team standup, done'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Team standup, not done'), findsOneWidget);
    });

    testWidgets('minutes left follow the minute tick', (tester) async {
      final ticks = StreamController<DateTime>();
      addTearDown(ticks.close);
      await pumpToday(tester, ticks: ticks.stream);
      ticks.add(todayTestNow);
      await tester.pumpAndSettle();
      // On the now card's time line (E rules §5.3).
      Finder left(int m) =>
          find.textContaining('Now, $m min left', findRichText: true);
      expect(left(98), findsOneWidget);
      ticks.add(todayTestNow.add(const Duration(minutes: 1)));
      await tester.pumpAndSettle();
      expect(left(97), findsOneWidget);
    });

    // +15 min and Shift the rest left the now card (M18.3, E-Phones
    // Today): the task sheet carries them and its tests cover them.
  });

  testWidgets('an empty day says what to do', (tester) async {
    await pumpToday(tester, rows: const []);
    expect(
      find.text('Nothing planned · pull the strip to plan or tap +'),
      findsWidgets,
    );
  });

  testWidgets('the dot opens the task; the circle ticks it in place '
      '(ADR-0015)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpToday(tester);
    await tester.tap(find.bySemanticsLabel('Team standup, not done'));
    await tester.pumpAndSettle();
    // Opening never ticks it.
    expect(find.bySemanticsLabel('Team standup, not done'), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Team standup'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Team standup, done'), findsOneWidget);
    // The circle stays, checked, so the same tap undoes it.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Team standup')),
      matchesSemantics(
        label: 'Team standup',
        isButton: true,
        hasCheckedState: true,
        isChecked: true,
        hasTapAction: true,
        onTapHint: 'Mark not done',
      ),
    );
    handle.dispose();
  });

  for (final (name, size) in [
    ('compact', const Size(390, 844)),
    ('expanded', const Size(1280, 800)),
  ]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('meets a11y guidelines ($name, ${mode.name})', (
        tester,
      ) async {
        await pumpToday(tester, size: size, mode: mode);
        await expectA11yGuidelines(tester);
      });
    }
  }

  group('add here (M3c.5, R-17)', () {
    testWidgets('a free gap opens Add at its start', (tester) async {
      final asked = <AddTaskIntent>[];
      // Tall enough that the lazy thread builds the 11:15 gap.
      await pumpToday(
        tester,
        size: const Size(390, 1600),
        onAddTask: asked.add,
      );
      // Design review ends 11:15, Reply to email starts 11:30.
      final gap = find.text('15 min free · add here').hitTestable();
      await tester.ensureVisible(gap.first);
      await tester.tap(gap.first);
      await tester.pump();
      expect(asked.single.startUtc, DateTime.utc(2026, 10, 21, 9, 15));
    });

    testWidgets('"Add to this day" opens Add on that day', (tester) async {
      final asked = <AddTaskIntent>[];
      await pumpToday(
        tester,
        date: DateTime(2026, 10, 24),
        size: const Size(390, 1000),
        onAddTask: asked.add,
      );
      final add = find.text('Add to this day').hitTestable();
      await tester.ensureVisible(add.first);
      await tester.tap(add.first);
      await tester.pump();
      expect(asked.single.day, DateTime(2026, 10, 24));
    });
  });
}
