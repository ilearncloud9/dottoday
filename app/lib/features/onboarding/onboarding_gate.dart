import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/features/onboarding/onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First run on this device (docs/09 M4, PRD F10): the onboarding flow in
/// front of [child] (the app) until it is finished or skipped through.
/// Above the app's navigator, so the flow has a navigator of its own for
/// tooltips, sheets and dialogs.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(
    onboardingProvider,
  )) {
    // AsyncValue, not AsyncData: a reload keeps the previous progress
    // instead of blanking the app or the flow (M5.5).
    AsyncValue(value: final p?) when !p.finished => Stack(
      children: [
        // The app stays mounted, hidden, under the flow: its router
        // must take links that arrive now. Unmounted, iOS dropped the
        // sign-in link opened from the mail in O5 (M6.1).
        Offstage(
          child: TickerMode(enabled: false, child: ExcludeFocus(child: child)),
        ),
        // Its own navigator beside the app's: no hero controller to share
        // (the flow has no heroes).
        HeroControllerScope.none(
          child: Navigator(
            onGenerateRoute: (_) =>
                MaterialPageRoute<void>(builder: (_) => const OnboardingFlow()),
          ),
        ),
      ],
    ),
    // Finished; or the record can't be read, which must not lock
    // anyone out of their tasks.
    AsyncValue(hasValue: true) || AsyncError() => child,
    _ => const ColoredBox(color: Colors.transparent),
  };
}
