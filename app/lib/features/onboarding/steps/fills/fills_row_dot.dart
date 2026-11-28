import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A row's dot (`.trow .dt`): the card colour, a 3 ring and the icon in
/// [color]. With [pop] it pops in from .6 through 1.15 (the spring).
class FillsRowDot extends StatelessWidget {
  const FillsRowDot({
    required this.color,
    required this.glyph,
    required this.iconSize,
    this.pop,
    this.filled = false,
    super.key,
  });

  final Color color;
  final DotGlyph? glyph;
  final double iconSize;
  final Animation<double>? pop;

  /// The nudge's subject: filled in [color], its icon in the card colour.
  final bool filled;

  /// The keyframes .6 → 1.15 → 1 with the spring over the whole of
  /// them, as the browser runs it: past the end it carries on below 1.
  static double scaleAt(double t) {
    final v = OnbMotion.pop.transform(t);
    if (v <= 0.5) {
      return OnbSize.landFrom + (OnbSize.landPeak - OnbSize.landFrom) * v / 0.5;
    }
    return OnbSize.landPeak + (1 - OnbSize.landPeak) * (v - 0.5) / 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final glyph = this.glyph;
    final dot = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : c.card,
        border: filled
            ? null
            : Border.all(color: color, width: OnbSize.rowRing),
      ),
      child: glyph == null
          ? null
          : Center(
              child: DotIcon(
                glyph,
                color: filled ? c.card : color,
                size: iconSize,
                bold: filled,
              ),
            ),
    );
    final pop = this.pop;
    if (pop == null) return ExcludeSemantics(child: dot);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: pop,
        builder: (_, child) =>
            Transform.scale(scale: scaleAt(pop.value), child: child),
        child: dot,
      ),
    );
  }
}
