import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "4½" planned hours to the nearest quarter (`CapacityRing`): digits and
/// a fraction glyph, no words.
String quarterHours(int minutes) {
  final quarters = (minutes / 15).round();
  final whole = quarters ~/ 4;
  const parts = ['', '¼', '½', '¾']; // l10n-ignore: fraction glyphs
  final part = parts[quarters % 4];
  if (whole == 0 && part.isNotEmpty) return part;
  return '$whole$part'; // l10n-ignore: a number, no words
}

/// A Week day's load (docs/10 §3 `CapacityRing`, `A-mac-week-alt3-board`):
/// a 38 px conic ring of planned time over the waking day, the planned
/// hours inside. [label] is the whole reading for screen readers.
class CapacityRing extends StatelessWidget {
  const CapacityRing({
    required this.share,
    required int this.plannedMinutes,
    required this.label,
    super.key,
  });

  /// [done] of [of] as the same ring with nothing inside (docs/13 §4.1,
  /// Settings › Learning): the count is the row's value beside it, so it
  /// grows with the text size instead of overflowing 38 px.
  const CapacityRing.count({
    required int done,
    required int of,
    required this.label,
    super.key,
  }) : share = of <= 0 ? 0 : done / of,
       plannedMinutes = null;

  /// Planned / awake, 0–1.
  final double share;

  /// The hours shown inside; null for a count ring.
  final int? plannedMinutes;
  final String label;

  static const double size = 38;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            share: share.clamp(0, 1),
            track: t.colors.outline,
            fill: t.colors.accent,
          ),
          child: Center(
            child: plannedMinutes == null
                ? null
                : Text(
                    quarterHours(plannedMinutes!),
                    style: t.styles.rowMeta.copyWith(
                      color: t.colors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

final class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.share,
    required this.track,
    required this.fill,
  });

  final double share;
  final Color track;
  final Color fill;

  static const double _stroke = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(rect, paint..color = track);
    if (share <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * share,
      false,
      paint..color = fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.share != share || old.track != track || old.fill != fill;
}
