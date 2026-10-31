import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// Dottoday's overlap (ADR-0015 knot amendment): the thread splits into
/// two strands, one per task, that cross once and join again. The dots
/// never change; only the thread says the two share time.
///
/// Paints the knot down [x] from [top] to [bottom]: [first] swings to one
/// side and [second] to the other, at most [sway] from [x], crossing
/// halfway.
void paintKnot(
  Canvas canvas, {
  required double x,
  required double top,
  required double bottom,
  required double sway,
  required double stroke,
  required Color first,
  required Color second,
}) {
  final h = bottom - top;
  // A cubic with its handles at ±c a third and two thirds down peaks at
  // 0.2887 c from the line, so this puts the peak at [sway].
  final c = sway / 0.2887;
  Path strand(double side) => Path()
    ..moveTo(x, top)
    ..cubicTo(
      x + side * c,
      top + h / 3,
      x - side * c,
      top + h * 2 / 3,
      x,
      bottom,
    );
  Paint paint(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = stroke
    ..strokeCap = StrokeCap.round;
  canvas
    ..drawPath(strand(-1), paint(first))
    ..drawPath(strand(1), paint(second));
}

/// The knot as a mark, where there is no thread to draw it on: the time
/// picker's caption, the Add sheet's landing line and proposal rows. The
/// same two strands as the day thread, in the two tasks' colours.
class OverlapKnot extends StatelessWidget {
  const OverlapKnot({required this.first, required this.second, super.key});

  final Color first;
  final Color second;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: const Size(DotSize.knotMarkWidth, DotSize.knotMark),
      painter: _KnotPainter(first, second),
    ),
  );
}

final class _KnotPainter extends CustomPainter {
  const _KnotPainter(this.first, this.second);

  final Color first;
  final Color second;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = DotSize.knotMarkStroke;
    paintKnot(
      canvas,
      x: size.width / 2,
      top: stroke / 2,
      bottom: size.height - stroke / 2,
      sway: size.width / 2 - stroke / 2,
      stroke: stroke,
      first: first,
      second: second,
    );
  }

  @override
  bool shouldRepaint(_KnotPainter old) =>
      old.first != first || old.second != second;
}
