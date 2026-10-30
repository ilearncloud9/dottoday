import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/widgets.dart';

/// Width of the column the thread runs down (docs/10 §2.3, `Main`): room
/// for the 42 px live dot plus its ring.
const double threadAxisWidth = 56;

/// Gap between the axis column and a row's text.
const double threadTextGap = DotSpace.l;

/// Least height of a day-thread row for a task of [minutes] (ADR-0015):
/// rows stretch by duration, within [DotSize.threadRowMin] and
/// [DotSize.threadRowMax].
///
/// ```dart
/// threadRowHeight(15); // 88: short tasks keep the row's own height
/// threadRowHeight(90); // 144
/// ```
double threadRowHeight(int minutes) => (minutes * DotSize.threadPerMinute)
    .clamp(DotSize.threadRowMin, DotSize.threadRowMax);

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
    this.ghost,
    this.fill,
    this.joinAbove = false,
    this.joinBelow = false,
  });

  /// The dot's tint, for the capsule an overlap draws (ADR-0015).
  final Color? fill;

  /// The task overlaps the one above: its dot reaches up as a capsule.
  final bool joinAbove;

  /// The task below overlaps this one: its dot reaches down as a capsule
  /// in place of the segment.
  final bool joinBelow;

  /// On the Reality thread (11 C3): the plan's ghost lane beside the
  /// segment, with the planned dot where it differs. Null on the plan.
  final GhostShift? ghost;

  final Color color;
  final DotState state;
  final double dotSize;

  /// Live only: share of the segment that is solid; the now-marker sits at
  /// its end.
  final double progress;
}

/// Two overlapping tasks meeting (ADR-0015): the upper capsule's rounded
/// end, then the lower one's over it with a [notch] cut along its top.
final class OverlapPiece extends AxisPiece {
  const OverlapPiece({
    required this.above,
    required this.below,
    required this.notch,
  });

  final Color above;
  final Color below;

  /// The surface colour the notch is cut in.
  final Color notch;
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
    this.ghostSide = -1,
  });

  /// -1 puts the ghost lane before the centre in LTR; +1 mirrors it (RTL).
  final double ghostSide;

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
      case OverlapPiece() && final p:
        _overlap(canvas, x, size.height, p);
      case CapPiece(:final below, :final iconExtent):
        below
            ? _dotted(canvas, x, iconExtent, size.height)
            : _dotted(canvas, x, 0, size.height - iconExtent);
    }
  }

  void _segment(Canvas canvas, double x, double height, SegmentPiece p) {
    if (p.ghost case final shift?) _ghost(canvas, x, height, p, shift);
    if (p.fill case final fill? when p.joinAbove || p.joinBelow) {
      final half = p.dotSize / 2;
      final paint = Paint()..color = fill;
      if (p.joinAbove) {
        canvas.drawRect(Rect.fromLTRB(x - half, 0, x + half, half), paint);
      }
      if (p.joinBelow) {
        canvas.drawRect(Rect.fromLTRB(x - half, half, x + half, height), paint);
        return;
      }
    }
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

  /// The plan's lane at [TaskAlpha.ghost] down the row, and the planned
  /// dot as a ghost ring above or below where it really started.
  void _ghost(
    Canvas canvas,
    double x,
    double height,
    SegmentPiece p,
    GhostShift shift,
  ) {
    final lane = x + ghostSide * DotSize.ghostLaneOffset;
    final ghost = p.color.withValues(alpha: TaskAlpha.ghost);
    canvas.drawLine(
      Offset(lane, DotSize.segment / 2),
      Offset(lane, height - DotSize.segment / 2),
      Paint()
        ..color = ghost
        ..strokeWidth = DotSize.segment
        ..strokeCap = StrokeCap.round,
    );
    final dy = switch (shift) {
      GhostShift.none => null,
      GhostShift.earlier => -DotSize.ghostRingShift,
      GhostShift.later => DotSize.ghostRingShift,
    };
    if (dy == null) return;
    final at = Offset(lane, p.dotSize / 2 + dy);
    canvas.drawCircle(
      at,
      DotSize.ghostRing / 2,
      Paint()
        ..color = ghost
        ..style = PaintingStyle.stroke
        ..strokeWidth = DotSize.smallDotOutline,
    );
  }

  void _overlap(Canvas canvas, double x, double height, OverlapPiece p) {
    const half = DotSize.threadDot / 2;
    final mid = height / 2;
    const join = DotSize.overlapJoin / 2;
    final radius = const Radius.circular(half);
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        x - half,
        -half,
        x + half,
        mid + join,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      Paint()..color = p.above,
    );
    final lower = RRect.fromLTRBAndCorners(
      x - half,
      mid - join,
      x + half,
      height + half,
      topLeft: radius,
      topRight: radius,
    );
    canvas
      ..drawRRect(
        lower.inflate(DotSize.smallDotOutline),
        Paint()..color = p.notch,
      )
      ..drawRRect(lower, Paint()..color = p.below);
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
      old.accentTint != accentTint ||
      old.ghostSide != ghostSide;
}
