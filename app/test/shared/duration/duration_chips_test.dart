import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _chips(int value, List<int> out, {ThemeMode mode = ThemeMode.light}) =>
    testApp(
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: DurationChips(value: value, onChanged: out.add),
        ),
      ),
      themeMode: mode,
    );

void main() {
  testWidgets('shows presets with localised labels', (tester) async {
    await tester.pumpWidget(_chips(30, []));
    for (final label in ['15 min', '30 min', '45 min', '1 h', '1 h 30 min']) {
      expect(find.text(label), findsOneWidget);
    }
    final selected = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, '30 min'),
    );
    expect(selected.selected, isTrue);
  });

  testWidgets('tapping a preset emits it', (tester) async {
    final out = <int>[];
    await tester.pumpWidget(_chips(30, out));
    await tester.tap(find.text('1 h'));
    expect(out, [60]);
  });

  testWidgets('custom accepts typed durations within 5 min – 24 h', (
    tester,
  ) async {
    final out = <int>[];
    await tester.pumpWidget(_chips(30, out));
    await tester.tap(find.text('Custom'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '1h40');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(out, [100]);

    await tester.enterText(find.byType(TextField), '3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(out, [100]);
    expect(find.text('Use 5 min to 24 h, like 40m or 1h30'), findsOneWidget);
  });

  testWidgets('a non-preset value selects the custom chip with its length', (
    tester,
  ) async {
    await tester.pumpWidget(_chips(100, []));
    final custom = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, '1 h 40 min'),
    );
    expect(custom.selected, isTrue);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines ($mode)', (tester) async {
      await tester.pumpWidget(_chips(30, [], mode: mode));
      await expectA11yGuidelines(tester);
    });
  }
}
