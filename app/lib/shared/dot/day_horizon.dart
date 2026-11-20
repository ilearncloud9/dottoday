import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/horizon_dot.dart';
import 'package:dottoday/shared/dot/horizon_labels.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

export 'package:dottoday/shared/dot/horizon_dot.dart';

/// Minimal's horizon (E rules §3 "Horizon", §5.3; ED-241): the thread
/// laid flat from Wake Up to Wind Down, 3 px. Behind now it is solid, in
/// each task's colour where a task ran; ahead it is dotted. Each task is
/// a 14 px dot cut out of the line by the ground; the caps are plain
/// discs; the teal now-bead sits at now. Labels under it: Wake Up, now
/// (bold, teal), the middle hour and Wind Down. One stop for screen
/// readers, [label]; a tap is [onTap] (Today, on phones). A right-click
/// on a dot is [onDotMenu] with that dot's index (the Mac and web pane,
/// E-Minimal frame 1); the tasks stay reachable by keyboard in the Day
/// column.
class DayHorizon extends StatelessWidget {
  const DayHorizon({
    required this.dots,
    required this.wakeUtc,
    required this.windDownUtc,
    required this.nowUtc,
    required this.labels,
    required this.label,
    this.hint,
    this.onTap,
    this.onDotMenu,
    super.key,
  });

  final List<HorizonDot> dots;
  final DateTime wakeUtc;
  final DateTime windDownUtc;
  final DateTime nowUtc;

  /// Wake Up, now, the middle hour and Wind Down, as shown: "7 AM",
  /// "10:42", "3 PM", "11 PM"; the middle one's time is [labels].mid.
  final HorizonLabels labels;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final void Function(int index, Offset global)? onDotMenu;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: onTap != null,
      label: label,
      hint: hint,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: DotSize.horizonHeight,
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final at = _Scale(wakeUtc, windDownUtc, w);
              // The dot under a right-click, within its own width.
              int? hit(double x) {
                int? best;
                var gap = DotSize.horizonDot.toDouble();
                for (final (i, d) in dots.indexed) {
                  final g = (at.x(d.startUtc) - x).abs();
                  if (g <= gap) (best, gap) = (i, g);
                }
                return best;
              }

              final style = t.styles.threadMeta.copyWith(color: t.colors.muted);
              final menu = onDotMenu;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onSecondaryTapUp: menu == null
                    ? null
                    : (e) {
                        if (hit(e.localPosition.dx) case final i?) {
                          menu(i, e.globalPosition);
                        }
                      },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _HorizonPainter(
                          dots: dots,
                          at: at,
                          nowUtc: nowUtc,
                          colors: t.colors,
                          tasks: t.tasks,
                        ),
                      ),
                    ),
                    ...horizonLabels(
                      t,
                      labels,
                      nowX: at.x(nowUtc),
                      midX: at.x(labels.midUtc),
                      width: w,
                      style: style,
                      scaler: MediaQuery.textScalerOf(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Times to x along the line, the dots' radius kept in at both ends.
final class _Scale {
  const _Scale(this.from, this.to, this.width);

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

class _HorizonPainter extends CustomPainter {
  const _HorizonPainter({
    required this.dots,
    required this.at,
    required this.nowUtc,
    required this.colors,
    required this.tasks,
  });

  final List<HorizonDot> dots;
  final _Scale at;
  final DateTime nowUtc;
  final DotColors colors;
  final TaskPalette tasks;

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
  bool shouldRepaint(_HorizonPainter old) =>
      old.nowUtc != nowUtc ||
      old.dots != dots ||
      old.colors != colors ||
      old.at.width != at.width;
}
