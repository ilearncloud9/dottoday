import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/energy_history.dart';
import 'add_harness.dart';

// Energy suggestions in Add (docs/09 M11.5, 11 C4, docs/13 §3): for one of
// the user's high-energy tasks, once twenty were finished and the user
// turned suggestions on, step 2 says when they finish such work best and
// offers that time.

Future<void> _toWhen(WidgetTester tester, String text) async {
  await tester.enterText(addTitle, text);
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

Future<Object> _pump(
  WidgetTester tester,
  List<Occurrence> history, {
  bool? on = true,
}) => pumpAddHost(
  tester,
  rows: [...demoTimed(), ...history],
  size: const Size(390, 1600),
  settings: Settings(use24h: false, energySuggestions: on),
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('twenty runs: the window and "Try"', (tester) async {
    await _pump(tester, energyHistory());
    await _toWhen(tester, 'Write report 3pm');
    expect(
      find.text('you finish high-energy tasks best 9:00 AM – 11:00 AM'),
      findsOneWidget,
    );
    // docs/13 §6: explained, and no per-title reset for an app-wide window.
    await tester.tap(
      find.text('you finish high-energy tasks best 9:00 AM – 11:00 AM'),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'based on your last 20 finished high-energy tasks · where most started',
      ),
      findsOneWidget,
    );
    expect(find.text('Reset for this task on this device'), findsNothing);
    await tester.tap(find.text('Try 9:00 AM'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Today · 9:00 AM'), findsOneWidget);
    expect(find.text('Try 9:00 AM'), findsNothing, reason: 'already there');
  });

  testWidgets('nineteen runs, or another task: nothing', (tester) async {
    await _pump(tester, energyHistory(count: 19));
    await _toWhen(tester, 'Write report 3pm');
    expect(find.textContaining('high-energy'), findsNothing);
  });

  testWidgets('twenty runs but never turned on: nothing (docs/13 §3)', (
    tester,
  ) async {
    await _pump(tester, energyHistory(), on: null);
    await _toWhen(tester, 'Write report 3pm');
    expect(find.textContaining('high-energy'), findsNothing);
  });

  testWidgets('not one of the high-energy tasks: nothing', (tester) async {
    await _pump(tester, energyHistory());
    await _toWhen(tester, 'Groceries 3pm');
    expect(find.textContaining('high-energy'), findsNothing);
  });
}
