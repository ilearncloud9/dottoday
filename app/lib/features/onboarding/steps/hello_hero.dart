import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Hello's day dot (prototype `vHello`): five coloured parts of a day
/// draw round the ring in turn, the centre pops with the time and "NOW",
/// the thread drops out of it and three dots land on it. Drawn on the
/// prototype's 300 × 330 grid; [progress] is the time since Hello opened
/// (1 = the whole drawing, [OnbMotion.hello]).
class HelloHero extends StatelessWidget {
  const HelloHero({
    required this.progress,
    required this.clock,
    required this.now,
    super.key,
  });

  final Animation<double> progress;

  /// The time now, as the user reads it ("9:41"), and its label ("NOW").
  final String clock;
  final String now;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: OnbSize.heroWidth,
        height: OnbSize.heroHeight,
        child: CustomPaint(
          painter: _HeroPainter(
            progress: progress,
            colors: t.colors,
            parts: [for (final c in _parts) t.tasks[c.$1].ring],
            dots: [for (final c in _dots) t.tasks[c].ring],
            clock: TextPainter(
              text: TextSpan(text: clock, style: t.styles.onbClock),
              textDirection: TextDirection.ltr,
            )..layout(),
            now: TextPainter(
              text: TextSpan(text: now, style: t.styles.onbNow),
              textDirection: TextDirection.ltr,
            )..layout(),
          ),
        ),
      ),
    );
  }
}

/// The ring's parts and their share (`parts` in `vHello`).
const _parts = [
  (TaskColor.amber, .16),
  (TaskColor.indigo, .24),
  (TaskColor.coral, .14),
  (TaskColor.sky, .2),
  (TaskColor.mint, .16),
];

/// The three dots on the thread (`.pd`).
const _dots = [TaskColor.coral, TaskColor.sky, TaskColor.mint];

/// The drawing's geometry, in the prototype's units.
abstract final class _G {
  static const cx = 150.0;
  static const cy = 120.0;
  static const r = 62.0;
  static const stroke = 14.0;
  static const gap = 14.0;
  static const trackAlpha = .45;
  static const core = 40.0;
  static const coreShadowY = 6.0;
  static const coreShadowBlur = 12.0;
  static const coreShadowAlpha = .12;
  static const lineTop = 196.0;
  static const lineEnd = 330.0;
  static const dash = 2.0;
  static const dashGap = 9.0;
  static const dashWidth = 4.0;
  static const threadWidth = 5.0;
  static const threadDash = 160.0;
  static const dotR = 9.0;
  static const dotYs = [236.0, 276.0, 316.0];
  static const clockBase = 124.0;
  static const nowBase = 142.0;
}

class _HeroPainter extends CustomPainter {
  _HeroPainter({
    required this.progress,
    required this.colors,
    required this.parts,
    required this.dots,
    required this.clock,
    required this.now,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final DotColors colors;
  final List<Color> parts;
  final List<Color> dots;
  final TextPainter clock;
  final TextPainter now;

  /// 0–1 of a stage that starts at [start] and lasts [length].
  double _stage(Duration start, Duration length) {
    final ms = progress.value * OnbMotion.hello.inMilliseconds;
    return ((ms - start.inMilliseconds) / length.inMilliseconds).clamp(0, 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _dashedLine(canvas);
    _ring(canvas);
    _core(canvas);
    _thread(canvas);
    for (var i = 0; i < dots.length; i++) {
      final p = OnbMotion.pop.transform(
        _stage(OnbMotion.dotStarts[i], OnbMotion.dotPop),
      );
      _pop(
        canvas,
        Offset(_G.cx, _G.dotYs[i]),
        _G.dotR,
        p,
        Paint()..color = dots[i],
      );
    }
  }

  void _dashedLine(Canvas canvas) {
    final paint = Paint()
      ..color = colors.outline
      ..strokeWidth = _G.dashWidth
      ..strokeCap = StrokeCap.round;
    for (var y = _G.lineTop; y < _G.lineEnd; y += _G.dash + _G.dashGap) {
      final end = math.min(y + _G.dash, _G.lineEnd);
      canvas.drawLine(Offset(_G.cx, y), Offset(_G.cx, end), paint);
    }
  }

  void _ring(Canvas canvas) {
    final rect = Rect.fromCircle(
      center: const Offset(_G.cx, _G.cy),
      radius: _G.r,
    );
    canvas.drawCircle(
      const Offset(_G.cx, _G.cy),
      _G.r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _G.stroke
        ..color = colors.outline.withValues(alpha: _G.trackAlpha),
    );
    const circumference = 2 * math.pi * _G.r;
    // Each part starts 5° after its share begins and is 14 shorter,
    // leaving room for the round caps (`rotate(a+5)`, `C*f-14`).
    var start = -90.0;
    for (var i = 0; i < parts.length; i++) {
      final share = _parts[i].$2;
      final length = circumference * share - _G.gap;
      final drawn = OnbMotion.draw.transform(
        _stage(OnbMotion.arcStart + OnbMotion.arcGap * i, OnbMotion.arc),
      );
      if (drawn > 0) {
        canvas.drawArc(
          rect,
          _rad(start + 5),
          length * drawn / _G.r,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = _G.stroke
            ..strokeCap = StrokeCap.round
            ..color = parts[i],
        );
      }
      start += share * 360;
    }
  }

  void _core(Canvas canvas) {
    final p = OnbMotion.pop.transform(
      _stage(OnbMotion.coreStart, OnbMotion.corePop),
    );
    const centre = Offset(_G.cx, _G.cy);
    if (p > 0) {
      canvas
        ..save()
        ..translate(_G.cx, _G.cy)
        ..scale(p)
        ..translate(-_G.cx, -_G.cy);
      final alpha = p.clamp(0.0, 1.0);
      canvas
        ..drawCircle(
          centre.translate(0, _G.coreShadowY),
          _G.core,
          Paint()
            ..color = colors.shadow.withValues(
              alpha: _G.coreShadowAlpha * alpha,
            )
            ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal,
              _G.coreShadowBlur / 2,
            ),
        )
        ..drawCircle(
          centre,
          _G.core,
          Paint()..color = colors.raised.withValues(alpha: alpha),
        )
        ..restore();
    }
    // The words are not part of the pop (`<text>` after `.core`).
    clock.paint(
      canvas,
      Offset(_G.cx - clock.width / 2, _G.clockBase - _baseline(clock)),
    );
    now.paint(
      canvas,
      Offset(_G.cx - now.width / 2, _G.nowBase - _baseline(now)),
    );
  }

  void _thread(Canvas canvas) {
    final p = OnbMotion.draw.transform(
      _stage(OnbMotion.threadStart, OnbMotion.thread),
    );
    // `stroke-dasharray:160` over a 134 line: it is whole at 134/160.
    final length = math.min(_G.lineEnd - _G.lineTop, _G.threadDash * p);
    if (length <= 0) return;
    canvas.drawLine(
      const Offset(_G.cx, _G.lineTop),
      Offset(_G.cx, _G.lineTop + length),
      Paint()
        ..color = colors.accent
        ..strokeWidth = _G.threadWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  void _pop(Canvas canvas, Offset c, double r, double p, Paint paint) {
    if (p <= 0) return;
    paint.color = paint.color.withValues(
      alpha: paint.color.a * p.clamp(0.0, 1.0),
    );
    canvas.drawCircle(c, r * p, paint);
  }

  static double _baseline(TextPainter p) =>
      p.computeDistanceToActualBaseline(TextBaseline.alphabetic);

  static double _rad(double deg) => deg * math.pi / 180;

  @override
  bool shouldRepaint(_HeroPainter old) =>
      old.colors != colors ||
      old.clock.text != clock.text ||
      old.now.text != now.text;
}
