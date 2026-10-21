import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/widgets.dart';

/// Width of the column the thread runs down (docs/10 §2.3, `Main`): room
/// for the 42 px live dot plus its ring.
const double threadAxisWidth = 56;

/// Gap between the axis column and a row's text.
const double threadTextGap = DotSpace.l;

/// What one row draws on the axis behind its dot or cap.
sealed class AxisPiece {
  const AxisPiece();
}

/// A task: its coloured segment from under the dot to the row's end.
final class SegmentPiece extends AxisPiece {
  const SegmentPiece({
    required this.color,
    required this.state,
    required this.dotSize,
    this.progress = 0,
  });

  final Color color;
  final DotState state;
  final double dotSize;

  /// Live only: share of the segment that is solid; the now-marker sits at
  /// its end.
  final double progress;
}

/// Free time: the dotted line, with the now-marker if now is inside it.
final class FreePiece extends AxisPiece {
  const FreePiece({this.nowFraction});

  final double? nowFraction;
}

/// A cap: dotted line below the sun (from [iconExtent]) or above the moon.
final class CapPiece extends AxisPiece {
  const CapPiece({required this.below, required this.iconExtent});

  final bool below;
  final double iconExtent;
}

/// Paints one row's share of the thread down the centre of the axis.
final class ThreadAxisPainter extends CustomPainter {
  const ThreadAxisPainter({
    required this.piece,
    required this.hairline,
    required this.accent,
    required this.accentTint,
  });

  final AxisPiece piece;
  final Color hairline;
  final Color accent;
  final Color accentTint;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    switch (piece) {
      case SegmentPiece() && final p:
        _segment(canvas, x, size.height, p);
      case FreePiece(:final nowFraction):
        _dotted(canvas, x, 0, size.height);
        if (nowFraction != null) {
          _now(canvas, Offset(x, size.height * nowFraction));
        }
      case CapPiece(:final below, :final iconExtent):
        below
            ? _dotted(canvas, x, iconExtent, size.height)
            : _dotted(canvas, x, 0, size.height - iconExtent);
    }
  }

  void _segment(Canvas canvas, double x, double height, SegmentPiece p) {
    final top = p.dotSize;
    if (height <= top) return;
    final paint = Paint()
      ..strokeWidth = DotSize.segment
      ..strokeCap = StrokeCap.round;
    final start = Offset(x, top + DotSize.segment / 2);
    final end = Offset(x, height - DotSize.segment / 2);
    switch (p.state) {
      case DotState.live:
        final now = Offset(x, start.dy + (end.dy - start.dy) * p.progress);
        canvas
          ..drawLine(
            start,
            end,
            paint..color = p.color.withValues(alpha: TaskAlpha.upcoming),
          )
          ..drawLine(start, now, paint..color = p.color);
        _now(canvas, now);
      case DotState.done:
        canvas.drawLine(
          start,
          end,
          paint..color = p.color.withValues(alpha: TaskAlpha.done),
        );
      case DotState.skipped:
        _dotted(
          canvas,
          x,
          top,
          height,
          color: p.color.withValues(alpha: TaskAlpha.faded),
        );
      case DotState.upcoming || DotState.missed:
        canvas.drawLine(
          start,
          end,
          paint..color = p.color.withValues(alpha: TaskAlpha.upcoming),
        );
    }
  }

  /// The 2 px dotted free-time line (§2.3).
  void _dotted(
    Canvas canvas,
    double x,
    double from,
    double to, {
    Color? color,
  }) {
    final paint = Paint()..color = color ?? hairline;
    const step = DotSize.freeLine * 2.5;
    for (var y = from + step / 2; y < to; y += step) {
      canvas.drawCircle(Offset(x, y), DotSize.freeLine / 2, paint);
    }
  }

  /// 16 px accent dot with a 4 px halo (§2.4).
  void _now(Canvas canvas, Offset at) {
    canvas
      ..drawCircle(
        at,
        DotSize.nowMarker / 2 + DotSize.nowHalo,
        Paint()..color = accentTint,
      )
      ..drawCircle(at, DotSize.nowMarker / 2, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(ThreadAxisPainter old) =>
      old.piece != piece ||
      old.hairline != hairline ||
      old.accent != accent ||
      old.accentTint != accentTint;
}
