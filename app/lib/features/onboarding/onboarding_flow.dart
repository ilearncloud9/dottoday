import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/layout/feature_id.dart';
import 'package:dottoday/features/layout/layout_actions.dart';
import 'package:dottoday/features/layout/layout_providers.dart';
import 'package:dottoday/features/onboarding/steps/account_step.dart';
import 'package:dottoday/features/onboarding/steps/day_shape_step.dart';
import 'package:dottoday/features/onboarding/steps/done_step.dart';
import 'package:dottoday/features/onboarding/steps/first_task_step.dart';
import 'package:dottoday/features/onboarding/steps/habits_step.dart';
import 'package:dottoday/features/onboarding/steps/layout_step.dart';
import 'package:dottoday/features/onboarding/steps/reminders_step.dart';
import 'package:dottoday/features/onboarding/steps/welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The onboarding steps O1–O6 (docs/10 §5.1) in one frame: Back, where
/// you are, Skip; the step below. Every step can be skipped (PRD F10).
/// Step 0 picks the layout (docs/14 §4); minimal then runs three steps and
/// ends on Today with Add open.
class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(onboardingProvider).value;
    final step = progress?.step ?? OnboardingStep.welcome;
    final returning = progress?.returning ?? false;
    final store = ref.read(onboardingProvider.notifier);
    final minimal = watchSimplified(ref, FeatureId.onboarding);
    void go(OnboardingStep s, {bool? returning}) =>
        unawaited(store.go(s, returning: returning));
    void next() => step.isLastIn(minimal: minimal)
        ? unawaited(_finish(ref, add: true))
        : go(step.nextIn(minimal: minimal));
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
                  steps: OnboardingStep.flow(minimal: minimal),
                  onBack: () => go(step.previousIn(minimal: minimal)),
                  onSkip: next,
                ),
                Expanded(
                  child: _body(
                    context,
                    step,
                    go,
                    next,
                    () => _finish(ref),
                    returning,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Open today": done, and Today it is, wherever a link sent the app
  /// meanwhile (a sign-in callback shows Account, M6.1). With [add]
  /// (minimal's first task), Today opens with Add up (`/add`, M9.2c).
  Future<void> _finish(WidgetRef ref, {bool add = false}) async {
    final router = ref.read(routerProvider);
    await ref.read(onboardingProvider.notifier).finish();
    router.go(add ? AppRoutes.add : AppRoutes.today);
  }

  Widget _body(
    BuildContext context,
    OnboardingStep step,
    void Function(OnboardingStep, {bool? returning}) go,
    VoidCallback next,
    Future<void> Function() finish,
    bool returning,
  ) => switch (step) {
    OnboardingStep.welcome => WelcomeStep(
      // A new install starts with minimal preselected (docs/14 §7, owner
      // 2026-10-30); step 0 shows it chosen and can change it.
      onStart: () {
        setLayout(context, minimal: true);
        go(OnboardingStep.layout, returning: false);
      },
      // "Welcome back" on O5 (M4.7; the flag was never set, found M6.1).
      onSignIn: () => go(OnboardingStep.account, returning: true),
    ),
    OnboardingStep.layout => LayoutStep(onNext: next),
    OnboardingStep.dayShape => DayShapeStep(onNext: next),
    OnboardingStep.habits => HabitsStep(onNext: next),
    OnboardingStep.reminders => RemindersStep(onNext: next),
    OnboardingStep.account => AccountStep(returning: returning, onNext: next),
    OnboardingStep.firstTask => FirstTaskStep(onAdd: next),
    OnboardingStep.done => DoneStep(onFinish: finish),
  };
}

/// ‹, "Step 2 of 6" as dots, Skip. Nothing on the welcome.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.step,
    required this.steps,
    required this.onBack,
    required this.onSkip,
  });

  final OnboardingStep step;

  /// This flow's steps, for the dots.
  final List<OnboardingStep> steps;
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
          Expanded(
            child: _Dots(step: step, steps: steps),
          ),
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
  const _Dots({required this.step, required this.steps});

  final OnboardingStep step;
  final List<OnboardingStep> steps;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final total = steps.length;
    final at = steps.indexOf(step);
    return Semantics(
      label: context.l10n.onboardingStepOf(at + 1, total),
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
                color: i <= at ? t.colors.accent : t.colors.outline,
              ),
            ),
        ],
      ),
    );
  }
}
