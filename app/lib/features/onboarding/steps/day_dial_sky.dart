import 'dart:ui' as ui;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/rendering.dart';

/// What the dial draws under the sun and moon (prototype `.dial`
/// background, `.ticks` lines, `.rail2`, `.awake`, `.stars`): the sky
/// (night, dawn at the sun, the day, dusk at the moon, night), the hour
/// lines, the dashed thread, its awake part, and the stars above the sun
/// and below the moon. [sun], [moon] and [ticks] are heights in the dial.
class DayDialSky extends CustomPainter {
  const DayDialSky({
    required this.sun,
    required this.moon,
    required this.ticks,
    required this.sky,
    required this.ground,
    required this.accent,
    this.rtl = false,
  });

  final double sun;
  final double moon;
  final List<double> ticks;
  final OnbSky sky;
  final Color ground;
  final Color accent;

  /// Right to left: the thread and the hour lines from the right edge.
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (rtl) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    canvas.drawRect(rect, Paint()..shader = _sky(size).createShader(rect));
    _lines(canvas);
    _rail(canvas, size);
    canvas.drawRRect(
      RRect.fromLTRBR(
        OnbSize.rail - OnbSize.awakeWidth / 2,
        sun,
        OnbSize.rail + OnbSize.awakeWidth / 2,
        moon,
        const Radius.circular(OnbSize.awakeWidth / 2),
      ),
      Paint()..color = accent,
    );
    final above = (sun - OnbSize.starGap).clamp(0, size.height).toDouble();
    final below = (size.height - moon - OnbSize.starGap)
        .clamp(0, size.height)
        .toDouble();
    _stars(canvas, Rect.fromLTWH(0, 0, size.width, above), top: true);
    _stars(
      canvas,
      Rect.fromLTWH(0, size.height - below, size.width, below),
      top: false,
    );
  }

  /// The background's stops, as CSS places them: each no earlier than
  /// the one before, and cut to the dial with the colour found there.
  LinearGradient _sky(Size size) {
    final a = sun / size.height;
    final b = moon / size.height;
    final colors = [
      sky.night,
      sky.night,
      sky.dawn,
      ground,
      ground,
      sky.dusk,
      sky.night,
      sky.night,
    ];
    final stops = [
      0.0,
      a - OnbSize.skyNight,
      a,
      a + OnbSize.skyDay,
      b - OnbSize.skyDay,
      b,
      b + OnbSize.skyNight,
      1.0,
    ];
    for (var i = 1; i < stops.length; i++) {
      if (stops[i] < stops[i - 1]) stops[i] = stops[i - 1];
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        for (final (i, s) in stops.indexed)
          s >= 0 && s <= 1 ? colors[i] : _colorAt(stops, colors, s.clamp(0, 1)),
      ],
      stops: [for (final s in stops) s.clamp(0.0, 1.0)],
    );
  }

  /// The colour the stops give at [at] (a stop past the dial's end still
  /// shades it, as in CSS).
  static Color _colorAt(List<double> stops, List<Color> colors, double at) {
    for (var i = 1; i < stops.length; i++) {
      if (at > stops[i]) continue;
      final span = stops[i] - stops[i - 1];
      if (span <= 0) return colors[i];
      return Color.lerp(colors[i - 1], colors[i], (at - stops[i - 1]) / span)!;
    }
    return colors.last;
  }

  /// From each hour mark, a line fading out after 60 %, at .55.
  void _lines(Canvas canvas) {
    const line = Rect.fromLTWH(OnbSize.tickLine, 0, OnbSize.tickLineLength, 1);
    final ink = sky.line.withValues(alpha: OnbSize.tickLineOpacity);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        line.centerLeft,
        line.centerRight,
        [ink, ink, sky.line.withValues(alpha: 0)],
        [0, 0.6, 1],
      );
    for (final y in ticks) {
      canvas
        ..save()
        ..translate(0, y)
        ..drawRect(line, paint)
        ..restore();
    }
  }

  /// The thread: 4 wide, 5 on and 5 off, top to bottom.
  void _rail(Canvas canvas, Size size) {
    final paint = Paint()..color = sky.line;
    const left = OnbSize.rail - OnbSize.railWidth / 2;
    for (var y = 0.0; y < size.height; y += 2 * OnbSize.railDash) {
      canvas.drawRect(
        Rect.fromLTWH(left, y, OnbSize.railWidth, OnbSize.railDash),
        paint,
      );
    }
  }

  /// Two grids of small dots in [area], fading away from the sky's edge
  /// ([top]: solid to 40 %, then out; else in until 60 %).
  void _stars(Canvas canvas, Rect area, {required bool top}) {
    if (area.height <= 0) return;
    canvas
      ..save()
      ..clipRect(area)
      ..saveLayer(area, Paint());
    final dot = Paint()
      ..color = sky.star.withValues(alpha: OnbSize.starOpacity);
    for (final (w, h, x0, y0, r) in _grids) {
      for (var x = x0 - w; x < area.width + w; x += w) {
        for (var y = y0; y < area.height + h; y += h) {
          canvas.drawCircle(Offset(x, area.top + y), r, dot);
        }
      }
    }
    final clear = sky.star.withValues(alpha: 0);
    final solid = sky.star;
    canvas
      ..drawRect(
        area,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = ui.Gradient.linear(
            area.topCenter,
            area.bottomCenter,
            top ? [solid, solid, clear] : [clear, solid, solid],
            top
                ? [0, OnbSize.starsTopSolid, 1]
                : [0, OnbSize.starsBottomSolid, 1],
          ),
      )
      ..restore()
      ..restore();
  }

  /// The grids (`.stars` background): tile size, first dot, dot radius
  /// (between the solid edge and where it fades out).
  static const _grids = [
    (46.0, 34.0, 8.0 + 23, 6.0 + 17, 1.3),
    (29.0, 41.0, 21.0 + 14.5, 19.0 + 20.5, 1.05),
  ];

  @override
  bool shouldRepaint(DayDialSky old) =>
      old.sun != sun ||
      old.moon != moon ||
      old.sky != sky ||
      old.ground != ground ||
      old.accent != accent ||
      old.rtl != rtl ||
      !_same(old.ticks, ticks);

  static bool _same(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
