import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/energy_history.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// The reality thread's promise and reveal on Today (docs/13 §4.2–§4.3):
// a caption before the threshold, at most once a day; at it, the toggle
// with one quiet highlight, said once to screen readers.

const _caption7 =
    'Your reality thread appears after about 10 finished tasks '
    '· 7 so far';

LearningMetaState _meta(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(TodayScreen)),
).read(learningMetaProvider).value!;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('before the threshold: the caption, hidden until tomorrow', (
    tester,
  ) async {
    await pumpToday(
      tester,
      rows: [...demoDayRows(todayTestDate), ...energyHistory(count: 7)],
    );
    expect(find.text(_caption7), findsOneWidget);
    expect(find.text('Reality'), findsNothing);
    await tester.tap(find.byTooltip('Hide until tomorrow'));
    await tester.pumpAndSettle();
    expect(find.text(_caption7), findsNothing);
    expect(_meta(tester).captionDay, todayTestDate);
  });

  testWidgets('put away today: not shown again today', (tester) async {
    await pumpToday(
      tester,
      rows: [...demoDayRows(todayTestDate), ...energyHistory(count: 7)],
      learningMeta: captionPutAway(todayTestDate),
    );
    expect(find.textContaining('reality thread appears'), findsNothing);
  });

  testWidgets('at ten: the toggle, highlighted once, said once, remembered', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpToday(
      tester,
      rows: [...demoDayRows(todayTestDate), ...energyHistory(count: 10)],
    );
    expect(find.textContaining('reality thread appears'), findsNothing);
    expect(find.text('Reality'), findsOneWidget);
    expect(
      tester.takeAnnouncements().map((a) => a.message),
      contains('Plan and reality view is now in the day header'),
    );
    expect(_meta(tester).realityRevealed, isTrue, reason: 'the crossing');
    expect(_meta(tester).realityHighlighted, isFalse, reason: 'still holding');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(_meta(tester).realityHighlighted, isTrue);
    handle.dispose();
  });

  testWidgets('reduced motion: no tint, still said and remembered', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpToday(
      tester,
      rows: [...demoDayRows(todayTestDate), ...energyHistory(count: 10)],
      wrap: (today) => Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: today,
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeAnnouncements(), isNotEmpty);
    expect(_meta(tester).realityHighlighted, isTrue);
    handle.dispose();
  });

  testWidgets('highlighted before: no highlight, no announcement', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpToday(tester, learningMeta: realityRevealedMeta);
    expect(find.text('Reality'), findsOneWidget);
    expect(tester.takeAnnouncements(), isEmpty);
    handle.dispose();
  });
}
