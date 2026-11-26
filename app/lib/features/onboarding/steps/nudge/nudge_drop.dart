import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The nudge's subject dropping onto its time (`.drop`, 620 ms): from 160
/// above, landing at 55 %, then one small bounce (up 12, down, up 3,
/// down), each stretch on the draw curve as CSS keyframes run. With
/// Reduce Motion it fades in where it is.
class NudgeDrop extends StatelessWidget {
  const NudgeDrop({required this.progress, required this.child, super.key});

  /// 0–1 over the drop.
  final Animation<double> progress;
  final Widget child;

  /// (time, height, opacity) keyframes.
  static const _keys = [
    (0.0, -OnbSize.dropFrom, 0.0),
    (0.55, 0.0, 1.0),
    (0.72, -OnbSize.dropBounce, 1.0),
    (0.86, 0.0, 1.0),
    (0.93, -OnbSize.dropBounceSmall, 1.0),
    (1.0, 0.0, 1.0),
  ];

  /// Height and opacity at [t].
  static (double, double) at(double t) {
    for (var i = 1; i < _keys.length; i++) {
      final (b, yb, ob) = _keys[i];
      if (t > b) continue;
      final (a, ya, oa) = _keys[i - 1];
      final u = OnbMotion.draw.transform(((t - a) / (b - a)).clamp(0, 1));
      return (ya + (yb - ya) * u, oa + (ob - oa) * u);
    }
    return (0, 1);
  }

  @override
  Widget build(BuildContext context) {
    if (DotTheme.of(context).motion.isReduced) {
      return FadeTransition(opacity: progress, child: child);
    }
    return AnimatedBuilder(
      animation: progress,
      builder: (_, child) {
        final (y, o) = at(progress.value);
        return Opacity(
          opacity: o,
          child: Transform.translate(offset: Offset(0, y), child: child),
        );
      },
      child: child,
    );
  }
}
