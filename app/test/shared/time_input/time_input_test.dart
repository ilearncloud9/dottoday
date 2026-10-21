// docs/08 §2 `time_input_test` (R-20): AM/PM edges, "930" → 09:30, locale
// separators, never changes the date.
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

final class _Harness {
  final changes = <ClockTime>[];

  Widget build({
    ClockTime value = const ClockTime(8, 0),
    bool? use24h = true,
    ThemeMode themeMode = ThemeMode.light,
  }) => testApp(
    Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TimeInput(value: value, onChanged: changes.add, use24h: use24h),
      ),
    ),
    themeMode: themeMode,
  );
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  testWidgets('typing "930" yields 09:30', (tester) async {
    final h = _Harness();
    await tester.pumpWidget(h.build());
    await _type(tester, '930');
    expect(h.changes, [const ClockTime(9, 30)]);
    expect(_fieldText(tester), '09:30');
  });

  for (final (input, want) in [
    ('12:00 AM', const ClockTime(0, 0)),
    ('12:00 PM', const ClockTime(12, 0)),
    ('12:30am', const ClockTime(0, 30)),
    ('11:59 pm', const ClockTime(23, 59)),
  ]) {
    testWidgets('AM/PM edge "$input" → $want', (tester) async {
      final h = _Harness();
      await tester.pumpWidget(h.build());
      await _type(tester, input);
      expect(h.changes.single, want);
    });
  }

  for (final input in ['9:30', '9.30', '9h30', '9 30']) {
    testWidgets('locale separator "$input" → 09:30', (tester) async {
      final h = _Harness();
      await tester.pumpWidget(h.build());
      await _type(tester, input);
      expect(h.changes.single, const ClockTime(9, 30));
    });
  }

  testWidgets('12-h display shows AM/PM and parsing does not flip', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(
      h.build(value: const ClockTime(0, 0), use24h: false),
    );
    expect(_fieldText(tester), '12:00 AM');
    await _type(tester, '930');
    expect(h.changes.single, const ClockTime(9, 30));
    expect(_fieldText(tester), '9:30 AM');
  });

  testWidgets('invalid text shows an error and keeps the value', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(h.build());
    await _type(tester, '25:00');
    expect(h.changes, isEmpty);
    expect(find.text('Type a time like 9:30 or 2pm'), findsOneWidget);
    await _type(tester, '10');
    expect(find.text('Type a time like 9:30 or 2pm'), findsNothing);
    expect(h.changes, [const ClockTime(10, 0)]);
  });

  testWidgets('commits when focus leaves the field', (tester) async {
    final h = _Harness();
    await tester.pumpWidget(h.build());
    await tester.enterText(find.byType(TextField), '1745');
    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pump();
    expect(h.changes, [const ClockTime(17, 45)]);
  });

  testWidgets('same time as before emits nothing', (tester) async {
    final h = _Harness();
    await tester.pumpWidget(h.build());
    await _type(tester, '8:00');
    expect(h.changes, isEmpty);
  });

  testWidgets('wheel only reads hour and minute (never a date)', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(h.build(value: const ClockTime(23, 30)));
    await tester.tap(find.byTooltip('Pick time with a wheel'));
    await tester.pumpAndSettle();
    final picker = tester.widget<CupertinoDatePicker>(
      find.byType(CupertinoDatePicker),
    );
    expect(picker.initialDateTime.hour, 23);
    // Scrolling across midnight changes the date the wheel carries; only
    // the time must come back.
    picker.onDateTimeChanged(DateTime(2000, 1, 2, 0, 15));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(h.changes, [const ClockTime(0, 15)]);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines ($mode, with error)', (tester) async {
      final h = _Harness();
      await tester.pumpWidget(h.build(themeMode: mode));
      await expectA11yGuidelines(tester);
      await _type(tester, 'x');
      await expectA11yGuidelines(tester);
    });
  }
}
