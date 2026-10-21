import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/sample_day.dart';
import '../../support/test_app.dart';

Widget _strip({
  ValueChanged<int>? onSelect,
  VoidCallback? onPull,
  ThemeMode mode = ThemeMode.light,
}) => testApp(
  Scaffold(
    body: Column(
      children: [
        const DayDot(progress: 0.4),
        WeekStrip(
          days: mainWeek,
          selected: 3,
          onSelect: onSelect ?? (_) {},
          onPull: onPull ?? () {},
        ),
      ],
    ),
  ),
  themeMode: mode,
);

void main() {
  testWidgets('tapping a day selects it; the handle pulls the month', (
    tester,
  ) async {
    final picked = <int>[];
    var pulls = 0;
    await tester.pumpWidget(
      _strip(onSelect: picked.add, onPull: () => pulls++),
    );
    await tester.tap(find.text('Fri'));
    await tester.tap(find.bySemanticsLabel('Show month'));
    await tester.drag(find.byType(PullHandle), const Offset(0, 80));
    expect(picked, [5]);
    expect(pulls, 2);
  });

  testWidgets('labels: day dot share, selected day, handle state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_strip());
    expect(find.bySemanticsLabel('Day 40 % through'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Wednesday 21, today')),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      await tester.pumpWidget(_strip(mode: mode));
      await expectA11yGuidelines(tester);
    });
  }
}
