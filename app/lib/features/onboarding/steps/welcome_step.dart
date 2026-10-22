import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:flutter/material.dart';

/// O1 Welcome (docs/10 §5.1, docs/09 M4.1): the day dot draws itself,
/// "Your day, as a thread.", Get started / I already have an account.
/// With reduced motion the dot is simply full (the theme's motion is 0).
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({required this.onStart, required this.onSignIn, super.key});

  final VoidCallback onStart;
  final VoidCallback onSignIn;

  static const _dot = DotSize.dayDot * 3;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DotSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.l,
        children: [
          const SizedBox(height: DotSpace.xxl),
          const Center(child: _DrawingDot(size: _dot)),
          const SizedBox(height: DotSpace.l),
          Semantics(
            header: true,
            child: Text(
              l10n.onboardingWelcomeTitle,
              style: t.styles.pageTitle,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            l10n.onboardingWelcomeBody,
            style: t.styles.body.copyWith(color: t.colors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DotSpace.l),
          FilledButton(
            onPressed: onStart,
            child: Text(l10n.onboardingGetStarted),
          ),
          TextButton(onPressed: onSignIn, child: Text(l10n.onboardingSignIn)),
        ],
      ),
    );
  }
}

/// The day dot filling from empty to full once (the `DayDot`'s own
/// animation, started after the first frame).
class _DrawingDot extends StatefulWidget {
  const _DrawingDot({required this.size});

  final double size;

  @override
  State<_DrawingDot> createState() => _DrawingDotState();
}

/// A leaf: only the dot's fill.
class _DrawingDotState extends State<_DrawingDot> {
  var _fill = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _fill = 1);
    });
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.onboardingDotLabel,
    image: true,
    excludeSemantics: true,
    child: DayDot(progress: _fill, size: widget.size),
  );
}
