import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/sample_day.dart';
import '../../support/test_app.dart';

const _days = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

Widget _pager({
  ValueChanged<int>? onChanged,
  ThemeMode mode = ThemeMode.light,
}) => testApp(
  Scaffold(
    body: DayPager(
      itemCount: 7,
      initialIndex: 3,
      onChanged: onChanged,
      itemBuilder: (context, i) => DayCard(
        title: _days[i],
        isToday: i == 3,
        summary: const DaySummary(
          done: 2,
          total: 7,
          plannedMinutes: 345,
          freeMinutes: 555,
        ),
        entries: mainThread,
      ),
    ),
  ),
  themeMode: mode,
);

void main() {
  testWidgets('a short pager never overflows', (tester) async {
    for (final height in [30.0, 80.0, 200.0]) {
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: height,
                child: DayPager(
                  itemCount: 7,
                  initialIndex: 3,
                  itemBuilder: (_, i) => const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: '$height');
    }
  });

  testWidgets('opens on today with its header numbers', (tester) async {
    await tester.pumpWidget(_pager());
    expect(find.text('Wednesday · Today'), findsOneWidget);
    expect(find.text('2 of 7 · 5 h 45 planned'), findsWidgets);
  });

  testWidgets('a day fills the width: no peek, no page dots (ADR-0015)', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_pager());
    final today = tester.getRect(find.byType(DayCard));
    expect(today.left, 0);
    expect(today.right, 390);
    expect(find.byType(DayCard), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Day \d of 7$')), findsNothing);
  });

  testWidgets('swiping snaps to the next day and reports it', (tester) async {
    final pages = <int>[];
    await tester.pumpWidget(_pager(onChanged: pages.add));
    await tester.fling(
      find.text('Wednesday · Today'),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(pages, [4]);
    expect(find.text('Thursday'), findsOneWidget);
  });

  testWidgets('a new index (week strip tap) slides the pager there', (
    tester,
  ) async {
    Widget pager(int index) => testApp(
      Scaffold(
        body: DayPager(
          itemCount: 7,
          initialIndex: index,
          itemBuilder: (context, i) => Text(_days[i]),
        ),
      ),
    );
    await tester.pumpWidget(pager(3));
    await tester.pumpWidget(pager(5));
    await tester.pumpAndSettle();
    expect(find.text('Friday'), findsOneWidget);
  });

  testWidgets('an empty day says so', (tester) async {
    await tester.pumpWidget(
      testApp(
        const Scaffold(
          body: DayCard(
            title: 'Monday 14 Dec',
            summary: DaySummary(
              done: 0,
              total: 0,
              plannedMinutes: 0,
              freeMinutes: 900,
            ),
            entries: [],
          ),
        ),
      ),
    );
    expect(find.text('Nothing planned · 15 h free'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      await tester.pumpWidget(_pager(mode: mode));
      await expectA11yGuidelines(tester);
    });
  }
}
