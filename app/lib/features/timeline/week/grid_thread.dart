import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/rendering.dart';

/// One task's dot on a column's thread: where its centre is, and the
/// colour the thread runs in from it to the next dot.
typedef GridThreadDot = ({double y, Color color});

/// A day column's thread on the hour grid (E-FullA-v2 Week): the 4 px line
/// behind the blocks, solid in each task's colour from its dot to the next
/// one up to now, dotted from now on. A past day is solid to its last
/// block's end; a later day is dotted from its first dot.
final class GridThread extends CustomPainter {
  const GridThread({
    required this.dots,
    required this.lastBottom,
    required this.nowY,
    required this.ahead,
  });

  /// The tasks' dots, top to bottom.
  final List<GridThreadDot> dots;

  /// The last block's bottom: a finished day's thread ends there.
  final double lastBottom;

  /// Now, in px down the axis: negative infinity on a later day, positive
  /// infinity on an earlier one.
  final double nowY;

  /// The dotted thread ahead of now.
  final Color ahead;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final paint = Paint()..strokeWidth = size.width;
    final first = dots.isEmpty ? 0.0 : dots.first.y;
    for (final (i, d) in dots.indexed) {
      if (d.y >= nowY) break;
      final next = i + 1 < dots.length ? dots[i + 1].y : lastBottom;
      final end = next < nowY ? next : nowY;
      canvas.drawLine(Offset(x, d.y), Offset(x, end), paint..color = d.color);
    }
    if (nowY >= size.height || (dots.isEmpty && nowY.isInfinite && nowY > 0)) {
      return;
    }
    final from = nowY > first ? nowY : first;
    final dot = Paint()..color = ahead;
    for (var y = from + x; y < size.height; y += DotSpace.s) {
      canvas.drawCircle(Offset(x, y), x, dot);
    }
  }

  @override
  bool shouldRepaint(GridThread old) =>
      old.nowY != nowY ||
      old.lastBottom != lastBottom ||
      old.ahead != ahead ||
      !_sameDots(old.dots, dots);

  static bool _sameDots(List<GridThreadDot> a, List<GridThreadDot> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
