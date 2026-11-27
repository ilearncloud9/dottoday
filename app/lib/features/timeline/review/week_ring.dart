import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// A day of This week (E-R2-24 §1, ED-496): a ring in the accent, its arc
/// how much of the day's plan was done ([done] of [total]) over a faint
/// track. Drawn only: the column around it says the count and carries the
/// reading for screen readers.
class WeekRing extends StatelessWidget {
  const WeekRing({
    required this.done,
    required this.total,
    this.size = WeekSize.ring,
    this.stroke = WeekSize.ringStroke,
    super.key,
  });

  final int done;
  final int total;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            share: total == 0 ? 0 : (done / total).clamp(0, 1),
            track: WeekColors.track(c),
            arc: c.accent,
            stroke: stroke,
          ),
        ),
      ),
    );
  }
}

final class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.share,
    required this.track,
    required this.arc,
    required this.stroke,
  });

  final double share;
  final Color track;
  final Color arc;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawOval(rect, paint);
    if (share <= 0) return;
    paint
      ..color = arc
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * share, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.share != share ||
      old.track != track ||
      old.arc != arc ||
      old.stroke != stroke;
}
