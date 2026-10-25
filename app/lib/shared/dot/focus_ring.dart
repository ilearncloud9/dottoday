import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Focus's ring (`B-ios-focus`, 11 A3): the share of the dot's planned
/// time gone, filling clockwise from the top in the task's colour around
/// its icon. The sweep eases between seconds; with reduced motion it jumps
/// (`DotMotion.reduced`). Decorative: the screen says the time in words.
class FocusRing extends StatelessWidget {
  const FocusRing({
    required this.progress,
    required this.color,
    required this.icon,
    super.key,
  });

  /// 0–1.
  final double progress;
  final TaskColor color;
  final TaskIcon icon;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final glyph = icon.glyph;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: DotSize.focusRing,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress.clamp(0, 1)),
          duration: t.motion.slow,
          curve: t.motion.curve,
          builder: (context, sweep, child) => CustomPaint(
            painter: _RingPainter(
              sweep: sweep,
              color: swatch.color,
              track: t.colors.hairline,
              inner: t.colors.raised,
            ),
            child: child,
          ),
          child: Center(
            child: glyph == null
                ? null
                : DotIcon(
                    glyph,
                    color: swatch.color,
                    size: DotSize.focusGlyph,
                    active: true,
                  ),
          ),
        ),
      ),
    );
  }
}

final class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.sweep,
    required this.color,
    required this.track,
    required this.inner,
  });

  final double sweep;
  final Color color;
  final Color track;
  final Color inner;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = DotSize.focusRingStroke;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2;
    canvas.drawCircle(center, radius - stroke / 2, Paint()..color = inner);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, paint..color = track);
    if (sweep <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * sweep,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.sweep != sweep ||
      old.color != color ||
      old.track != track ||
      old.inner != inner;
}
