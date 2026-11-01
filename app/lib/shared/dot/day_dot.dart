import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/day_dot_geometry.dart';
import 'package:flutter/material.dart';

/// The day dot in every header (docs/10 §3 `DayDot`, `Main`): a conic ring
/// filling from Wake Up to Wind Down with a small accent dot in the centre,
/// and the night from Wind Down round to the next Wake Up as a faint arc
/// (docs/15 W6). [geometry] is `dayDotGeometry`, the one every painter
/// reads; [nightLabel] ("Night · 7 h 45") is read out and shown on a
/// long-press.
class DayDot extends StatelessWidget {
  const DayDot({
    required this.geometry,
    this.size = DotSize.dayDot,
    this.nightLabel,
    super.key,
  });

  final DayDotGeometry geometry;
  final String? nightLabel;

  /// [DotSize.dayDot] (44), or [DotSize.dayDotWatch] (18).
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final g = geometry;
    final night = nightLabel;
    final dot = Semantics(
      // Its own node: never merged into the header beside it.
      container: true,
      label: [
        context.l10n.dayDotLabel((g.dayShare * 100).round()),
        ?night,
      ].join('. '), // l10n-ignore: joins two localised sentences
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: g.progress),
        duration: t.motion.slow,
        curve: t.motion.curve,
        builder: (context, sweep, _) => CustomPaint(
          size: Size.square(size),
          painter: _DayDotPainter(
            sweep: sweep,
            dayEnd: g.dayEnd,
            track: t.colors.outline,
            night: t.colors.night,
            accent: t.colors.accent,
          ),
        ),
      ),
    );
    if (night == null || !g.hasNight) return dot;
    return Tooltip(
      message: night,
      triggerMode: TooltipTriggerMode.longPress,
      child: dot,
    );
  }
}

final class _DayDotPainter extends CustomPainter {
  const _DayDotPainter({
    required this.sweep,
    required this.dayEnd,
    required this.track,
    required this.night,
    required this.accent,
  });

  final double sweep;
  final double dayEnd;
  final Color track;
  final Color night;
  final Color accent;

  /// Ring and centre dot as shares of the diameter (`Main`: 9 / 10 px at 44).
  static const _ring = 0.2;
  static const _centre = 0.24;

  /// The night's stroke as a share of the day's (docs/15 W6).
  static const _nightStroke = 0.45;
  static const _top = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.shortestSide;
    final c = size.center(Offset.zero);
    final ring = d * _ring;
    final rect = Rect.fromCircle(center: c, radius: (d - ring) / 2);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring;
    canvas.drawArc(
      rect,
      _top,
      2 * math.pi * dayEnd,
      false,
      stroke..color = track,
    );
    if (dayEnd < 1) {
      // Thinner, not just fainter: the night reads as night without colour.
      canvas.drawArc(
        rect,
        _top + 2 * math.pi * dayEnd,
        2 * math.pi * (1 - dayEnd),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring * _nightStroke
          ..color = night,
      );
    }
    if (sweep > 0) {
      canvas.drawArc(
        rect,
        _top,
        2 * math.pi * sweep,
        false,
        stroke..color = accent,
      );
    }
    canvas.drawCircle(c, d * _centre / 2, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_DayDotPainter old) =>
      old.sweep != sweep ||
      old.dayEnd != dayEnd ||
      old.track != track ||
      old.night != night ||
      old.accent != accent;
}
