import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/overlap_knot.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/widgets.dart';

/// Width of the dot column the thread runs down (Concept E §5.2: 48, so
/// with the page's 20 gutter the thread's centre is 44 from the edge).
const double threadAxisWidth = 48;

/// Gap between the dot column and a row's text (Concept E §5.2: 10).
const double threadTextGap = DotSpace.s + DotSpace.xxs;

/// Least height of a phone thread row for a task in [state] (Concept E
/// §5.2): rows keep fixed heights instead of stretching with the task.
///
/// ```dart
/// threadRowHeight(DotState.done);     // 48
/// threadRowHeight(DotState.upcoming); // 54
/// ```
double threadRowHeight(DotState state) =>
    state == DotState.done ? DotSize.threadRowDone : DotSize.threadRowAhead;

/// What one row draws on the axis behind its dot or cap.
sealed class AxisPiece {
  const AxisPiece();
}

/// A task: the thread through its row (Concept E §5.2). Behind now
/// ([above] set) it is solid, the row's upper half in [above] (the task
/// before it) and the lower half in [color]; ahead of now ([above] null)
/// it is the dotted thread, faded for a skipped task.
final class SegmentPiece extends AxisPiece {
  const SegmentPiece({
    required this.color,
    required this.state,
    this.above,
    this.ghost,
  });

  /// On the Reality thread (11 C3): the plan's ghost lane beside the
  /// segment, with the planned dot where it differs. Null on the plan.
  final GhostShift? ghost;

  final Color color;
  final DotState state;

  /// The colour the thread arrives in when the row is behind now; null:
  /// the row is ahead and dotted.
  final Color? above;
}

/// Two overlapping tasks (§5.4): the 26 px knot, one strand in each
/// task's colour, between their dots.
final class OverlapPiece extends AxisPiece {
  const OverlapPiece({required this.above, required this.below});

  final Color above;
  final Color below;
}

/// Free time: solid in [color] when it is behind now, else dotted.
final class FreePiece extends AxisPiece {
  const FreePiece({this.color});

  /// The previous task's colour when the gap is behind now; null: ahead.
  final Color? color;
}

/// Now (§5.3, ED-246): the bead on the thread, solid above it in [color]
/// (null: dotted) and dotted below.
final class NowPiece extends AxisPiece {
  const NowPiece({this.color});

  final Color? color;
}

/// A cap: the thread starts at the sun's centre and ends at the moon's
/// (§5.2): below the sun, or above the moon. Solid in [color] when that
/// stretch is behind now, else dotted.
final class CapPiece extends AxisPiece {
  const CapPiece({required this.below, this.color});

  final bool below;
  final Color? color;
}

/// Paints one row's share of the thread down the centre of the axis.
final class ThreadAxisPainter extends CustomPainter {
  const ThreadAxisPainter({
    required this.piece,
    required this.hairline,
    required this.accent,
    required this.card,
    this.ghostSide = -1,
  });

  /// -1 puts the ghost lane before the centre in LTR; +1 mirrors it (RTL).
  final double ghostSide;

  final AxisPiece piece;

  /// The dotted thread's colour ([DotColors.threadAhead]).
  final Color hairline;
  final Color accent;

  /// The now-bead's border: the card colour (§5.3).
  final Color card;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final h = size.height;
    switch (piece) {
      case SegmentPiece() && final p:
        _segment(canvas, x, h, p);
      case FreePiece(:final color):
        _line(canvas, x, 0, h, color);
      case NowPiece(:final color):
        _line(canvas, x, 0, h / 2, color);
        _line(canvas, x, h / 2, h, null);
        _now(canvas, Offset(x, h / 2));
      case OverlapPiece() && final p:
        _overlap(canvas, x, h, p);
      case CapPiece(:final below, :final color):
        below
            ? _line(canvas, x, h / 2, h, color)
            : _line(canvas, x, 0, h / 2, color);
    }
  }

  void _segment(Canvas canvas, double x, double height, SegmentPiece p) {
    if (p.ghost case final shift?) _ghost(canvas, x, height, p, shift);
    final above = p.above;
    if (above == null) {
      _line(
        canvas,
        x,
        0,
        height,
        null,
        dotted: p.state == DotState.skipped
            ? hairline.withValues(alpha: TaskAlpha.faded)
            : null,
      );
      return;
    }
    final mid = height / 2;
    _line(canvas, x, 0, mid, above);
    _line(canvas, x, mid, height, p.color);
  }

  /// A stretch of thread: solid in [solid], or dotted when it is null.
  void _line(
    Canvas canvas,
    double x,
    double from,
    double to,
    Color? solid, {
    Color? dotted,
  }) {
    if (to <= from) return;
    if (solid != null) {
      canvas.drawLine(
        Offset(x, from),
        Offset(x, to),
        Paint()
          ..color = solid
          ..strokeWidth = DotSize.segment,
      );
      return;
    }
    // Concept E's dotted thread: 4 px dots, a dot's width apart.
    final paint = Paint()..color = dotted ?? hairline;
    const step = DotSize.freeLine * 2;
    for (var y = from + DotSize.freeLine / 2; y < to; y += step) {
      canvas.drawCircle(Offset(x, y), DotSize.freeLine / 2, paint);
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
    final at = Offset(lane, height / 2 + dy);
    canvas.drawCircle(
      at,
      DotSize.ghostRing / 2,
      Paint()
        ..color = ghost
        ..style = PaintingStyle.stroke
        ..strokeWidth = DotSize.smallDotOutline,
    );
  }

  void _overlap(Canvas canvas, double x, double height, OverlapPiece p) =>
      paintKnot(
        canvas,
        x: x,
        top: 0,
        bottom: height,
        sway: DotSize.knotSway,
        stroke: DotSize.knotStroke,
        first: p.above,
        second: p.below,
      );

  /// The now-bead (§5.3): 16 px in the accent, a 2 px card-coloured
  /// border and a 1 px accent ring at 40 % outside it.
  void _now(Canvas canvas, Offset at) {
    const r = DotSize.nowMarker / 2;
    canvas
      ..drawCircle(
        at,
        r + DotSize.nowHalo,
        Paint()..color = accent.withValues(alpha: TaskAlpha.nowHalo),
      )
      ..drawCircle(at, r, Paint()..color = card)
      ..drawCircle(at, r - DotSize.nowBorder, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(ThreadAxisPainter old) =>
      old.piece != piece ||
      old.hairline != hairline ||
      old.accent != accent ||
      old.card != card ||
      old.ghostSide != ghostSide;
}
