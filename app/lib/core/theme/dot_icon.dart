import 'package:dottoday/core/theme/dot_glyphs.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:flutter/widgets.dart';

/// Draws a [DotGlyph] (docs/10 §3 "Icon set"): stroke 2 on the 24-unit
/// grid, 2.4 when [active], 2.8 when [bold], round caps and joins, scaled
/// to [size].
///
/// Decorative: it adds no semantics. The control around it carries the
/// label (an icon is never the only description of an action).
class DotIcon extends StatelessWidget {
  const DotIcon(
    this.glyph, {
    required this.color,
    this.size = DotSize.navIcon,
    this.active = false,
    this.bold = false,
    this.filled = false,
    super.key,
  });

  final DotGlyph glyph;
  final Color color;
  final double size;

  /// Selected tab / chosen icon: the heavier 2.4 stroke.
  final bool active;

  /// A task dot's icon: the bold [boldStroke] (ADR-0015).
  final bool bold;

  /// Painted solid (even-odd, so a gear keeps its hole) under the stroke:
  /// the bold nav icons (ADR-0015).
  final bool filled;

  /// Stroke width in grid units.
  static const double stroke = 2;
  static const double activeStroke = 2.4;
  static const double boldStroke = 2.8;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _GlyphPainter(
          glyph: glyph,
          color: color,
          filled: filled,
          stroke: bold
              ? boldStroke
              : active
              ? activeStroke
              : stroke,
        ),
      ),
    );
  }
}

final class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.glyph,
    required this.color,
    required this.stroke,
    this.filled = false,
  });

  final DotGlyph glyph;
  final Color color;
  final double stroke;
  final bool filled;

  static const _grid = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _grid;
    canvas
      ..save()
      ..scale(scale);
    if (filled) {
      canvas.drawPath(
        Path.from(glyph.path)..fillType = PathFillType.evenOdd,
        Paint()..color = color,
      );
    }
    canvas.drawPath(
      glyph.path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.stroke != stroke ||
      old.filled != filled;
}
