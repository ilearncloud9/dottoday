import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// How a dot is drawn in a [LayoutSketch].
enum SketchDot { done, live, next, later }

/// A link between two sketch dots: solid in a tint, or dotted.
enum SketchLink { solid, dotted }

/// A tiny thread on onboarding step 0's cards (the owner's render,
/// 2026-10-31): minimal is the live dot, the next and a faint later one;
/// full is a coloured day around the live dot. Decoration only.
final class LayoutSketch {
  const LayoutSketch._(this.dots, this.links, this.colors, this.gap);

  final List<SketchDot> dots;

  /// Between dot i and i + 1.
  final List<SketchLink> links;

  /// Each dot's task colour (null: the accent or the neutral ink).
  final List<TaskColor?> colors;

  /// Link length.
  final double gap;

  static const minimal = LayoutSketch._(
    [SketchDot.live, SketchDot.next, SketchDot.later],
    [SketchLink.solid, SketchLink.dotted],
    [null, null, null],
    DotSpace.xxl + DotSpace.l,
  );

  static const full = LayoutSketch._(
    [
      SketchDot.done,
      SketchDot.done,
      SketchDot.live,
      SketchDot.next,
      SketchDot.next,
      SketchDot.next,
    ],
    [
      SketchLink.solid,
      SketchLink.solid,
      SketchLink.solid,
      SketchLink.solid,
      SketchLink.solid,
    ],
    [
      TaskColor.coral,
      TaskColor.amber,
      null,
      TaskColor.slate,
      TaskColor.rose,
      TaskColor.teal,
    ],
    DotSpace.l + DotSpace.xxs,
  );
}

/// Paints [sketch] in the theme's colours.
class LayoutSketchView extends StatelessWidget {
  const LayoutSketchView({required this.sketch, super.key});

  final LayoutSketch sketch;

  static const _dot = DotSpace.xl - DotSpace.xxs;
  static const _live = DotSize.doneCircle;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final width =
        _live +
        _dot * (sketch.dots.length - 1) +
        sketch.gap * sketch.links.length;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, _live),
        painter: _SketchPainter(
          sketch: sketch,
          inks: [
            for (final c in sketch.colors) c == null ? null : t.tasks[c].color,
          ],
          accent: t.colors.accent,
          accentTint: t.colors.accentTint,
          neutral: t.colors.muted,
          faint: t.colors.hairline,
          fill: t.colors.raised,
          rtl: Directionality.of(context) == TextDirection.rtl,
        ),
      ),
    );
  }
}

final class _SketchPainter extends CustomPainter {
  const _SketchPainter({
    required this.sketch,
    required this.inks,
    required this.accent,
    required this.accentTint,
    required this.neutral,
    required this.faint,
    required this.fill,
    required this.rtl,
  });

  final LayoutSketch sketch;
  final List<Color?> inks;
  final Color accent;
  final Color accentTint;
  final Color neutral;
  final Color faint;
  final Color fill;
  final bool rtl;

  static const _stroke = DotSize.dotOutline;

  /// The live dot's share of its ring, as in the render.
  static const _liveShare = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    if (rtl) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    final cy = size.height / 2;
    var x = 0.0;
    for (final (i, dot) in sketch.dots.indexed) {
      final d = dot == SketchDot.live
          ? LayoutSketchView._live
          : LayoutSketchView._dot;
      final center = Offset(x + d / 2, cy);
      final ink = inks[i] ?? (dot == SketchDot.later ? faint : neutral);
      _dot(canvas, dot, center, d / 2, ink);
      x += d;
      if (i < sketch.links.length) {
        // A done dot leads with its own colour; otherwise the link takes
        // the colour of the dot it reaches (the render).
        final next = inks[i + 1] ?? (i == 0 ? accent : neutral);
        final tint = dot == SketchDot.done ? inks[i] ?? next : next;
        _link(canvas, sketch.links[i], x, x + sketch.gap, cy, tint);
        x += sketch.gap;
      }
    }
  }

  void _dot(Canvas canvas, SketchDot dot, Offset c, double r, Color ink) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    switch (dot) {
      case SketchDot.done:
        canvas.drawCircle(c, r, Paint()..color = ink);
      case SketchDot.live:
        canvas
          ..drawCircle(c, r - _stroke, Paint()..color = fill)
          ..drawCircle(c, r - _stroke, ring..color = accentTint)
          ..drawArc(
            Rect.fromCircle(center: c, radius: r - _stroke),
            -math.pi / 2,
            2 * math.pi * _liveShare,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = _stroke * 1.6
              ..strokeCap = StrokeCap.round
              ..color = accent,
          );
      case SketchDot.next:
        canvas
          ..drawCircle(c, r - _stroke / 2, Paint()..color = fill)
          ..drawCircle(c, r - _stroke / 2, ring..color = ink);
      case SketchDot.later:
        const dashes = 10;
        for (var k = 0; k < dashes; k++) {
          canvas.drawArc(
            Rect.fromCircle(center: c, radius: r - _stroke / 2),
            2 * math.pi * k / dashes,
            math.pi / dashes,
            false,
            ring..color = ink,
          );
        }
    }
  }

  void _link(
    Canvas canvas,
    SketchLink link,
    double from,
    double to,
    double y,
    Color ink,
  ) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = link == SketchLink.solid ? _stroke * 1.6 : _stroke * 0.8
      ..color = link == SketchLink.solid ? _tint(ink) : faint;
    if (link == SketchLink.solid) {
      canvas.drawLine(Offset(from, y), Offset(to, y), paint);
      return;
    }
    for (var x = from + _stroke; x < to - _stroke; x += _stroke * 2.4) {
      canvas.drawCircle(Offset(x, y), _stroke * 0.4, paint);
    }
  }

  /// A link reads as the tint of the dot it leaves (TaskAlpha.upcoming).
  Color _tint(Color ink) =>
      ink == accent ? accentTint : ink.withValues(alpha: TaskAlpha.upcoming);

  @override
  bool shouldRepaint(_SketchPainter old) =>
      old.sketch != sketch ||
      old.accent != accent ||
      old.fill != fill ||
      old.rtl != rtl ||
      old.neutral != neutral;
}
