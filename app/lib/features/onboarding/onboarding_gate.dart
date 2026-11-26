import 'dart:ui' as ui;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/features/onboarding/flow/css_saturate.dart';
import 'package:dottoday/features/onboarding/flow/onb_keys.dart';
import 'package:dottoday/features/onboarding/onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First run on this device (docs/09 M4, M20.11): the onboarding flow in
/// front of [child] (the app) until it is finished. On phones the flow is
/// the whole screen and the app waits hidden under it; on tablets, Mac and
/// web the steps sit in a card over your own Today, blurred and dimmed,
/// visible the whole time (prototype `.wide`). Above the app's navigator,
/// so the flow has a navigator of its own for sheets and dialogs.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(onboardingProvider)) {
        // AsyncValue, not AsyncData: a reload keeps the previous progress
        // instead of blanking the app or the flow (M5.5).
        AsyncValue(value: final p?) when !p.finished =>
          onboardingInCard(MediaQuery.sizeOf(context))
              ? _Card(app: child)
              : Stack(
                  children: [
                    // The app stays mounted, hidden, under the flow: its router
                    // must take links that arrive now. Unmounted, iOS dropped
                    // the sign-in link opened from the mail (M6.1).
                    Offstage(
                      child: TickerMode(
                        enabled: false,
                        child: ExcludeFocus(child: child),
                      ),
                    ),
                    const _FlowNavigator(),
                  ],
                ),
        // Finished; or the record can't be read, which must not lock
        // anyone out of their tasks.
        AsyncValue(hasValue: true) || AsyncError() => child,
        _ => const ColoredBox(color: Colors.transparent),
      };
}

/// Its own navigator beside the app's: no hero controller to share.
class _FlowNavigator extends StatelessWidget {
  const _FlowNavigator();

  @override
  Widget build(BuildContext context) => HeroControllerScope.none(
    child: Navigator(
      onGenerateRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => const OnboardingFlow()),
    ),
  );
}

/// The steps in a 440 × 760 card, 8 below centre, over the app blurred
/// 16, at .85 saturation and 1.03 scale, under the scrim at .6
/// (prototype `.card`, `.back-app.blur`, `.wscrim`). The app can't be
/// touched, focused or read while the card is up.
class _Card extends StatelessWidget {
  const _Card({required this.app});

  final Widget app;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final height = onboardingCardHeight(MediaQuery.sizeOf(context).height);
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ExcludeFocus(
            child: ExcludeSemantics(
              child: Transform.scale(
                scale: OnbSize.blurScale,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.compose(
                    outer: ui.ImageFilter.blur(
                      sigmaX: OnbSize.blur / 2,
                      sigmaY: OnbSize.blur / 2,
                    ),
                    inner: ColorFilter.matrix(
                      cssSaturate(OnbSize.blurSaturation),
                    ),
                  ),
                  child: app,
                ),
              ),
            ),
          ),
        ),
        ColoredBox(
          color: c.scrim.withValues(alpha: c.scrim.a * OnbSize.scrimOpacity),
        ),
        Center(
          child: Transform.translate(
            offset: const Offset(0, OnbSize.cardDrop),
            child: Container(
              key: OnbKeys.card,
              width: OnbSize.cardWidth,
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(OnbSize.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: c.shadow.withValues(alpha: OnbSize.cardShadowAlpha),
                    offset: const Offset(0, OnbSize.cardShadowY),
                    blurRadius: OnbSize.cardShadowBlur,
                    spreadRadius: OnbSize.cardShadowSpread,
                  ),
                ],
              ),
              child: const _FlowNavigator(),
            ),
          ),
        ),
      ],
    );
  }
}
