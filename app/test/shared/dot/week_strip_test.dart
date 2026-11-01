import 'package:dottoday/domain/time/day_dot_geometry.dart';
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
        const DayDot(geometry: DayDotGeometry.filled(0.4)),
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

  // Large text on a phone: "Wed" no longer fits a seventh of 390 px. The
  // whole week shows its narrow form, never a word broken mid-way and never
  // a mix of the two forms.
  for (final (scale, expected) in [
    (1.0, ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
    (2.0, ['S', 'M', 'T', 'W', 'T', 'F', 'S']),
  ]) {
    testWidgets('weekday labels at ${(scale * 100).round()} % text', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(390, 400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final week = [
        for (final d in mainWeek)
          StripDay(
            weekday: d.weekday,
            weekdayNarrow: d.weekday.substring(0, 1),
            date: d.date,
            label: d.label,
            completion: d.completion,
            isToday: d.isToday,
            isPast: d.isPast,
          ),
      ];
      await tester.pumpWidget(
        testApp(Scaffold(body: WeekStrip(days: week, selected: 3))),
      );
      for (final label in expected.toSet()) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      // The column labels still say the whole day.
      expect(find.bySemanticsLabel('Wednesday 21, today'), findsOneWidget);
    });
  }
}
