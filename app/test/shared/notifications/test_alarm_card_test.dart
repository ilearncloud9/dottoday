import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

// "Send me a test alarm" (docs/09 M6.5.9): explain, send, count down, ask.
void main() {
  late DateTime now;
  late List<String> calls;

  Widget card() => Scaffold(
    body: TestAlarmCard(
      onSend: () async {
        calls.add('send');
        return now.add(const Duration(seconds: 60));
      },
      onCancel: () async => calls.add('cancel'),
      now: () => now,
      afterNo: 'Look at the checks.', // l10n-ignore: test fixture
    ),
  );

  setUp(() {
    now = DateTime.utc(2026, 10, 23, 9);
    calls = [];
  });

  testWidgets('explains first, then counts down and asks', (tester) async {
    await tester.pumpWidget(testApp(card()));
    await tester.tap(find.text('Send me a test alarm'));
    await tester.pump();
    expect(
      find.text(
        'Dottoday will send one test alarm in 60 seconds so you can check it '
        'gets through.',
      ),
      findsOneWidget,
    );
    expect(calls, isEmpty, reason: 'nothing is scheduled before Send');
    await expectA11yGuidelines(tester);
    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(calls, ['send']);
    now = now.add(const Duration(seconds: 18));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Ringing in 42 s…'), findsOneWidget);
    now = now.add(const Duration(seconds: 42));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Did it ring?'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pump();
    expect(find.text('Look at the checks.'), findsOneWidget);
    expect(calls, ['send'], reason: 'it rang or not: nothing to cancel');
  });

  testWidgets('leaving before it rings cancels it', (tester) async {
    await tester.pumpWidget(testApp(card()));
    await tester.tap(find.text('Send me a test alarm'));
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pump();
    await tester.pumpWidget(testApp(const SizedBox.shrink()));
    expect(calls, ['send', 'cancel']);
  });

  testWidgets('Cancel while waiting takes it back', (tester) async {
    await tester.pumpWidget(testApp(card()));
    await tester.tap(find.text('Send me a test alarm'));
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(calls, ['send', 'cancel']);
    expect(find.text('Send'), findsNothing);
  });
}
