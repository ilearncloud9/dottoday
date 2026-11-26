import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/flow/onb_buttons.dart';
import 'package:dottoday/features/onboarding/steps/hello_hero.dart';
import 'package:dottoday/shared/text/balanced_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Hello (prototype `vHello`; ED-305, ED-351): the day dot draws itself,
/// "Your day, as a thread.", Get started, I have an account, and "Dottoday
/// is for people aged 13+.". The drawing plays once; Reduce Motion shows
/// it complete and the words fade in.
class HelloStep extends ConsumerStatefulWidget {
  const HelloStep({required this.onStart, required this.onAccount, super.key});

  final VoidCallback onStart;
  final VoidCallback onAccount;

  @override
  ConsumerState<HelloStep> createState() => _HelloStepState();
}

class _HelloStepState extends ConsumerState<HelloStep>
    with SingleTickerProviderStateMixin {
  late final _play = AnimationController(
    vsync: this,
    duration: OnbMotion.hello,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_play.isAnimating || _play.isCompleted) return;
    if (DotTheme.of(context).motion.isReduced) {
      _play.value = 1;
    } else {
      _play.forward();
    }
  }

  @override
  void dispose() {
    _play.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final reduced = t.motion.isReduced;
    Widget rise(int i, Widget child) =>
        _Rise(play: _play, index: i, reduced: reduced, child: child);
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Semantics(
                    label: l10n.onboardingDotLabel,
                    image: true,
                    excludeSemantics: true,
                    child: Center(
                      child: HelloHero(
                        progress: _play,
                        clock: _clock(context),
                        now: l10n.onboardingHelloNow,
                      ),
                    ),
                  ),
                ),
                rise(
                  0,
                  Semantics(
                    header: true,
                    child: BalancedText(
                      l10n.onboardingWelcomeTitle,
                      style: t.styles.onbHero,
                      maxWidth: box.maxWidth,
                    ),
                  ),
                ),
                const SizedBox(height: OnbSize.subTop),
                rise(
                  1,
                  Text(
                    l10n.onboardingWelcomeBody,
                    style: t.styles.onbSub,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: OnbSize.ctaTop),
                rise(
                  2,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: OnbSize.ctaGap,
                    children: [
                      OnbPrimary(
                        label: l10n.onboardingGetStarted,
                        onPressed: widget.onStart,
                      ),
                      OnbSecondary(
                        label: l10n.onboardingSignIn,
                        onPressed: widget.onAccount,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: OnbSize.fineTop),
                rise(
                  3,
                  Text(
                    l10n.onboardingAgeNote,
                    style: t.styles.onbFine,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The time now in the user's clock, without AM/PM ("9:41").
  String _clock(BuildContext context) {
    final local = ref.watch(clockProvider).nowUtc().toLocal();
    final h24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Patterns, not words.
    final pattern = h24 ? 'HH:mm' : 'h:mm'; // l10n-ignore: date pattern
    return DateFormat(pattern, locale).format(local);
  }
}

/// The words rise 14 and fade in, 600 ms, emphasized decelerate, at
/// their own delays (`.rise`); with Reduce Motion they fade in, 200 ms.
class _Rise extends StatelessWidget {
  const _Rise({
    required this.play,
    required this.index,
    required this.reduced,
    required this.child,
  });

  final Animation<double> play;
  final int index;
  final bool reduced;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduced) {
      return _FadeIn(child: child);
    }
    final total = OnbMotion.hello.inMilliseconds;
    final start = OnbMotion.wordStarts[index].inMilliseconds / total;
    final end = start + OnbMotion.words.inMilliseconds / total;
    final eased = CurvedAnimation(
      parent: play,
      curve: Interval(start, end, curve: OnbMotion.decelerate),
    );
    return AnimatedBuilder(
      animation: eased,
      builder: (_, child) => Opacity(
        opacity: eased.value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - eased.value) * OnbMotion.wordRise),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Reduce Motion: a 200 ms fade (`.rm .rise{animation:fade .2s}`).
class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: OnbMotion.fade,
    builder: (_, v, child) => Opacity(opacity: v, child: child),
    child: child,
  );
}
