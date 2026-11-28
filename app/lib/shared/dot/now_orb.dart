import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Minimal's orb, the large now-dot (E rules §5.3, ED-106: one drawing on
/// every platform, on a 232 viewBox): a raised disc, the task's track and
/// its elapsed arc, a hairline, the centre tinted, and in it the task's
/// icon, the [numeral] (800 at 0.36 of the orb) with its [unit] and the
/// [caption]. With no [color] it is the open day's: a plain track, no
/// arc. [size] is the iPhone's 236 or Android's 228 (Mac and web, 6c).
class NowOrb extends StatelessWidget {
  const NowOrb({
    required this.numeral,
    required this.caption,
    required this.size,
    this.unit,
    this.color,
    this.icon,
    this.progress = 0,
    super.key,
  });

  final String numeral;

  /// "h" beside the numeral, smaller.
  final String? unit;
  final String caption;
  final double size;
  final TaskColor? color;
  final TaskIcon? icon;

  /// The share of the task gone, 0–1.
  final double progress;

  static const _box = 232.0;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final swatch = switch (color) {
      final k? => t.tasks[k],
      null => null,
    };
    final k = size / _box;
    final numeral = t.styles.pageTitle.copyWith(
      fontSize: size * 0.36,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: -0.05 * size * 0.36,
      color: c.ink,
    );
    final caption = t.styles.rowMeta.copyWith(
      fontWeight: FontWeight.w600,
      color: c.secondary,
    );
    final glyph = icon?.glyph;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _OrbPainter(
            k: k,
            disc: c.card,
            hairline: c.hairline,
            track: swatch?.color.withValues(alpha: TaskAlpha.track) ?? c.sunk,
            arc: swatch?.ring,
            centre:
                swatch?.color.withValues(alpha: TaskAlpha.orbCentre) ?? c.sunk,
            shadow: (swatch?.color ?? c.ink).withValues(
              alpha: TaskAlpha.orbShadow,
            ),
            progress: progress.clamp(0, 1),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (glyph != null && swatch != null)
                  DotIcon(glyph, color: swatch.ring, size: DotSize.rowIcon),
                // The numeral keeps its size at any text size (ED-170): it
                // is the orb's own drawing, and the orb's spoken label
                // says it (`NowBody`).
                Text.rich(
                  textScaler: TextScaler.noScaling,
                  TextSpan(
                    text: this.numeral,
                    children: [
                      if (unit case final u?)
                        TextSpan(
                          text: u,
                          style: numeral.copyWith(
                            fontSize: numeral.fontSize! / 2,
                          ),
                        ),
                    ],
                  ),
                  style: numeral,
                ),
                Text(this.caption, style: caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  const _OrbPainter({
    required this.k,
    required this.disc,
    required this.hairline,
    required this.track,
    required this.arc,
    required this.centre,
    required this.shadow,
    required this.progress,
  });

  /// The size over the 232 viewBox.
  final double k;
  final Color disc;
  final Color hairline;
  final Color track;
  final Color? arc;
  final Color centre;
  final Color shadow;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // r112 disc with its soft shadow (0 18 40).
    canvas
      ..drawCircle(
        c.translate(0, 18 * k),
        112 * k,
        Paint()
          ..color = shadow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * k),
      )
      ..drawCircle(c, 112 * k, Paint()..color = disc);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12 * k
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, 100 * k, ring..color = track);
    if (arc case final a? when progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: 100 * k),
        -math.pi / 2,
        progress * 2 * math.pi,
        false,
        ring..color = a,
      );
    }
    canvas
      ..drawCircle(
        c,
        84 * k,
        Paint()
          ..color = hairline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      )
      ..drawCircle(c, 74 * k, Paint()..color = centre);
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.progress != progress ||
      old.arc != arc ||
      old.track != track ||
      old.k != k ||
      old.disc != disc;
}
