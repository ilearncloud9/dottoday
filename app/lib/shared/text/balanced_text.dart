import 'package:flutter/material.dart';

/// Text whose lines are as even as they can be (CSS `text-wrap:
/// balance`, which the approved boards and prototypes use on titles):
/// the narrowest width within [maxWidth] that keeps the same number of
/// lines, centred (or at the start, for start-aligned text). It takes the width it may use rather than measuring
/// it, so it can sit in intrinsic layouts (a scrolling column).
///
/// ```dart
/// BalancedText('Your day, as a thread.', style: t.styles.onbHero,
///   maxWidth: 342);
/// // "Your day, / as a thread." rather than "Your day, as a / thread."
/// ```
class BalancedText extends StatelessWidget {
  const BalancedText(
    this.text, {
    required this.style,
    required this.maxWidth,
    this.textAlign = TextAlign.center,
    super.key,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      textAlign: textAlign,
    );
    final width = _balanced(painter, maxWidth);
    painter.dispose();
    return Align(
      alignment: textAlign == TextAlign.center
          ? Alignment.center
          : AlignmentDirectional.centerStart,
      child: SizedBox(
        width: width,
        child: Text(text, style: style, textAlign: textAlign),
      ),
    );
  }

  /// The narrowest width, to a pixel, with as many lines as [max] gives.
  static double _balanced(TextPainter p, double max) {
    if (!max.isFinite) return max;
    int lines(double w) {
      p.layout(maxWidth: w);
      return p.computeLineMetrics().length;
    }

    final target = lines(max);
    if (target < 2) return max;
    var lo = 0.0;
    var hi = max;
    while (hi - lo > 1) {
      final mid = (lo + hi) / 2;
      if (lines(mid) > target) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return hi;
  }
}
