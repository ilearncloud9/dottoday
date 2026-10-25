import 'package:dottoday/shared/dot/shift_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

// The drag chips (docs/03 §3.2, docs/09 M7.6): both are toggles a screen
// reader can read and flip, and they wrap rather than clip at large text.

Widget _chips(
  ValueNotifier<bool> on,
  ValueNotifier<bool> calendar, {
  ThemeMode theme = ThemeMode.light,
  double textScale = 1,
}) => testApp(
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Stack(
          children: [ShiftChip(on: on, calendar: calendar)],
        ),
      ),
    ),
  ),
  themeMode: theme,
);

void main() {
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    for (final width in [390.0, 1024.0]) {
      testWidgets('both chips meet the a11y guidelines ($theme, $width)', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _chips(ValueNotifier(true), ValueNotifier(false), theme: theme),
        );
        expect(find.text('Calendar events too'), findsOneWidget);
        await expectA11yGuidelines(tester);
      });
    }
  }

  testWidgets('a screen reader reads and toggles "Calendar events too"', (
    tester,
  ) async {
    final calendar = ValueNotifier(false);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_chips(ValueNotifier(true), calendar));
    final node = find.bySemanticsLabel('Calendar events too');
    expect(
      tester.getSemantics(node),
      matchesSemantics(
        label: 'Calendar events too',
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.text('Calendar events too'));
    await tester.pump();
    expect(calendar.value, isTrue);
    handle.dispose();
  });

  testWidgets('at 200 % text the chips wrap without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _chips(ValueNotifier(true), ValueNotifier(true), textScale: 2),
    );
    expect(tester.takeException(), isNull);
    final a = tester.getTopLeft(find.text('Shift later tasks'));
    final b = tester.getTopLeft(find.text('Calendar events too'));
    expect(b.dy, greaterThan(a.dy), reason: 'second row');
  });
}
