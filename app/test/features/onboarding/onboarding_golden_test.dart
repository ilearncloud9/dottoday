// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/onboarding_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/account_fakes.dart';
import '../../support/dot_golden.dart';
import '../../support/first_thread_rows.dart';
import '../../support/onboarding_fakes.dart';
import '../../support/timeline_fakes.dart';

// Onboarding O1–O6 (derived, docs/10 §5.1, docs/09 M4).

List<Override> _at(OnboardingStep step) => [
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
    occurrences: FakeOccurrenceRepository(
      step == OnboardingStep.done ? firstThreadRows() : const [],
    ),
    profile: testProfile(),
  ),
  onboardingProvider.overrideWith(
    () => FakeOnboarding(OnboardingProgress(step: step)),
  ),
];

void main() {
  // The overrides are built as the tests are declared.
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  const widths = {'compact', 'expanded'};
  for (final step in [
    OnboardingStep.welcome,
    OnboardingStep.dayShape,
    OnboardingStep.habits,
    OnboardingStep.reminders,
    OnboardingStep.account,
    OnboardingStep.done,
  ]) {
    goldenMatrix(
      'onboarding_${step.name}',
      height: 844,
      widths: widths,
      overrides: _at(step),
      build: (_) => const OnboardingGate(child: SizedBox.shrink()),
    );
  }
  // M4.7 states, with accounts on.
  final accounts = FakeAccountService();
  goldenMatrix(
    'onboarding_check_mail',
    height: 844,
    widths: widths,
    overrides: [
      ..._at(OnboardingStep.account),
      accountServiceProvider.overrideWithValue(accounts),
    ],
    act: (tester) async {
      await tester.tap(find.text('Continue with email'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'kody@example.com');
      await tester.tap(find.text('Send me a link'));
    },
    build: (_) => const OnboardingGate(child: SizedBox.shrink()),
  );
  goldenMatrix(
    'onboarding_restoring',
    height: 844,
    widths: widths,
    overrides: [
      ..._at(OnboardingStep.account),
      accountServiceProvider.overrideWithValue(accounts),
    ],
    act: (tester) async {
      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();
      accounts.restore.add(const RestoreProgress(done: 120, total: 300));
      await tester.pump();
    },
    build: (_) => const OnboardingGate(child: SizedBox.shrink()),
  );
}
