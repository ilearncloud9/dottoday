import 'dart:async';

import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('opens on today: caption, greeting, day dot, today card', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpToday(tester);
    expect(find.text('WED, OCT 21'), findsOneWidget);
    expect(find.text('Good morning, Kody'), findsOneWidget);
    expect(find.text('Wednesday · Today'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Day \d+ % through$')),
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

  testWidgets('no name: plain greeting', (tester) async {
    await pumpToday(tester, name: null);
    expect(find.text('Good morning'), findsOneWidget);
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
    expect(find.text('Friday'), findsWidgets);
    expect(find.text('FRI, OCT 23'), findsOneWidget);
  });

  testWidgets('swiping the pager changes the day', (tester) async {
    await pumpToday(tester);
    await tester.fling(find.byType(DayCard).at(1), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('THU, OCT 22'), findsOneWidget);
  });

  testWidgets('/day/:date opens that day', (tester) async {
    await pumpToday(tester, date: DateTime(2026, 12, 14));
    expect(find.text('MON, DEC 14'), findsOneWidget);
    expect(find.text('Monday, December 14'), findsWidgets);
  });

  testWidgets('the caption chevron and the strip handle open the month', (
    tester,
  ) async {
    await pumpToday(tester);
    await tester.tap(find.text('WED, OCT 21'));
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
    expect(find.byType(WeekStrip), findsNothing);
    await tester.tap(find.bySemanticsLabel('Hide month').last);
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsNothing);
    await tester.drag(find.byType(PullHandle), const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
  });

  testWidgets('month: data dots, footer, Today link; nav to another month', (
    tester,
  ) async {
    await pumpToday(tester, size: const Size(390, 1000));
    await tester.tap(find.text('WED, OCT 21'));
    await tester.pumpAndSettle();
    expect(find.text('October · 1 of 31 days planned'), findsOneWidget);
    expect(find.text('Sep · Oct · Nov'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Wednesday, October 21, \d+ of 13 done$')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
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
    expect(find.text('WED, OCT 21'), findsOneWidget);
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
    await tester.tap(find.text('WED, OCT 21'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(MonthGrid), findsOneWidget);
    // No AnimatedSize at all: a zero-duration one asserts during layout.
    expect(find.byType(AnimatedSize), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('done, live and shift (M3b.3)', () {
    testWidgets('a dot marks done with Undo', (tester) async {
      await pumpToday(tester);
      await tester.tap(find.bySemanticsLabel('Team standup, not done'));
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
      expect(find.text('98 min left'), findsOneWidget);
      ticks.add(todayTestNow.add(const Duration(minutes: 1)));
      await tester.pumpAndSettle();
      expect(find.text('97 min left'), findsOneWidget);
    });

    testWidgets('+15 min extends the live task, with Undo', (tester) async {
      await pumpToday(tester, size: const Size(390, 1200));
      await tester.tap(find.text('+15 min'));
      await tester.pumpAndSettle();
      expect(
        find.text('Deep work: roadmap now ends at 11:15 AM'),
        findsOneWidget,
      );
      expect(find.text('9:00 AM – 11:15 AM · 2 h 15'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('9:00 AM – 11:00 AM · 2 h'), findsOneWidget);
    });

    testWidgets('Shift the rest moves later tasks up to the pinned one', (
      tester,
    ) async {
      await pumpToday(tester, size: const Size(390, 1400));
      // Design review (10:30) sits 30 min inside Deep work (until 11:00).
      await tester.tap(find.text('Shift the rest'));
      await tester.pumpAndSettle();
      expect(
        find.text('Moved 2 tasks · stopped at Lunch with Sam (pinned)'),
        findsOneWidget,
      );
      expect(find.text('11:00 AM – 11:45 AM'), findsOneWidget);
      expect(find.text('12:00 PM – 12:30 PM'), findsOneWidget);
    });

    testWidgets('Shift the rest is off when nothing overlaps', (tester) async {
      final rows = [
        for (final o in demoDayRows(todayTestDate))
          if (o.title != 'Design review') o,
      ];
      await pumpToday(tester, rows: rows, size: const Size(390, 1200));
      final shift = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Shift the rest'),
      );
      expect(shift.onPressed, isNull);
    });
  });

  testWidgets('an empty day says what to do', (tester) async {
    await pumpToday(tester, rows: const []);
    expect(
      find.text('Nothing planned · pull the strip to plan or tap +'),
      findsWidgets,
    );
  });

  testWidgets('tapping a dot marks the task done', (tester) async {
    await pumpToday(tester);
    await tester.tap(find.bySemanticsLabel('Team standup, not done'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Team standup, done'), findsOneWidget);
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
