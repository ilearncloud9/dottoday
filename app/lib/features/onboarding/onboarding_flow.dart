import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/steps/account_step.dart';
import 'package:dottoday/features/onboarding/steps/day_shape_step.dart';
import 'package:dottoday/features/onboarding/steps/done_step.dart';
import 'package:dottoday/features/onboarding/steps/habits_step.dart';
import 'package:dottoday/features/onboarding/steps/reminders_step.dart';
import 'package:dottoday/features/onboarding/steps/welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The onboarding steps O1–O6 (docs/10 §5.1) in one frame: Back, where
/// you are, Skip; the step below. Every step can be skipped (PRD F10).
class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(onboardingProvider).value;
    final step = progress?.step ?? OnboardingStep.welcome;
    final returning = progress?.returning ?? false;
    final store = ref.read(onboardingProvider.notifier);
    void go(OnboardingStep s, {bool? returning}) =>
        unawaited(store.go(s, returning: returning));
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  step: step,
                  onBack: () => go(step.previous),
                  onSkip: () => go(step.next),
                ),
                Expanded(child: _body(step, go, store.finish, returning)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    OnboardingStep step,
    void Function(OnboardingStep, {bool? returning}) go,
    Future<void> Function() finish,
    bool returning,
  ) => switch (step) {
    OnboardingStep.welcome => WelcomeStep(
      onStart: () => go(OnboardingStep.dayShape),
      onSignIn: () => go(OnboardingStep.account),
    ),
    OnboardingStep.dayShape => DayShapeStep(onNext: () => go(step.next)),
    OnboardingStep.habits => HabitsStep(onNext: () => go(step.next)),
    OnboardingStep.reminders => RemindersStep(onNext: () => go(step.next)),
    OnboardingStep.account => AccountStep(
      returning: returning,
      onNext: () => go(step.next),
    ),
    OnboardingStep.done => DoneStep(onFinish: finish),
  };
}

/// ‹, "Step 2 of 6" as dots, Skip. Nothing on the welcome.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.step,
    required this.onBack,
    required this.onSkip,
  });

  final OnboardingStep step;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    if (step == OnboardingStep.welcome) {
      return const SizedBox(height: DotTouch.android);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.onboardingBack,
            onPressed: onBack,
            icon: DotIcon(DotGlyphs.arrowLeft, color: t.colors.text),
          ),
          Expanded(child: _Dots(step: step)),
          if (step != OnboardingStep.done)
            TextButton(onPressed: onSkip, child: Text(l10n.onboardingSkip))
          else
            const SizedBox(width: DotTouch.android),
        ],
      ),
    );
  }
}

/// "Step 2 of 6" as dots, the ones done in accent.
class _Dots extends StatelessWidget {
  const _Dots({required this.step});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final total = OnboardingStep.values.length;
    return Semantics(
      label: context.l10n.onboardingStepOf(step.index + 1, total),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: DotSpace.xs,
        children: [
          for (var i = 0; i < total; i++)
            Container(
              width: DotSize.weekDot,
              height: DotSize.weekDot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= step.index ? t.colors.accent : t.colors.outline,
              ),
            ),
        ],
      ),
    );
  }
}
