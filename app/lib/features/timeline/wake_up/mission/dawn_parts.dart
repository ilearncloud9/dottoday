import 'dart:math' as math;

import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A mission on the dawn sky (E-R2-19-B "Mission at dawn", ED-314; tablets
/// E-R2-19-B-2, ED-336): the time at the top, the mission and its words,
/// then Can't right now. On an expanded landscape window (a tablet) the
/// mission sits on the left and the time and its line on the right, Can't
/// right now centred under both. [ground] lies on the sky behind
/// everything (Walk's walker, Light's room light); [over] floats above it
/// (Catch the dot's dots).
class DawnScaffold extends StatelessWidget {
  const DawnScaffold({
    required this.time,
    required this.title,
    required this.mission,
    required this.cantRightNow,
    this.over,
    this.ground,
    super.key,
  });

  final String time;

  /// "Walk 20 steps".
  final String title;

  /// The ring (or list) with its own words under it.
  final Widget mission;
  final Widget cantRightNow;
  final Widget? over;
  final Widget? ground;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final size = MediaQuery.sizeOf(context);
    final wide =
        AppLayout.classOf(context) == WidthClass.expanded &&
        size.width > size.height;
    final timeText = Text(
      time,
      style: t.styles.dawnTime,
      textAlign: wide ? TextAlign.start : TextAlign.center,
    );
    final titleText = Semantics(
      header: true,
      child: Text(
        title,
        style: t.styles.dawnTitle,
        textAlign: wide ? TextAlign.start : TextAlign.center,
      ),
    );
    final body = wide
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: DotSpace.xxl,
            children: [
              // A list (Pick today's one thing) needs a width to lay out in.
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: DotSize.wakeCardColumn,
                  ),
                  child: mission,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [timeText, titleText],
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.l,
            children: [timeText, mission, titleText],
          );
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: DotDawn.gradient),
      child: Stack(
        children: [
          if (ground case final g?) Positioned.fill(child: g),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: wide
                        ? Alignment.center
                        : const Alignment(0, -0.6),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(DotSpace.l),
                      child: body,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: DotSpace.xl),
                  child: cantRightNow,
                ),
              ],
            ),
          ),
          if (over case final o?) Positioned.fill(child: o),
        ],
      ),
    );
  }
}

/// The mission ring on the sky (E-R2-19-B): a faint track, the progress in
/// the App colour's dark-surface shade at 3:1 against the sky
/// ([DotDawn.ring]), and [child] in the middle. [scale] grows and shrinks
/// it (Breathe, Walk's step pulse).
class DawnRing extends StatelessWidget {
  const DawnRing({
    required this.progress,
    required this.child,
    this.fill = false,
    this.scale = 1,
    super.key,
  });

  /// 0–1.
  final double progress;
  final Widget child;

  /// Breathe: the inside glows with the ring's colour as it fills.
  final bool fill;
  final double scale;

  /// Roughly where the ring sits down the phone's sky.
  static const _height = 0.35;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final color = DotDawn.ring(t.colors.accent, _height);
    return SizedBox.square(
      dimension: DotSize.dawnRing,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: const Size.square(DotSize.dawnRing),
              painter: _RingPainter(
                progress: progress,
                color: color,
                fill: fill,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.fill,
  });

  final double progress;
  final Color color;
  final bool fill;

  /// The glow inside Breathe's ring at its fullest.
  static const _glow = 0.35;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = DotSize.dawnRingStroke;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = DotDawn.track,
    );
    if (fill) {
      canvas.drawOval(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: _glow),
              color.withValues(alpha: _glow * progress),
            ],
          ).createShader(rect),
      );
    }
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.fill != fill;
}

/// Walk's walker on the ground line (E-R2-19-B `wk-walker`): it crosses
/// the sky and comes straight back in from the other edge with no pause,
/// legs and arms swinging and the body bobbing with each step, for as long
/// as the challenge runs. At the end ([done]) it stands in the middle with
/// a check. Reduced motion: it stands still in the middle.
class DawnWalker extends StatefulWidget {
  const DawnWalker({required this.done, super.key});

  final bool done;

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
    final check = DotDawn.ring(t.colors.accent, _WalkerPainter.groundAt);
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

  /// The ground line's height, as a share of the screen.
  static const groundAt = 0.74;

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
    final ground = size.height * groundAt;
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

/// Light: the room brightening round the bulb (E-R2-19-B `ms-lit`), a warm
/// wash from the top of the sky at [level] (0–1).
class DawnRoomLight extends StatelessWidget {
  const DawnRoomLight({required this.level, super.key});

  final double level;

  /// How bright the room gets once it is light enough (`ms-lit` .55).
  static const _full = 0.55;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: level * _full),
      duration: DotTheme.of(context).motion.isReduced
          ? Duration.zero
          : DotDawnMotion.glow,
      curve: DotDawnMotion.easeInOut,
      builder: (context, opacity, _) => Opacity(
        opacity: opacity,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 0.7,
              colors: [DotDawn.roomLight, DotDawn.roomLightClear],
            ),
          ),
        ),
      ),
    ),
  );
}
