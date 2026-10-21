import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The day dot in every header (docs/10 §3 `DayDot`, `Main`): a conic ring
/// filling from Wake Up to Bedtime with a small accent dot in the centre.
///
/// [progress] comes from `DayShape.progressAt(clock.nowUtc())`.
class DayDot extends StatelessWidget {
  const DayDot({required this.progress, this.size = DotSize.dayDot, super.key});

  /// 0–1 share of the waking day elapsed.
  final double progress;

  /// [DotSize.dayDot] (44), or [DotSize.dayDotWatch] (18).
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final share = progress.clamp(0.0, 1.0);
    return Semantics(
      label: context.l10n.dayDotLabel((share * 100).round()),
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: share),
        duration: t.motion.slow,
        curve: t.motion.curve,
        builder: (context, sweep, _) => CustomPaint(
          size: Size.square(size),
          painter: _DayDotPainter(
            sweep: sweep,
            track: t.colors.outline,
            accent: t.colors.accent,
          ),
        ),
      ),
    );
  }
}

final class _DayDotPainter extends CustomPainter {
  const _DayDotPainter({
    required this.sweep,
    required this.track,
    required this.accent,
  });

  final double sweep;
  final Color track;
  final Color accent;

  /// Ring and centre dot as shares of the diameter (`Main`: 9 / 10 px at 44).
  static const _ring = 0.2;
  static const _centre = 0.24;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.shortestSide;
    final c = size.center(Offset.zero);
    final ring = d * _ring;
    final rect = Rect.fromCircle(center: c, radius: (d - ring) / 2);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring;
    canvas.drawOval(rect, stroke..color = track);
    if (sweep > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * sweep,
        false,
        stroke..color = accent,
      );
    }
    canvas.drawCircle(c, d * _centre / 2, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_DayDotPainter old) =>
      old.sweep != sweep || old.track != track || old.accent != accent;
}
