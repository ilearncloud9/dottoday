import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/reality_fixtures.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// The Reality thread on Today (docs/09 M11.2, 11 C3): the toggle shows
// once a task really started; Reality captions what happened in plain
// words; Plan is the thread as before.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('no actuals today: no toggle', (tester) async {
    await pumpToday(tester);
    expect(find.text('Reality'), findsNothing);
  });

  testWidgets('Reality captions the day as it went', (tester) async {
    await pumpToday(
      tester,
      rows: realityDayRows(),
      size: const Size(390, 1600),
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
    );
    final grips = find.bySemanticsLabel(RegExp('^Change how long'));
    expect(grips, findsWidgets);
    await tester.tap(find.text('Reality'));
    await tester.pumpAndSettle();
    expect(grips, findsNothing);
    handle.dispose();
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpToday(
      tester,
      rows: realityDayRows(),
      size: const Size(390, 1600),
    );
    await tester.tap(find.text('Reality'));
    await tester.pumpAndSettle();
    await expectA11yGuidelines(tester);
    handle.dispose();
  });

  test('the fixture has a dot with no actuals', () {
    final rows = realityDayRows();
    expect(hasActuals(rows), isTrue);
    expect(hasActuals(demoDayRows(DateTime(2026, 10, 21))), isFalse);
  });
}
