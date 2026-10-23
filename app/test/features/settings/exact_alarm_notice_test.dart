import 'package:dottoday/domain/notifications/exact_alarms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'settings_harness.dart';

/// Android with "Alarms & reminders" off until the user allows it.
final class _Gated implements ExactAlarms {
  var allowedNow = false;
  var requests = 0;

  @override
  Future<bool> allowed() async => allowedNow;

  @override
  Future<void> request() async {
    requests++;
    allowedNow = true; // the user switched it on in the system screen
  }
}

// docs/07 Android: SCHEDULE_EXACT_ALARM with a rationale, inexact fallback
// (docs/09 M5.6).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Settings explains late reminders and opens the system screen', (
    tester,
  ) async {
    final gate = _Gated();
    await pumpSettings(tester, exactAlarms: gate);
    expect(find.text('Reminders may come a few minutes late'), findsOneWidget);
    await expectA11yGuidelines(tester);
    await tester.ensureVisible(find.text('Allow exact timing'));
    await tester.tap(find.text('Allow exact timing'));
    await tester.pumpAndSettle();
    expect(gate.requests, 1);
    expect(find.text('Reminders may come a few minutes late'), findsNothing);
  });

  testWidgets('nothing to say where exact timing is allowed', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Reminders may come a few minutes late'), findsNothing);
  });
}
