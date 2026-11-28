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
    this.size = DotSize.focusRing,
    super.key,
  }) : screen = false;

  /// The Focus screen's ring (E-R2-9): a 15 stroke on a track of the
  /// task's colour, no disc inside, the glyph at 64 in its plain stroke.
  const FocusRing.screen({
    required this.progress,
    required this.color,
    required this.icon,
    this.size = DotSize.focusScreenRing,
    super.key,
  }) : screen = true;

  /// 0–1.
  final double progress;
  final TaskColor color;
  final TaskIcon icon;

  /// [DotSize.focusRing], or [DotSize.missionRing]; the stroke scales.
  final double size;

  /// The Focus screen's look ([FocusRing.screen]).
  final bool screen;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final glyph = icon.glyph;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress.clamp(0, 1)),
          duration: t.motion.slow,
          curve: t.motion.curve,
          builder: (context, sweep, child) => CustomPaint(
            painter: _RingPainter(
              sweep: sweep,
              color: swatch.color,
              track: screen
                  ? swatch.color.withValues(alpha: TaskAlpha.focusTrack)
                  : t.colors.threadAhead,
              inner: screen ? null : t.colors.card,
              stroke: screen
                  ? DotSize.focusScreenStroke
                  : DotSize.focusRingStroke * size / DotSize.focusRing,
            ),
            child: child,
          ),
          child: Center(
            child: glyph == null
                ? null
                : DotIcon(
                    glyph,
                    color: swatch.color,
                    size: screen
                        ? DotSize.focusScreenGlyph
                        : DotSize.focusGlyph * size / DotSize.focusRing,
                    active: !screen,
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
    required this.stroke,
  });

  final double sweep;
  final Color color;
  final Color track;
  final Color? inner;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2;
    if (inner case final fill?) {
      canvas.drawCircle(center, radius - stroke / 2, Paint()..color = fill);
    }
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
      old.inner != inner ||
      old.stroke != stroke;
}
