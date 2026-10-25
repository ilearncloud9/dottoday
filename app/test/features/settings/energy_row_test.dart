import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/energy_history.dart';
import 'settings_harness.dart';

// Settings › Planning › Energy suggestions (docs/09 M11.5, 11 C4): off and
// locked until twenty high-energy tasks were finished, then on until the
// user turns it off.

Finder get _row => find.ancestor(
  of: find.text('Energy suggestions'),
  matching: find.byType(InkWell),
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('locked with the count so far', (tester) async {
    final h = await pumpSettings(tester, rows: energyHistory(count: 7));
    expect(
      find.text('After 20 finished high-energy tasks · 7 so far'),
      findsOneWidget,
    );
    await tester.tap(_row.first);
    await tester.pumpAndSettle();
    final s = h.container.read(currentProfileProvider).value!.settings;
    expect(
      s.energySuggestions,
      isNull,
      reason: 'a locked switch changes nothing',
    );
  });

  testWidgets('twenty: on by default, and the user can turn it off', (
    tester,
  ) async {
    final h = await pumpSettings(tester, rows: energyHistory());
    expect(
      find.text('Suggest times when you usually finish high-energy tasks'),
      findsOneWidget,
    );
    await tester.tap(_row.first);
    await tester.pumpAndSettle();
    final s = h.container.read(currentProfileProvider).value!.settings;
    expect(s.energySuggestions, isFalse);
  });
}
