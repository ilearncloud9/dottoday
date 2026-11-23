import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/week/week_board.dart';
import 'package:dottoday/features/timeline/widgets/today_three_days.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:dottoday/shared/sheets/sheet_nav_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// 3 days on the hour grid (E-R2-30, ED-333; M19.2 part 2): yesterday,
// today and tomorrow as Week draws them. Wednesday 21 Oct, 09:22 in
// Berlin.
const _wide = Size(1280, 1400);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('expanded: yesterday, today and tomorrow on the hour grid', (
    tester,
  ) async {
    await pumpToday(tester, size: _wide, threeDays: true);
    expect(find.byType(TodayThreeDays), findsOneWidget);
    expect(find.byType(WeekBoard), findsOneWidget);
    expect(find.byType(DayPager), findsNothing);
    expect(find.text('Good morning, Kody'), findsOneWidget);
    expect(find.text('Tuesday, October 20 · Yesterday'), findsOneWidget);
    expect(find.text('Wednesday, October 21 · Today'), findsOneWidget);
    expect(find.text('Thursday, October 22 · Tomorrow'), findsOneWidget);
    expect(find.text('2 of 13 done'), findsOneWidget);
    expect(find.text('Reply to email'), findsOneWidget);
  });

  testWidgets('medium and compact keep the pager', (tester) async {
    await pumpToday(tester, size: const Size(839, 900));
    expect(find.byType(TodayThreeDays), findsNothing);
    expect(find.byType(DayPager), findsOneWidget);
  });

  testWidgets('Go › Next Day and Previous Day step a day', (tester) async {
    Future<void> step(int days) async {
      Actions.invoke(
        tester.element(find.byType(WeekBoard)),
        ShowDayIntent(days),
      );
      await tester.pumpAndSettle();
    }

    await pumpToday(tester, size: _wide, threeDays: true);
    await step(1);
    // Yesterday, Today and Tomorrow stay relative to today.
    expect(find.text('Wednesday, October 21 · Today'), findsOneWidget);
    expect(find.text('Friday, October 23'), findsOneWidget);
    expect(find.text('Tuesday, October 20 · Yesterday'), findsNothing);
    await step(-1);
    await step(-1);
    expect(find.text('Monday, October 19'), findsOneWidget);
    expect(find.text('Tuesday, October 20 · Yesterday'), findsOneWidget);
  });

  testWidgets(
    'Shift the rest from here +15: a plan, then the rest of today, with Undo',
    (tester) async {
      await pumpToday(
        tester,
        size: const Size(1280, 1600),
        wrap: (today) => ProposalHost(child: today),
      );
      expect(find.text('10:30 AM – 11:15 AM'), findsOneWidget);
      // The Day menu's Time group, no separate button (ED-093).
      await tester.tap(find.byTooltip('More options').hitTestable().first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shift the rest from here…'));
      await tester.pumpAndSettle();
      // The sheet's chip (M3f.5), not the live row's own "+15 min".
      await tester.tap(find.widgetWithText(ChoiceChip, '+15 min'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(RegExp('move.? 15 min later')),
        findsOneWidget,
      );
      await tester.tap(find.text('Shift the rest').last); // the sheet's
      await tester.pumpAndSettle();
      await tester.tap(_formDone); // the form acts on Done
      await tester.pumpAndSettle();
      // Rebalance in the right-hand panel (M11.1): nothing moved yet.
      expect(find.text('10:30 AM – 11:15 AM'), findsWidgets);
      await tester.tap(find.text('Accept plan'));
      await tester.pumpAndSettle();
      expect(find.text('Plan accepted'), findsOneWidget);
      expect(find.text('10:45 AM – 11:30 AM'), findsOneWidget);
      // The live task started before now and stays put ("… · 2 h": the
      // card's live row keeps its time above the title, ADR-0015).
      expect(find.textContaining('9:00 AM – 11:00 AM'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('10:30 AM – 11:15 AM'), findsOneWidget);
    },
  );

  group('drag between days (M3e.1)', () {
    /// Drags [title] to the same height in yesterday's column.
    Future<void> drag(
      WidgetTester tester,
      String title, {
      required PointerDeviceKind kind,
      Duration hold = Duration.zero,
    }) async {
      final from = tester.getCenter(find.text(title));
      final yesterday = tester.getCenter(
        find.text('Tuesday, October 20 · Yesterday'),
      );
      final g = await tester.startGesture(from, kind: kind);
      await tester.pump(hold);
      await g.moveBy(const Offset(0, 20));
      await tester.pump();
      await g.moveTo(Offset(yesterday.dx, from.dy));
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
    }

    testWidgets('a mouse lifts at once and drops on another day', (
      tester,
    ) async {
      final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
      await pumpToday(tester, size: _wide, threeDays: true, repo: repo);
      await drag(tester, 'Reply to email', kind: PointerDeviceKind.mouse);
      expect(find.textContaining('Reply to email moved to'), findsOneWidget);
      final moved = repo.rows.singleWhere((o) => o.title == 'Reply to email');
      expect(moved.startUtc!.toUtc().day, 20);
    });

    testWidgets('touch without the hold does not lift', (tester) async {
      await pumpToday(tester, size: _wide, threeDays: true);
      await drag(tester, 'Reply to email', kind: PointerDeviceKind.touch);
      expect(find.textContaining('moved to'), findsNothing);
    });

    testWidgets('touch after the hold still drags', (tester) async {
      await pumpToday(tester, size: _wide, threeDays: true);
      await drag(
        tester,
        'Reply to email',
        kind: PointerDeviceKind.touch,
        hold: DotTouch.liftDelay + const Duration(milliseconds: 50),
      );
      expect(find.textContaining('Reply to email moved to'), findsOneWidget);
    });
  });

  testWidgets('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await pumpToday(tester, size: _wide, threeDays: true, mode: mode);
      await expectA11yGuidelines(tester);
    }
  });
}

/// The Running late form's Done (M20.6 part 2), not a task's.
final _formDone = find.descendant(
  of: find.byType(SheetNavBar),
  matching: find.text('Done'),
);
