import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/data/calendar/calendar_moves.dart';
import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/proposal_harness.dart';
import '../../support/rebalance_fixtures.dart';
import '../../support/test_app.dart';

// "Standup moved to 1:45 PM · Rebalance?" (docs/09 M11.1b) over a real
// database: the calendar moved Standup 13:00 → 13:45 New York, into
// Spanish lesson at 14:00. The prompt opens Rebalance; nothing is written
// before Accept; Not now puts it away.

const _standup = '01928c3e-0000-7000-8000-0000000000e1';
final _was = DateTime.utc(2026, 10, 21, 17);
final _is = DateTime.utc(2026, 10, 21, 17, 45);

final _move = CalendarMove(
  occurrenceId: _standup,
  title: 'Standup',
  fromUtc: _was,
  toUtc: _is,
  durationMin: 30,
);

Future<(ProposalHarness, ProviderContainer)> _pump(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = ProposalHarness(rebalanceNow);
  addTearDown(() => h.dispose(tester));
  await h.seed(
    tester,
    WriteBatch(
      userId: userId,
      profile: profileFixture(),
      occurrences: [
        ...rebalanceDayRows(),
        occurrenceFixture().copyWith(
          id: _standup,
          title: 'Standup',
          startUtc: _is,
          durationMin: 30,
          source: OccurrenceSource.calendar,
        ),
      ],
    ),
  );
  final today = DateTime(2026, 10, 21);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...h.overrides,
        minuteTickProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: testApp(
        Scaffold(
          body: ProposalHost(
            child: ListView(
              children: [TodayPrompt(date: today, today: today)],
            ),
          ),
        ),
      ),
    ),
  );
  await _settleDb(tester);
  final container = ProviderScope.containerOf(
    tester.element(find.byType(TodayPrompt, skipOffstage: false)),
  );
  return (h, container);
}

Future<void> _move_(WidgetTester tester, ProviderContainer c) async {
  c.read(calendarMovesProvider.notifier).add([_move]);
  await tester.pumpAndSettle();
}

/// Lets the database's queries run (they need real time) between frames.
Future<void> _settleDb(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// Unmounts so the day's database streams close inside the test (drift
/// closes them on a zero timer, run for real here).
Future<void> _unmount(WidgetTester tester) => tester.runAsync(() async {
  await tester.pumpWidget(const SizedBox());
  await Future<void>.delayed(const Duration(milliseconds: 50));
});

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a move into the plan asks, once', (tester) async {
    final (_, c) = await _pump(tester);
    expect(find.text('Rebalance'), findsNothing);
    await _move_(tester, c);
    expect(find.text('CALENDAR CHANGED'), findsOneWidget);
    expect(find.text('Standup moved to 1:45 PM · Rebalance?'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('CALENDAR CHANGED'), findsNothing);
    expect(c.read(calendarMovesProvider), isEmpty);
    await _unmount(tester);
  });

  testWidgets('Rebalance opens the plan; nothing before Accept', (
    tester,
  ) async {
    final (h, c) = await _pump(tester);
    await _move_(tester, c);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await tester.tap(find.text('Rebalance'));
        await _settleDb(tester);
        expect(find.text('Calendar changed'), findsOneWidget);
        expect(
          find.text("Standup moved to 1:45 PM · here's a plan"),
          findsOneWidget,
        );
        expect(find.text('shifted +45 min'), findsWidgets);
      },
      leave: () => tester.tap(find.text('Discard')),
    );
    expect(c.read(calendarMovesProvider), isEmpty, reason: 'asked once');
    await _unmount(tester);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    final (_, c) = await _pump(tester);
    await _move_(tester, c);
    await expectA11yGuidelines(tester);
    handle.dispose();
    await _unmount(tester);
  });
}
