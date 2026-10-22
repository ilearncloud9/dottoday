import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Onboarding at [progress], in memory (docs/09 M4).
final class FakeOnboarding extends Onboarding {
  FakeOnboarding([this.progress = OnboardingProgress.start]);

  final OnboardingProgress progress;

  @override
  Future<OnboardingProgress> build() async => progress;

  @override
  Future<void> go(OnboardingStep step) async =>
      state = AsyncData(OnboardingProgress(step: step));

  @override
  Future<void> finish() async => state = const AsyncData(
    OnboardingProgress(step: OnboardingStep.done, finished: true),
  );
}

/// For app-level tests that start on Today: onboarding already done.
final Override onboarded = onboardingProvider.overrideWith(
  () => FakeOnboarding(
    const OnboardingProgress(step: OnboardingStep.done, finished: true),
  ),
);
