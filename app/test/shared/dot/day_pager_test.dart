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
  testWidgets('opens on today with its header numbers', (tester) async {
    await tester.pumpWidget(_pager());
    expect(find.text('Wednesday · Today'), findsOneWidget);
    expect(find.text('2 of 7 · 5 h 45 planned'), findsWidgets);
    expect(find.bySemanticsLabel('Day 4 of 7'), findsOneWidget);
  });

  testWidgets('neighbours peek in at both edges', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_pager());
    final today = tester.getRect(find.byType(DayCard).at(1));
    expect(today.left, closeTo(DayPager.peek + 4, 0.5));
    expect(390 - today.right, closeTo(DayPager.peek + 4, 0.5));
    expect(find.byType(DayCard), findsNWidgets(3));
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
    expect(find.bySemanticsLabel('Day 5 of 7'), findsOneWidget);
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
