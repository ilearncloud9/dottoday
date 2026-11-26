import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/flow/onb_keys.dart';
import 'package:flutter/material.dart';

/// The step's top row (prototype `.nav`): Back, then where you are as
/// three dots joined by bars, balanced by a space the width of Back.
/// Android has ← alone; Apple platforms and the web have ‹ Back. [at] is
/// 1–3, or null for a row with Back only (the account path).
class OnbNav extends StatelessWidget {
  const OnbNav({required this.onBack, this.at, super.key});

  final VoidCallback onBack;
  final int? at;

  @override
  Widget build(BuildContext context) {
    final android = _android(context);
    final at = this.at;
    return SizedBox(
      height: OnbSize.nav,
      child: Row(
        spacing: DotSpace.s,
        children: [
          _Back(onBack: onBack, android: android),
          if (at != null) Expanded(child: OnbProgress(at: at)),
          if (at != null)
            SizedBox(
              width: android ? OnbSize.navSpaceAndroid : OnbSize.navSpace,
            ),
        ],
      ),
    );
  }
}

bool _android(BuildContext context) =>
    !webChrome(context) && Theme.of(context).platform == TargetPlatform.android;

class _Back extends StatelessWidget {
  const _Back({required this.onBack, required this.android});

  final VoidCallback onBack;
  final bool android;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    if (android) {
      return IconButton(
        key: OnbKeys.back,
        tooltip: l10n.onboardingBack,
        onPressed: onBack,
        constraints: const BoxConstraints.tightFor(
          width: OnbSize.navSpaceAndroid,
          height: DotTouch.android,
        ),
        icon: DotIcon(DotGlyphs.arrowLeft, color: t.colors.text),
      );
    }
    final ink = t.colors.accentInk;
    return TextButton(
      key: OnbKeys.back,
      onPressed: onBack,
      style: TextButton.styleFrom(
        foregroundColor: ink,
        textStyle: t.styles.onbBack,
        minimumSize: const Size(DotTouch.min, DotTouch.min),
        padding: const EdgeInsetsDirectional.only(end: DotSpace.xs),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DotIcon(DotGlyphs.chevronLeft, color: ink, size: DotSize.rowIcon),
          Text(l10n.onboardingBack),
        ],
      ),
    );
  }
}

/// Three dots and two bars (prototype `.prog`): done dots filled, the
/// current one a ring, bars filling as you pass them. Read as "Step 2 of
/// 3".
class OnbProgress extends StatelessWidget {
  const OnbProgress({required this.at, super.key});

  /// 1–3.
  final int at;

  static const count = 3;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final reduced = t.motion.isReduced;
    return Semantics(
      label: context.l10n.onboardingStepOf(at, count),
      image: true,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var k = 1; k <= count; k++) ...[
            _Dot(done: k < at, current: k == at, reduced: reduced),
            if (k < count)
              SizedBox(
                width: OnbSize.bar,
                height: OnbSize.barHeight,
                child: ColoredBox(
                  color: c.outline,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: k < at ? 1 : 0),
                    duration: reduced ? Duration.zero : OnbMotion.bars,
                    curve: OnbMotion.standard,
                    builder: (_, f, _) => FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: f,
                      child: ColoredBox(color: c.accent),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.done,
    required this.current,
    required this.reduced,
  });

  final bool done;
  final bool current;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final size = current ? OnbSize.dotCurrent : OnbSize.dot;
    return AnimatedContainer(
      duration: reduced ? Duration.zero : OnbMotion.dots,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? c.accent : c.raised,
        border: done
            ? null
            : Border.all(
                color: current ? c.accent : c.outline,
                width: current ? OnbSize.dotRingCurrent : OnbSize.dotRing,
              ),
      ),
    );
  }
}
