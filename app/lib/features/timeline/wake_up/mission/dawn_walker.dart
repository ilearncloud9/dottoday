import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_sky_scope.dart';
import 'package:flutter/material.dart';

/// Walk's walker on the ground line (E-R2-19-B `wk-walker`): it crosses
/// the sky and comes straight back in from the other edge with no pause,
/// legs and arms swinging and the body bobbing with each step, for as long
/// as the challenge runs. At the end ([done]) it stands in the middle with
/// a check. Reduced motion: it stands still in the middle.
class DawnWalker extends StatefulWidget {
  const DawnWalker({required this.done, super.key});

  final bool done;

  /// The ground line's height, as a share of the screen (E-R2-19-B).
  static const groundAt = 0.74;

  @override
  State<DawnWalker> createState() => _DawnWalkerState();
}

class _DawnWalkerState extends State<DawnWalker> with TickerProviderStateMixin {
  late final _cross = AnimationController(
    vsync: this,
    duration: DotDawnMotion.walkCross,
  );
  late final _gait = AnimationController(
    vsync: this,
    duration: DotDawnMotion.walkGait,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(DawnWalker old) {
    super.didUpdateWidget(old);
    _sync();
  }

  bool get _moving => !widget.done && !DotTheme.of(context).motion.isReduced;

  void _sync() {
    for (final c in [_cross, _gait]) {
      if (_moving && !c.isAnimating) c.repeat();
      if (!_moving) c.stop();
    }
  }

  @override
  void dispose() {
    _cross.dispose();
    _gait.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final check = DawnSkyScope.of(
      context,
    ).ring(t.colors.accent, DawnWalker.groundAt);
    final moving = _moving;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: Listenable.merge([_cross, _gait]),
        builder: (context, _) => CustomPaint(
          painter: _WalkerPainter(
            along: moving ? _cross.value : null,
            gait: moving ? _gait.value : null,
            done: widget.done,
            check: check,
          ),
        ),
      ),
    );
  }
}

class _WalkerPainter extends CustomPainter {
  const _WalkerPainter({
    required this.along,
    required this.gait,
    required this.done,
    required this.check,
  });

  /// 0–1 across the sky, or null standing in the middle.
  final double? along;

  /// 0–1 through a stride (legs, arms; the body bobs twice), or null still.
  final double? gait;
  final bool done;
  final Color check;

  /// The board's figure: drawn in a 24 × 48 box, 44 × 88 on the phone.
  static const _box = 48.0;
  static const _width = 24.0;
  static const _stroke = 3.2;

  /// Legs and arms swing ±26° and ±30° (`wkLegA`, `wkArmA`); the body bobs
  /// up 3 (`wkBob`).
  static const _leg = 26 * math.pi / 180;
  static const _arm = 30 * math.pi / 180;
  static const _bob = 3.0;

  /// Where it stands at the end: just left of the middle (175 of 390).
  static const _mid = 0.45;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height * DawnWalker.groundAt;
    canvas.drawLine(
      Offset(0, ground),
      Offset(size.width, ground),
      Paint()
        ..color = DotDawn.ground
        ..strokeWidth = DotSpace.hairline,
    );
    final k = DotSize.dawnWalker / _box;
    final w = _width * k;
    final x = switch (along) {
      final a? => -w + (size.width + w) * a,
      null => size.width * _mid,
    };
    final g = gait;
    final swing = g == null ? 0.0 : 1 - 2 * _there(g);
    final bob = g == null ? 0.0 : -_bob * _there(2 * g % 1);
    canvas
      ..save()
      ..translate(x, ground - DotSize.dawnWalker + bob)
      ..scale(k);
    final line = Paint()
      ..color = DotDawn.ink
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final faint = Paint()
      ..color = DotDawn.ink.withValues(alpha: 0.7)
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas
      ..drawCircle(const Offset(12, 6), 4.5, Paint()..color = DotDawn.ink)
      ..drawLine(const Offset(12, 12), const Offset(12, 31), line);
    if (done) {
      // Arms and legs apart, a check at the shoulder (`wk-done`).
      canvas
        ..drawLine(const Offset(12, 15), const Offset(6, 24), line)
        ..drawLine(const Offset(12, 15), const Offset(18, 24), line)
        ..drawLine(const Offset(12, 31), const Offset(8, 46), line)
        ..drawLine(const Offset(12, 31), const Offset(16, 46), line)
        ..drawCircle(const Offset(26, 7), 7, Paint()..color = check)
        ..drawPath(
          Path()
            ..moveTo(22.8, 6.8)
            ..lineTo(25, 9)
            ..lineTo(29.2, 4.4),
          Paint()
            ..color = DotDawn.inkDark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
    } else {
      void limb(Offset from, double length, double angle, Paint p) =>
          canvas.drawLine(
            from,
            from + Offset(math.sin(angle) * length, math.cos(angle) * length),
            p,
          );
      limb(const Offset(12, 15), 12, _arm * swing, line);
      limb(const Offset(12, 15), 12, -_arm * swing, faint);
      limb(const Offset(12, 31), 15, -_leg * swing, line);
      limb(const Offset(12, 31), 15, _leg * swing, faint);
    }
    canvas.restore();
  }

  /// How far through a there-and-back keyframe (0% → 50% → 100%) [t] is,
  /// eased like the board's `ease-in-out`: 0 at both ends, 1 halfway. The
  /// limbs sit at full swing at 0% and 50% (`wkLegA`), so they never close.
  static double _there(double t) =>
      DotDawnMotion.easeInOut.transform(t < 0.5 ? t * 2 : (1 - t) * 2);

  @override
  bool shouldRepaint(_WalkerPainter old) =>
      old.along != along ||
      old.gait != gait ||
      old.done != done ||
      old.check != check;
}
