import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Today's card opens at now (ED-336, ED-103): the live row (or the now
// marker) scrolls into view above the floating controls; other days and
// days without a now open at their top.

/// Floating Day / Add controls' strip, in the bottom padding.
const _controls = 120.0;

ThreadTask _task(int i, DotState state) => ThreadTask(
  id: 't$i',
  title: 'Task $i', // l10n-ignore: test fixture
  color: TaskColor.indigo,
  icon: TaskIcon.code,
  state: state,
  timeRange: '$i:00 – $i:30',
  minutes: 30,
);

/// Twenty rows done before [live]; on a 640 px phone it starts far below
/// the fold.
List<ThreadEntry> _day({bool live = true, bool marker = false}) => [
  const ThreadCap.wake('6:00'),
  for (var i = 0; i < 20; i++) ThreadTaskEntry(_task(i, DotState.done)),
  if (marker) const ThreadNow('20:30'),
  ThreadTaskEntry(_task(20, live ? DotState.live : DotState.upcoming)),
  for (var i = 21; i < 26; i++) ThreadTaskEntry(_task(i, DotState.upcoming)),
  const ThreadCap.bed('23:00'),
];

Future<void> _pump(
  WidgetTester tester,
  List<ThreadEntry> entries, {
  bool openAtNow = true,
  bool reduce = false,
}) async {
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: DotTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 640),
          padding: EdgeInsets.only(bottom: _controls),
        ).copyWith(disableAnimations: reduce),
        child: Scaffold(
          body: DayCard.page(entries: entries, openAtNow: openAtNow),
        ),
      ),
    ),
  );
}

ScrollPosition _position(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable).first).position;

/// The row's top sits on screen and above the controls' strip.
void _expectClear(WidgetTester tester, String title) {
  final top = tester.getTopLeft(find.text(title)).dy;
  expect(top, greaterThanOrEqualTo(0));
  expect(top, lessThan(640 - _controls));
}

void main() {
  testWidgets('today opens with the live row clear of the controls', (
    tester,
  ) async {
    await _pump(tester, _day());
    await tester.pumpAndSettle();
    expect(_position(tester).pixels, greaterThan(0));
    _expectClear(tester, 'Task 20');
    expect(find.text('Task 0'), findsNothing);
  });

  testWidgets('no live task: the now marker opens in view', (tester) async {
    await _pump(tester, _day(live: false, marker: true));
    await tester.pumpAndSettle();
    expect(_position(tester).pixels, greaterThan(0));
    _expectClear(tester, 'Task 20');
  });

  testWidgets('another day opens at its top', (tester) async {
    await _pump(tester, _day(), openAtNow: false);
    await tester.pumpAndSettle();
    expect(_position(tester).pixels, 0);
    expect(find.text('Task 0'), findsOneWidget);
  });

  testWidgets('a day with no now opens at its top', (tester) async {
    await _pump(tester, _day(live: false));
    await tester.pumpAndSettle();
    expect(_position(tester).pixels, 0);
  });

  testWidgets('a live row already in view stays put', (tester) async {
    await _pump(tester, [
      const ThreadCap.wake('6:00'),
      ThreadTaskEntry(_task(1, DotState.live)),
      ThreadTaskEntry(_task(2, DotState.upcoming)),
    ]);
    await tester.pumpAndSettle();
    expect(_position(tester).pixels, 0);
  });

  testWidgets('it animates there', (tester) async {
    await _pump(tester, _day());
    var animated = false;
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      animated |= _position(tester).isScrollingNotifier.value;
    }
    await tester.pumpAndSettle();
    expect(animated, isTrue);
    _expectClear(tester, 'Task 20');
  });

  testWidgets('reduced motion: it jumps there', (tester) async {
    await _pump(tester, _day(), reduce: true);
    var animated = false;
    for (var i = 0; i < 10; i++) {
      await tester.pump();
      animated |= _position(tester).isScrollingNotifier.value;
    }
    expect(animated, isFalse);
    expect(tester.binding.hasScheduledFrame, isFalse);
    _expectClear(tester, 'Task 20');
  });
}
