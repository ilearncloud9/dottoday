import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/reality_fixtures.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// The Reality thread on Today (docs/09 M11.2, 11 C3, docs/13 §4.3): the
// toggle shows once the reality threshold was crossed; Reality captions
// what happened in plain words; Plan is the thread as before.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('before the threshold: no toggle, even with actuals', (
    tester,
  ) async {
    await pumpToday(tester, rows: realityDayRows());
    expect(find.text('Reality'), findsNothing);
  });

  testWidgets('revealed, no actuals today: the plan, "nothing started yet"', (
    tester,
  ) async {
    await pumpToday(tester, learningMeta: realityRevealedMeta);
    expect(find.text('nothing started yet today'), findsNothing);
    await tester.tap(find.text('Reality'));
    await tester.pumpAndSettle();
    expect(find.text('nothing started yet today'), findsOneWidget);
    expect(find.text('Morning run'), findsOneWidget, reason: 'the plan');
  });

  testWidgets('Reality captions the day as it went', (tester) async {
    await pumpToday(
      tester,
      rows: realityDayRows(),
      size: const Size(390, 1600),
      learningMeta: realityRevealedMeta,
    );
    expect(find.text('Reality'), findsOneWidget);
    expect(find.text('6:57 AM – 7:31 AM'), findsNothing, reason: 'Plan first');
    await tester.tap(find.text('Reality'));
    await tester.pumpAndSettle();
    // Finished: real times, the plan's start, how long it took.
    expect(find.text('6:57 AM – 7:31 AM'), findsOneWidget);
    expect(find.text('· planned 6:45 AM'), findsOneWidget);
    expect(find.text('took 34 min'), findsOneWidget);
    // Under way since 9:10, planned 9–11.
    expect(
      find.text('9:10 AM – now · planned 9:00 AM – 11:00 AM'),
      findsOneWidget,
    );
    expect(find.text('12 min in'), findsOneWidget);
    // The next one, never "late".
    expect(find.text('· not started yet'), findsWidgets);
    expect(find.textContaining('late'), findsNothing);
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(find.text('took 34 min'), findsNothing);
  });

  testWidgets('Reality is read-only for drags', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpToday(
      tester,
      rows: realityDayRows(),
      size: const Size(390, 1600),
      learningMeta: realityRevealedMeta,
    );
    final lifts = find.byType(DraggableTaskRow);
    expect(lifts, findsWidgets);
    await tester.tap(find.text('Reality'));
    await tester.pumpAndSettle();
    expect(lifts, findsNothing);
    handle.dispose();
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpToday(
      tester,
      rows: realityDayRows(),
      size: const Size(390, 1600),
      learningMeta: realityRevealedMeta,
    );
    await tester.tap(find.text('Reality'));
    await tester.pumpAndSettle();
    await expectA11yGuidelines(tester);
    handle.dispose();
  });

  testWidgets('learning: "usually 2 h 20" and the insight strip', (
    tester,
  ) async {
    await pumpToday(
      tester,
      rows: [...realityDayRows(), ...deepWorkHistory()],
      size: const Size(390, 1600),
      learningMeta: realityRevealedMeta,
    );
    await tester.tap(find.text('Reality'));
    await tester.pumpAndSettle();
    expect(find.text('usually 2 h 20'), findsOneWidget);
    // docs/13 §6: the live row's and the strip's values explain themselves.
    await tester.tap(find.text('usually 2 h 20'));
    await tester.pumpAndSettle();
    expect(find.text('based on your last 4 times · median'), findsOneWidget);
    await tester.tap(find.textContaining('usually takes you'));
    await tester.pumpAndSettle();
    expect(find.text('based on your last 4 times · median'), findsNWidgets(2));
    await tester.tap(find.text('usually 2 h 20'));
    await tester.tap(find.textContaining('usually takes you'));
    await tester.pumpAndSettle();
    const strip =
        'Deep work: roadmap usually takes you 2 h 20 · Add will suggest it';
    expect(find.text(strip), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(strip), findsNothing);
    expect(find.text('usually 2 h 20'), findsOneWidget, reason: 'stays');
  });

  testWidgets('no strip on the plan, or without history', (tester) async {
    await pumpToday(
      tester,
      rows: [...realityDayRows(), ...deepWorkHistory()],
      size: const Size(390, 1600),
      learningMeta: realityRevealedMeta,
    );
    expect(find.textContaining('usually takes you'), findsNothing);
    await tester.tap(find.text('Reality'));
    await tester.pumpAndSettle();
    expect(find.textContaining('usually takes you'), findsOneWidget);
  });

  test('the fixture has a dot with no actuals', () {
    final rows = realityDayRows();
    expect(hasActuals(rows), isTrue);
    expect(hasActuals(demoDayRows(DateTime(2026, 10, 21))), isFalse);
  });
}
