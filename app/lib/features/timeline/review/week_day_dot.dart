import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:flutter/material.dart';

/// One day of the weekly review (`B-ios-week-review`, 11 D1): a ring split
/// into the day's tasks by length, each in its colour — done solid, not
/// done faint — with [centre] inside. Colour is never the only signal: the
/// count says it, and the caller gives the whole reading to screen readers.
class WeekDayDot extends StatelessWidget {
  const WeekDayDot({
    required this.dots,
    required this.diameter,
    this.centre,
    this.selected = false,
    super.key,
  });

  final List<SnapshotDot> dots;
  final double diameter;

  /// "5/7", or nothing (the share image, large text).
  final String? centre;

  /// The day whose thread is open: a halo in the accent tint.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    // The halo is painted outside the dot, so selecting a day never
    // shrinks it inside its column.
    final halo = selected ? DotSize.weekReviewHalo * 2 : 0.0;
    return SizedBox.square(
      dimension: diameter,
      child: CustomPaint(
        painter: _RingPainter(
          segments: [
            for (final d in dots)
              (
                minutes: d.durationMin,
                color: d.done
                    ? t.tasks[TaskColor.fromKey(d.colorKey)].color
                    : t.tasks[TaskColor.fromKey(d.colorKey)].upcomingSegment,
              ),
          ],
          track: t.colors.outline,
          halo: selected ? t.colors.accentTint : null,
          haloWidth: halo,
          stroke:
              diameter * DotSize.weekReviewStroke / DotSize.weekReviewDotMax,
        ),
        child: Center(
          child: centre == null
              ? null
              : Text(
                  centre!,
                  style: t.styles.rowMeta.copyWith(
                    color: t.colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

typedef _Segment = ({int minutes, Color color});

final class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.segments,
    required this.track,
    required this.halo,
    required this.haloWidth,
    required this.stroke,
  });

  final List<_Segment> segments;
  final Color track;
  final Color? halo;
  final double haloWidth;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final ring = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    if (halo case final h?) {
      canvas.drawOval(
        (Offset.zero & size).inflate(haloWidth / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = haloWidth
          ..color = h,
      );
    }
    final total = segments.fold(0, (s, x) => s + x.minutes);
    if (total == 0) {
      canvas.drawOval(ring, paint..color = track);
      return;
    }
    // A small gap between tasks, none for a single task.
    final gap = segments.length == 1 ? 0.0 : DotSize.weekReviewGap;
    var angle = -math.pi / 2;
    for (final s in segments) {
      final sweep = 2 * math.pi * s.minutes / total;
      canvas.drawArc(
        ring,
        angle + gap / 2,
        math.max(sweep - gap, gap / 2),
        false,
        paint..color = s.color,
      );
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.segments != segments ||
      old.track != track ||
      old.halo != halo ||
      old.haloWidth != haloWidth ||
      old.stroke != stroke;
}

/// The diameter of a day with [minutes] planned when the busiest day has
/// [max]: square-root scaled (area follows hours), between [min] and
/// [maxSize].
double weekDotDiameter(
  int minutes,
  int max, {
  required double min,
  required double maxSize,
}) {
  if (max <= 0 || minutes <= 0) return min;
  return min + (maxSize - min) * math.sqrt(minutes / max);
}
