import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/widgets/today_spread.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// T5, the Mac/web three-day spread (docs/09 M3e.1,
// `A-mac-today-alt1-spread`). Wednesday 21 Oct, 09:22 in Berlin.
// Tall enough for the day thread's stretched rows (ADR-0015).
const _wide = Size(1280, 1400);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('expanded: yesterday, today on its card, tomorrow', (
    tester,
  ) async {
    await pumpToday(tester, size: _wide);
    expect(find.byType(TodaySpread), findsOneWidget);
    expect(find.byType(DayPager), findsNothing);
    expect(find.text('Good morning, Kody'), findsOneWidget);
    expect(find.text('Wednesday, October 21 · 2 of 13 done'), findsOneWidget);
    expect(find.text('Tuesday · Yesterday'), findsOneWidget);
    expect(find.text('Wednesday · Today'), findsOneWidget);
    expect(find.text('Thursday · Tomorrow'), findsOneWidget);
    expect(find.text('Nothing planned'), findsOneWidget);
    expect(find.text('1 planned'), findsOneWidget);
    expect(find.text('drop here to plan'), findsOneWidget);
    expect(find.text('Running late'), findsOneWidget);
  });

  testWidgets('medium and compact keep the pager', (tester) async {
    await pumpToday(tester, size: const Size(839, 900));
    expect(find.byType(TodaySpread), findsNothing);
    expect(find.byType(DayPager), findsOneWidget);
  });

  testWidgets('› and ‹ step a day; away from today the pill returns', (
    tester,
  ) async {
    await pumpToday(tester, size: _wide);
    await tester.tap(find.byTooltip('Next day'));
    await tester.pumpAndSettle();
    expect(find.text('Wednesday · Today'), findsOneWidget);
    expect(find.text('Friday'), findsOneWidget);
    expect(find.text('Running late'), findsNothing);
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Kody'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous day'));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
  });

  testWidgets('Running late +15: a plan, then the rest of today, with Undo', (
    tester,
  ) async {
    await pumpToday(
      tester,
      size: const Size(1280, 1600),
      wrap: (today) => ProposalHost(child: today),
    );
    expect(find.text('10:30 AM – 11:15 AM'), findsOneWidget);
    await tester.tap(find.text('Running late'));
    await tester.pumpAndSettle();
    // The sheet's chip (M3f.5), not the live row's own "+15 min".
    await tester.tap(find.widgetWithText(ChoiceChip, '+15 min'));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp('move.? 15 min later')), findsOneWidget);
    await tester.tap(find.text('Shift the rest').last); // the sheet's
    await tester.pumpAndSettle();
    // Rebalance in the right-hand panel (M11.1): nothing moved yet.
    expect(find.text('10:30 AM – 11:15 AM'), findsWidgets);
    await tester.tap(find.text('Accept plan'));
    await tester.pumpAndSettle();
    expect(find.text('Plan accepted'), findsOneWidget);
    expect(find.text('10:45 AM – 11:30 AM'), findsOneWidget);
    // The live task started before now and stays put.
    expect(find.text('9:00 AM – 11:00 AM'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('10:30 AM – 11:15 AM'), findsOneWidget);
  });

  group('drag between columns (M3e.1)', () {
    Future<void> drag(
      WidgetTester tester,
      String title,
      String gap, {
      required PointerDeviceKind kind,
      Duration hold = Duration.zero,
    }) async {
      final g = await tester.startGesture(
        tester.getCenter(find.text(title)),
        kind: kind,
      );
      await tester.pump(hold);
      await g.moveBy(const Offset(0, 20));
      await tester.pump();
      await g.moveTo(tester.getCenter(find.text(gap)));
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
    }

    testWidgets('a mouse lifts at once and drops on another day', (
      tester,
    ) async {
      final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
      await pumpToday(tester, size: _wide, repo: repo);
      await drag(
        tester,
        'Reply to email',
        '15 h free',
        kind: PointerDeviceKind.mouse,
      );
      expect(find.textContaining('Reply to email moved to'), findsOneWidget);
      final moved = repo.rows.singleWhere((o) => o.title == 'Reply to email');
      expect(moved.startUtc!.toUtc().day, 20);
    });

    testWidgets('touch without the hold does not lift', (tester) async {
      await pumpToday(tester, size: _wide);
      await drag(
        tester,
        'Reply to email',
        '15 h free',
        kind: PointerDeviceKind.touch,
      );
      expect(find.textContaining('moved to'), findsNothing);
    });

    testWidgets('touch after the hold still drags', (tester) async {
      await pumpToday(tester, size: _wide);
      await drag(
        tester,
        'Reply to email',
        '15 h free',
        kind: PointerDeviceKind.touch,
        hold: DotTouch.liftDelay + const Duration(milliseconds: 50),
      );
      expect(find.textContaining('Reply to email moved to'), findsOneWidget);
    });
  });

  testWidgets('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await pumpToday(tester, size: _wide, mode: mode);
      await expectA11yGuidelines(tester);
    }
  });
}
