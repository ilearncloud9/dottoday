import 'dart:math' as math;

import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_sky_scope.dart';
import 'package:flutter/material.dart';

/// A mission on the dawn sky (E-R2-19-B "Mission at dawn", ED-314; tablets
/// E-R2-19-B-2, ED-336): the time at the top, the mission and its words,
/// then Can't right now. On an expanded landscape window (a tablet) the
/// mission sits on the left and the time and its line on the right, Can't
/// right now centred under both. [ground] lies on the sky behind
/// everything (Walk's walker, Light's room light); [over] floats above it
/// (Catch the dot's dots). With [groundLine] (Walk), the words keep above
/// the walker standing on that share of the height, so large text scrolls
/// instead of running under it. The time keeps its display size, as on the
/// ringing screen (ED-459 option A); everything else follows the text size.
class DawnScaffold extends StatelessWidget {
  const DawnScaffold({
    required this.time,
    required this.title,
    required this.mission,
    required this.cantRightNow,
    this.over,
    this.ground,
    this.groundLine,
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

  /// Where a figure stands on [ground], as a share of the height (Walk).
  final double? groundLine;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final size = MediaQuery.sizeOf(context);
    final wide =
        AppLayout.classOf(context) == WidthClass.expanded &&
        size.width > size.height;
    final timeText = Text(
      time,
      textScaler: TextScaler.noScaling,
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
      decoration: BoxDecoration(gradient: DawnSkyScope.of(context).gradient),
      child: Stack(
        children: [
          if (ground case final g?) Positioned.fill(child: g),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _aboveGround(
                    context,
                    Align(
                      alignment: switch ((wide, groundLine)) {
                        (true, _) => Alignment.center,
                        // Walk: where the full height's -0.6 put it, in
                        // the room above the walker.
                        (_, _?) => const Alignment(0, 0.25),
                        _ => const Alignment(0, -0.6),
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(DotSpace.l),
                        child: body,
                      ),
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

  /// [content] kept above the figure on the ground line, if there is one:
  /// its top is the safe area's, its foot a gap above the figure's head.
  Widget _aboveGround(BuildContext context, Widget content) {
    final line = groundLine;
    if (line == null) return content;
    final screen = MediaQuery.sizeOf(context).height;
    final top = MediaQuery.paddingOf(context).top;
    final room = screen * line - DotSize.dawnWalker - DotSpace.m - top;
    return LayoutBuilder(
      builder: (context, box) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: math.max(0, math.min(box.maxHeight, room)),
          child: content,
        ),
      ),
    );
  }
}

/// The mission ring on the sky (E-R2-19-B): a faint track, the progress in
/// the App colour's dark-surface shade at 3:1 against the sky
/// ([DawnSky.ring]), and [child] in the middle. [scale] grows and shrinks
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
    final color = DawnSkyScope.of(context).ring(t.colors.accent, _height);
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
