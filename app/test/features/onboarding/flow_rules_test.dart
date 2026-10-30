import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/onboarding_harness.dart';

// The flow rules (PRD F10, docs/09 M4.8).

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('at most three steps ask for input, in either flow', () {
    for (final minimal in [true, false]) {
      expect(
        OnboardingStep.flow(minimal: minimal).where((s) => s.asksForInput),
        hasLength(lessThanOrEqualTo(3)),
        reason: 'minimal: $minimal',
      );
    }
  });

  test('minimal is three steps after the layout choice (docs/14 §7)', () {
    final flow = OnboardingStep.minimalFlow;
    expect(flow.sublist(flow.indexOf(OnboardingStep.layout) + 1), [
      OnboardingStep.dayShape,
      OnboardingStep.reminders,
      OnboardingStep.firstTask,
    ]);
  });

  testWidgets('every step after the welcome can be skipped', (tester) async {
    final c = await pumpOnboarding(
      tester,
      progress: const OnboardingProgress(step: OnboardingStep.dayShape),
    );
    for (final expected in [
      OnboardingStep.habits,
      OnboardingStep.reminders,
      OnboardingStep.account,
      OnboardingStep.done,
    ]) {
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(stepOf(c), expected);
    }
    await tester.ensureVisible(find.text('Open today'));
    await tester.tap(find.text('Open today'));
    await tester.pumpAndSettle();
    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('without an account, start to Today', (tester) async {
    await pumpOnboarding(tester);
    Future<void> tap(String text) async {
      final f = find.text(text);
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
      await tester.tap(f.first);
      await tester.pumpAndSettle();
    }

    await tap('Get started');
    await tap('The full planner');
    await tap('Continue');
    await tap('Continue');
    await tap('Continue');
    // Notifications are already allowed in the fakes: O4 offers the test
    // alarm and Continue (M6.5.9).
    await tap('Continue');
    await tap('Continue without an account');
    await tap('Open today');
    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('minimal: start to Today with Add open in three steps', (
    tester,
  ) async {
    final c = await pumpOnboarding(tester);
    Future<void> tap(String text) async {
      final f = find.text(text);
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
      await tester.tap(f.first);
      await tester.pumpAndSettle();
    }

    await tap('Get started');
    // Minimal is preselected: Continue keeps it.
    await tap('Continue');
    expect(stepOf(c), OnboardingStep.dayShape);
    await tap('Continue');
    expect(stepOf(c), OnboardingStep.reminders);
    // No calendar to connect: minimal asks for nothing with a default.
    expect(find.text('Connect a calendar'), findsNothing);
    await tap('Continue');
    expect(stepOf(c), OnboardingStep.firstTask);
    await tap('Put it on today');
    expect(find.text('the app'), findsOneWidget);
  });
}
