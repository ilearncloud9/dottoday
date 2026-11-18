import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/timeline/widgets/today_top_actions.dart';
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

  testWidgets('opens on today: date title, numbers, Sync', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpToday(tester);
    expect(
      find.textContaining('Wed, Oct 21', findRichText: true),
      findsOneWidget,
    );
    // The day's numbers sit under the title (E-Phones, ED-040).
    expect(find.textContaining(RegExp(r'^\d+ of \d+ done · ')), findsOneWidget);
    // Sync in the top row says its state in words (R-08); no day dot.
    expect(find.bySemanticsLabel('Sync'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Day \d+ % through')), findsNothing);
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
      find.textContaining('Fri, Oct 23', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('swiping the pager changes the day', (tester) async {
    await pumpToday(tester);
    await tester.fling(find.byType(DayCard).first, const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Thu, Oct 22', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('/day/:date opens that day', (tester) async {
    await pumpToday(tester, date: DateTime(2026, 12, 14));
    expect(
      find.textContaining('Mon, Dec 14', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('/day/<today> is today: no Today pill', (tester) async {
    await pumpToday(tester, date: parseRouteDate('2026-10-21'));
    expect(
      find.textContaining('Wed, Oct 21', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(TodayBack), findsNothing);
  });

  testWidgets('/day/:date past the pager\'s reach opens today', (tester) async {
    await pumpToday(tester, date: parseRouteDate('2028-01-01'));
    expect(
      find.textContaining('Wed, Oct 21', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(DayCard), findsWidgets);
  });

  testWidgets('the title and a pull on the strip open the month', (
    tester,
  ) async {
    await pumpToday(tester);
    await tester.tap(find.textContaining('Wed, Oct 21', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
    expect(find.byType(WeekStrip), findsNothing);
    // The month's own handle closes it; pulling the strip down opens it
    // again (E-Phones: no handle on the day).
    await tester.tap(find.byType(PullHandle).first);
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsNothing);
    expect(find.byType(PullHandle), findsNothing);
    await tester.fling(find.byType(WeekStrip), const Offset(0, 120), 800);
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
  });

  testWidgets('month: data dots, footer, Today link; nav to another month', (
    tester,
  ) async {
    await pumpToday(tester, size: const Size(390, 1000));
    await tester.tap(find.textContaining('Wed, Oct 21', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('October · 1 of 31 days planned'), findsOneWidget);
    expect(find.text('Sep · Oct · Nov'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Wednesday, October 21, \d+ of 13 done$')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nov 2026', findRichText: true), findsOneWidget);
    expect(find.text('Oct · Nov · Dec'), findsOneWidget);
  });

  testWidgets('a future free day: ‹ Today and the empty day in the thread', (
    tester,
  ) async {
    await pumpToday(
      tester,
      date: DateTime(2026, 12, 14),
      size: const Size(390, 1000),
    );
    expect(find.byType(TodayBack), findsOneWidget);
    // 7:00 AM to 10:00 PM, all free.
    expect(find.text('15 h free'), findsOneWidget);
    expect(find.text('Add a task'), findsOneWidget);
    expect(find.text('Drop a routine'), findsOneWidget);
    expect(find.text('Copy a day…'), findsOneWidget);
    await tester.tap(find.byType(TodayBack));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Wed, Oct 21', findRichText: true),
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
    expect(find.text('Add a task'), findsWidgets);
  });

  testWidgets('reduced motion: the month opens without animating', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpToday(tester);
    await tester.tap(find.textContaining('Wed, Oct 21', findRichText: true));
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

  testWidgets('an empty day says what to do, in its free time', (tester) async {
    await pumpToday(tester, rows: const [], size: const Size(390, 1000));
    expect(
      find.text(
        'A clear day. Add what matters, drop in a routine, '
        'or bring something over from your Inbox.',
      ),
      findsOneWidget,
    );
    expect(find.text('Add a task'), findsOneWidget);
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

    testWidgets('"Add a task" opens Add on that day', (tester) async {
      final asked = <AddTaskIntent>[];
      await pumpToday(
        tester,
        date: DateTime(2026, 10, 24),
        size: const Size(390, 1000),
        onAddTask: asked.add,
      );
      final add = find.text('Add a task').hitTestable();
      await tester.ensureVisible(add.first);
      await tester.tap(add.first);
      await tester.pump();
      expect(asked.single.day, DateTime(2026, 10, 24));
    });
  });
}
