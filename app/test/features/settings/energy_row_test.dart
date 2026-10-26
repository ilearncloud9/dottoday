import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/energy_history.dart';
import 'settings_harness.dart';

// Settings › Learning › Energy suggestions (11 C4, docs/13 §3): off and
// locked with its progress until twenty high-energy tasks were finished,
// then available but still off ("ready") until the user turns it on.

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
    expect(find.text('7/20'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('7 of 20 so far')), findsOneWidget);
    await tester.tap(_row.first);
    await tester.pumpAndSettle();
    final s = h.container.read(currentProfileProvider).value!.settings;
    expect(
      s.energySuggestions,
      isNull,
      reason: 'a locked switch changes nothing',
    );
  });

  testWidgets('twenty: ready but off until the user turns it on', (
    tester,
  ) async {
    final h = await pumpSettings(tester, rows: energyHistory());
    expect(find.text('ready — based on 20 completed tasks'), findsOneWidget);
    Settings settings() =>
        h.container.read(currentProfileProvider).value!.settings;
    expect(settings().energySuggestions, isNull, reason: 'unset is off');
    await tester.tap(_row.first);
    await tester.pumpAndSettle();
    expect(settings().energySuggestions, isTrue, reason: 'on is explicit');
    expect(
      find.text('Suggest times when you usually finish high-energy tasks'),
      findsOneWidget,
    );
    await tester.tap(_row.first);
    await tester.pumpAndSettle();
    expect(settings().energySuggestions, isFalse);
  });
}
