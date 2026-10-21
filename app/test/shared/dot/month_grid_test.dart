import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/sample_month.dart';
import '../../support/test_app.dart';

Widget _grid({
  MonthCellStyle style = MonthCellStyle.compact,
  int weekStart = 0,
  int month = 10,
  ValueChanged<int>? onSelect,
  ThemeMode mode = ThemeMode.light,
}) => testApp(
  Scaffold(
    body: SingleChildScrollView(
      child: MonthGrid(
        weekdays: sampleWeekdays(weekStart),
        days: sampleMonth(year: 2026, month: month, weekStart: weekStart),
        style: style,
        onSelect: onSelect ?? (_) {},
      ),
    ),
  ),
  themeMode: mode,
);

void main() {
  test('sample months: 5 rows for October, 6 for August 2026', () {
    int rows(int month, int start) =>
        (sampleMonth(year: 2026, month: month, weekStart: start).length / 7)
            .ceil();
    expect([rows(10, 0), rows(10, 1)], [5, 5]);
    expect([rows(8, 0), rows(8, 1)], [6, 6]);
  });

  testWidgets('week start moves the 1st to its weekday column', (tester) async {
    await tester.pumpWidget(_grid(weekStart: 1));
    // 1 October 2026 is a Thursday: fourth column from Monday.
    final mon = tester.getCenter(find.text('Mon')).dx;
    final thu = tester.getCenter(find.text('Thu')).dx;
    final one = tester.getCenter(find.text('1')).dx;
    expect(one, closeTo(thu, 1));
    expect(one, greaterThan(mon));
  });

  testWidgets('a tap reports the index of the day', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_grid(onSelect: taps.add));
    await tester.tap(find.text('21'));
    expect(taps, [4 + 20]);
  });

  testWidgets('expanded cells: struck done, missed, now, more, N of M', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_grid(style: MonthCellStyle.expanded));
    expect(find.text('Deep work · now'), findsOneWidget);
    expect(find.textContaining('· missed'), findsWidgets);
    expect(find.textContaining(' done'), findsWidgets);
    final struck = tester
        .widgetList<Text>(find.text('Run'))
        .where((t) => t.style?.decoration == TextDecoration.lineThrough);
    expect(struck, isNotEmpty);
  });

  for (final style in MonthCellStyle.values) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('${style.name} meets a11y guidelines (${mode.name})', (
        tester,
      ) async {
        if (style == MonthCellStyle.expanded) {
          await tester.binding.setSurfaceSize(const Size(1280, 1100));
          addTearDown(() => tester.binding.setSurfaceSize(null));
        }
        await tester.pumpWidget(_grid(style: style, mode: mode));
        await expectA11yGuidelines(tester);
      });
    }
  }
}
