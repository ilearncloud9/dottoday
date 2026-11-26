import 'dart:async';
import 'dart:math' as math;

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/onboarding/flow/onb_nav.dart';
import 'package:dottoday/features/onboarding/flow/onb_switcher.dart';
import 'package:dottoday/features/onboarding/steps/account_step.dart';
import 'package:dottoday/features/onboarding/steps/day_shape_step.dart';
import 'package:dottoday/features/onboarding/steps/habits_step.dart';
import 'package:dottoday/features/onboarding/steps/hello_step.dart';
import 'package:dottoday/features/onboarding/steps/reminders_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether onboarding shows as a card over the app (tablets, Mac and web;
/// prototype `.wide`) rather than full screen, for a window of [size]:
/// from the medium width class, when the window is tall enough for it.
bool onboardingInCard(Size size) =>
    size.width >= WidthClass.mediumFrom && size.height >= OnbSize.cardMinHeight;

/// The card's height in a window of [height]: 760, less in a short one.
double onboardingCardHeight(double height) =>
    math.min(OnbSize.cardHeight, height - 2 * DotSpace.l);

/// The approved onboarding (the "Dottoday Onboarding Prototype", ED-305;
/// M20.11, ED-485): Hello → Your day → What fills your days? → A nudge,
/// in context → You're in, each step changing with the prototype's motion.
/// Back and Esc go back on the three counted steps; Return continues.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  /// Whether the last change went back, for the step motion.
  var _back = false;

  Onboarding get _store => ref.read(onboardingProvider.notifier);

  void _go(OnboardingStep step, {bool account = false}) {
    final at = ref.read(onboardingProvider).value;
    // Leaving the account path goes back to Hello (`acct-back`).
    final leaving = at?.account ?? false;
    setState(() => _back = leaving || step.index < (at?.step.index ?? 0));
    if (step == OnboardingStep.today) {
      unawaited(_finish());
      return;
    }
    unawaited(_store.go(step, account: account));
  }

  /// You're in: done, and Today it is, wherever a link sent the app
  /// meanwhile (a sign-in callback shows Account, M6.1).
  Future<void> _finish() async {
    final router = ref.read(routerProvider);
    await _store.finish();
    router.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(onboardingProvider).value;
    final step = progress?.step ?? OnboardingStep.hello;
    final account = progress?.account ?? false;
    final card = onboardingInCard(MediaQuery.sizeOf(context));
    final view = account
        ? _View(
            key: const ValueKey('account'),
            onBack: () => _go(OnboardingStep.hello),
            child: AccountStep(returning: true, onNext: _finish),
          )
        : _View(
            key: ValueKey(step),
            at: step.dot,
            onBack: step.canGoBack ? () => _go(step.previous) : null,
            child: _body(step),
          );
    return Scaffold(
      backgroundColor: DotTheme.of(context).colors.surface,
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (account) return _go(OnboardingStep.hello);
            if (step.canGoBack) _go(step.previous);
          },
          const SingleActivator(LogicalKeyboardKey.enter): () {
            if (!account && !_typing()) _go(step.next);
          },
        },
        child: Focus(
          autofocus: true,
          child: SafeArea(
            minimum: card
                ? const EdgeInsets.fromLTRB(
                    OnbSize.cardSide,
                    OnbSize.cardTop,
                    OnbSize.cardSide,
                    OnbSize.cardBottom,
                  )
                : const EdgeInsets.fromLTRB(
                    OnbSize.side,
                    DotSpace.xs,
                    OnbSize.side,
                    OnbSize.bottom,
                  ),
            child: OnbSwitcher(back: _back, child: view),
          ),
        ),
      ),
    );
  }

  Widget _body(OnboardingStep step) {
    void next() => _go(step.next);
    return switch (step) {
      OnboardingStep.hello => HelloStep(
        onStart: next,
        onAccount: () => _go(OnboardingStep.hello, account: true),
      ),
      // Parts 2 to 4 (ED-485) replace these with the prototype's steps.
      OnboardingStep.day => DayShapeStep(onNext: next),
      OnboardingStep.fills => HabitsStep(onNext: next),
      OnboardingStep.nudge => RemindersStep(onNext: next),
      // Reaching it finishes (`_go`); part 5 shows the real Today here.
      OnboardingStep.today => const SizedBox.shrink(),
    };
  }

  /// Return in a text field is the field's (part 3's add field).
  static bool _typing() =>
      FocusManager.instance.primaryFocus?.context?.widget is EditableText;
}

/// One step: its top row (Back with the dots, when it has them), then the
/// step.
class _View extends StatelessWidget {
  const _View({required this.child, this.onBack, this.at, super.key});

  final Widget child;
  final VoidCallback? onBack;
  final int? at;

  @override
  Widget build(BuildContext context) {
    final onBack = this.onBack;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onBack != null) OnbNav(onBack: onBack, at: at),
        Expanded(child: child),
      ],
    );
  }
}
