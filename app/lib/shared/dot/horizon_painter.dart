import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_horizon.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

/// The horizon's times to x along the line, the dots' radius kept in at
/// both ends.
final class HorizonScale {
  const HorizonScale(this.from, this.to, this.width);

  final DateTime from;
  final DateTime to;
  final double width;

  double x(DateTime t) {
    const r = DotSize.horizonCap / 2;
    final span = to.difference(from).inSeconds;
    if (span <= 0) return r;
    final p = (t.difference(from).inSeconds / span).clamp(0.0, 1.0);
    return r + p * (width - 2 * r);
  }
}

/// Paints [DayHorizon]'s line, caps, dots, now-bead and focus ring.
class HorizonPainter extends CustomPainter {
  const HorizonPainter({
    required this.dots,
    required this.at,
    required this.nowUtc,
    required this.colors,
    required this.tasks,
    this.ring,
  });

  final List<HorizonDot> dots;
  final HorizonScale at;
  final DateTime nowUtc;
  final DotColors colors;
  final TaskPalette tasks;

  /// The keyboard's dot, ringed while the horizon has focus (ED-178).
  final int? ring;

  static const _y = DotSize.horizonCap / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final nowX = at.x(nowUtc);
    final line = Paint()
      ..strokeWidth = DotSize.horizonLine
      ..strokeCap = StrokeCap.round;
    // Ahead: dotted, from now to Wind Down.
    line.color = colors.threadAhead;
    const gap = DotSize.horizonLine * 2;
    for (var x = nowX; x < size.width; x += gap) {
      canvas.drawCircle(Offset(x, _y), DotSize.horizonLine / 2, line);
    }
    // Behind: solid, in each task's colour where one ran.
    canvas.drawLine(const Offset(0, _y), Offset(nowX, _y), line);
    for (final d in dots) {
      final from = at.x(d.startUtc);
      // Not begun yet: nothing behind now to colour.
      if (from >= nowX) continue;
      final to = math.min(at.x(d.endUtc), nowX);
      line.color = tasks[d.color].color;
      canvas.drawLine(Offset(from, _y), Offset(to, _y), line);
    }
    _caps(canvas, size);
    for (final d in dots) {
      _dot(canvas, at.x(d.startUtc), d);
    }
    _bead(canvas, nowX);
    if (ring case final i? when i < dots.length) {
      // 2 px of ground, then the 2 px accent ring (ED-178).
      canvas.drawCircle(
        Offset(at.x(dots[i].startUtc), _y),
        DotSize.horizonDot / 2 +
            DotSize.horizonCut +
            DotSize.smallDotOutline / 2,
        Paint()
          ..color = colors.accentText
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSize.smallDotOutline,
      );
    }
  }

  void _caps(Canvas canvas, Size size) {
    const r = DotSize.horizonCap / 2;
    canvas
      ..drawCircle(const Offset(r, _y), r, Paint()..color = colors.wakeCap)
      ..drawCircle(
        Offset(size.width - r, _y),
        r,
        Paint()..color = colors.windCap,
      );
  }

  void _dot(Canvas canvas, double x, HorizonDot d) {
    const r = DotSize.horizonDot / 2;
    final c = Offset(x, _y);
    final swatch = tasks[d.color];
    // The 2 px cut-out in the ground colour (a gap, never a halo).
    canvas.drawCircle(
      c,
      r + DotSize.horizonCut,
      Paint()..color = colors.ground,
    );
    switch (d.state) {
      case DotState.done:
        canvas.drawCircle(c, r, Paint()..color = swatch.color);
      case DotState.skipped || DotState.missed:
        _ring(canvas, c, colors.threadAhead);
      case DotState.live || DotState.upcoming:
        _ring(canvas, c, swatch.ring);
    }
  }

  void _ring(Canvas canvas, Offset c, Color color) {
    const w = DotSize.horizonRing;
    canvas
      ..drawCircle(c, DotSize.horizonDot / 2, Paint()..color = colors.ground)
      ..drawCircle(
        c,
        (DotSize.horizonDot - w) / 2,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w,
      );
  }

  void _bead(Canvas canvas, double x) {
    const r = DotSize.horizonDot / 2;
    final c = Offset(x, _y);
    canvas
      ..drawCircle(c, r, Paint()..color = colors.ground)
      ..drawCircle(c, r - DotSize.horizonCut, Paint()..color = colors.accent);
  }

  @override
  bool shouldRepaint(HorizonPainter old) =>
      old.nowUtc != nowUtc ||
      old.dots != dots ||
      old.colors != colors ||
      old.ring != ring ||
      old.at.width != at.width;
}
