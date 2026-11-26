import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/rendering.dart';

/// The thread under the rows (`.tline`, `.tpast`): 4 wide at [x] from
/// [top] to [bottom], in the accent down to [now].
class FillsThreadLine extends CustomPainter {
  const FillsThreadLine({
    required this.x,
    required this.top,
    required this.bottom,
    required this.now,
    required this.line,
    required this.past,
    this.rtl = false,
  });

  /// The thread's middle (98, more at large text).
  final double x;
  final double top;
  final double bottom;
  final double now;
  final Color line;
  final Color past;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (rtl) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    const r = Radius.circular(OnbSize.threadWidth / 2);
    final left = x - OnbSize.threadWidth / 2;
    canvas.drawRRect(
      RRect.fromLTRBR(left, top, left + OnbSize.threadWidth, bottom, r),
      Paint()..color = line,
    );
    if (now <= top) return;
    canvas.drawRRect(
      RRect.fromLTRBR(left, top, left + OnbSize.threadWidth, now, r),
      Paint()..color = past,
    );
  }

  @override
  bool shouldRepaint(FillsThreadLine old) =>
      old.x != x ||
      old.top != top ||
      old.bottom != bottom ||
      old.now != now ||
      old.line != line ||
      old.past != past ||
      old.rtl != rtl;
}

/// NOW's line (`.nowm::before`): from [from] to the edge, 2 high, coral at
/// .55, over the dots; it stops 4 short of any row's words it would
/// cross ([cuts], ED-488).
class FillsNowLine extends CustomPainter {
  const FillsNowLine({
    required this.from,
    required this.now,
    required this.color,
    required this.cuts,
    this.rtl = false,
  });

  /// Where it starts (86, more at large text).
  final double from;
  final double now;
  final Color color;
  final List<Rect> cuts;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (rtl) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    final paint = Paint()
      ..color = color.withValues(alpha: OnbSize.nowLineAlpha);
    final spans = [(from, size.width)];
    for (final c in cuts) {
      final from = c.left - OnbSize.nowGap;
      final to = c.right + OnbSize.nowGap;
      final next = <(double, double)>[];
      for (final (a, b) in spans) {
        if (to <= a || from >= b) {
          next.add((a, b));
          continue;
        }
        if (from > a) next.add((a, from));
        if (to < b) next.add((to, b));
      }
      spans
        ..clear()
        ..addAll(next);
    }
    const half = OnbSize.nowLineHeight / 2;
    for (final (a, b) in spans) {
      canvas.drawRect(Rect.fromLTRB(a, now - half, b, now + half), paint);
    }
  }

  @override
  bool shouldRepaint(FillsNowLine old) =>
      old.from != from ||
      old.now != now ||
      old.color != color ||
      old.rtl != rtl ||
      old.cuts.length != cuts.length ||
      [
        for (var i = 0; i < cuts.length; i++) cuts[i] != old.cuts[i],
      ].any((d) => d);
}
