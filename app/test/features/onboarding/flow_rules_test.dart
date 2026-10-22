import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/onboarding_harness.dart';

// The flow rules (PRD F10, docs/09 M4.8).

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('at most three steps ask for input', () {
    expect(
      OnboardingStep.values.where((s) => s.asksForInput),
      hasLength(lessThanOrEqualTo(3)),
    );
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
    await tap('Continue');
    await tap('Continue');
    await tap('Not now');
    await tap('Continue without an account');
    await tap('Open today');
    expect(find.text('the app'), findsOneWidget);
  });
}
