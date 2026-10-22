// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/onboarding_gate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/onboarding_fakes.dart';
import '../../support/timeline_fakes.dart';

// Onboarding O1–O6 (derived, docs/10 §5.1, docs/09 M4).

List<Override> _at(OnboardingStep step) => [
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
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
  for (final step in [OnboardingStep.welcome]) {
    goldenMatrix(
      'onboarding_${step.name}',
      height: 844,
      widths: widths,
      overrides: _at(step),
      build: (_) => const OnboardingGate(child: SizedBox.shrink()),
    );
  }
}
