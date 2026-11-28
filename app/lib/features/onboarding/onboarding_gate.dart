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
/// visible the whole time (prototype `.wide`), and on finishing the card
/// shrinks and fades as the blur clears (part 5, ED-490). Above the app's
/// navigator, so the flow has a navigator of its own for sheets and
/// dialogs. The app keeps its state throughout (one key wherever it sits).
class OnboardingGate extends ConsumerStatefulWidget {
  const OnboardingGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends ConsumerState<OnboardingGate>
    with SingleTickerProviderStateMixin {
  final _app = GlobalKey();
  late final _exit = AnimationController(vsync: this, duration: OnbMotion.blur);

  /// The card was up, so finishing plays its exit.
  var _carded = false;

  @override
  void dispose() {
    _exit.dispose();
    super.dispose();
  }

  void _leave() {
    if (_exit.isAnimating || _exit.isCompleted) return;
    if (DotTheme.of(context).motion.isReduced) _exit.duration = OnbMotion.fade;
    _exit.forward().whenComplete(() {
      if (mounted) setState(() => _carded = false);
    }).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final app = KeyedSubtree(key: _app, child: widget.child);
    final wide = onboardingInCard(MediaQuery.sizeOf(context));
    return switch (ref.watch(onboardingProvider)) {
      // AsyncValue, not AsyncData: a reload keeps the previous progress
      // instead of blanking the app or the flow (M5.5).
      AsyncValue(value: final p?) when !p.finished => () {
        _carded = wide;
        return wide
            ? _Card(app: app, exit: _exit)
            : Stack(
                children: [
                  // The app stays mounted, hidden, under the flow: its
                  // router must take links that arrive now. Unmounted, iOS
                  // dropped the sign-in link opened from the mail (M6.1).
                  Offstage(
                    child: TickerMode(
                      enabled: false,
                      child: ExcludeFocus(child: app),
                    ),
                  ),
                  const _FlowNavigator(),
                ],
              );
      }(),
      // You're in on a wide window: the card leaves first.
      AsyncValue(hasValue: true) when _carded => () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _leave();
        });
        return _Card(app: app, exit: _exit);
      }(),
      // Finished; or the record can't be read, which must not lock
      // anyone out of their tasks.
      AsyncValue(hasValue: true) || AsyncError() => app,
      _ => const ColoredBox(color: Colors.transparent),
    };
  }
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
/// touched, focused or read while the card is up. On [exit] (You're in)
/// the card shrinks to .94 over 600 ms and fades over 450 ms, the scrim
/// fades over 600 ms and the blur clears over 700 ms; with Reduce Motion
/// all of it cross-fades (200 ms), with no scaling.
class _Card extends StatelessWidget {
  const _Card({required this.app, required this.exit});

  final Widget app;
  final Animation<double> exit;

  /// [exit]'s progress through a stretch of [part] ms of the whole, eased.
  double _at(int part, Curve curve) {
    final whole = OnbMotion.blur.inMilliseconds;
    return curve.transform((exit.value * whole / part).clamp(0, 1));
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final reduced = t.motion.isReduced;
    final height = onboardingCardHeight(MediaQuery.sizeOf(context).height);
    final card = Container(
      key: OnbKeys.card,
      width: OnbSize.cardWidth,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.ground,
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
    );
    return AnimatedBuilder(
      animation: exit,
      child: card,
      builder: (context, card) {
        final out = exit.value > 0;
        final blur = reduced
            ? 1 - exit.value
            : 1 - _at(OnbMotion.blur.inMilliseconds, OnbMotion.standard);
        final scrim = reduced ? 1 - exit.value : 1 - _at(600, OnbMotion.ease);
        final shrink = reduced ? 0.0 : _at(600, OnbMotion.standard);
        final fade = reduced ? 1 - exit.value : 1 - _at(450, OnbMotion.ease);
        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: ExcludeFocus(
                child: ExcludeSemantics(
                  excluding: !out,
                  child: Transform.scale(
                    scale: 1 + (OnbSize.blurScale - 1) * (reduced ? 1 : blur),
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.compose(
                        outer: ui.ImageFilter.blur(
                          sigmaX: OnbSize.blur / 2 * blur,
                          sigmaY: OnbSize.blur / 2 * blur,
                        ),
                        inner: ColorFilter.matrix(
                          cssSaturate(1 - (1 - OnbSize.blurSaturation) * blur),
                        ),
                      ),
                      child: app,
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              ignoring: out,
              child: ColoredBox(
                color: c.scrim.withValues(
                  alpha: c.scrim.a * OnbSize.scrimOpacity * scrim,
                ),
              ),
            ),
            Center(
              child: IgnorePointer(
                ignoring: out,
                child: Opacity(
                  opacity: fade.clamp(0, 1),
                  child: Transform.translate(
                    offset: const Offset(0, OnbSize.cardDrop),
                    child: Transform.scale(
                      scale: 1 - (1 - OnbSize.cardExitScale) * shrink,
                      child: card,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
