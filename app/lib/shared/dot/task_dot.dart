import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// What a task's dot shows (docs/10 §1, §3 `TaskDot`).
enum DotState {
  /// Outlined: the task has not started.
  upcoming,

  /// Conic ring filling with the task's progress.
  live,

  /// Solid with a check.
  done,

  /// Dashed outline: skipped, or a repeat not yet materialised.
  skipped,

  /// Outlined like [upcoming]; its row says "missed" (§5.2, `A-mac-month`).
  missed,
}

/// Screen-reader label of a dot with its state (docs/10 §5.4):
/// "Deep work, live, 38 minutes left".
String taskDotLabel(
  AppLocalizations l10n, {
  required String title,
  required DotState state,
  int? minutesLeft,
}) => switch (state) {
  DotState.upcoming => l10n.dotUpcoming(title),
  DotState.live when minutesLeft != null => l10n.dotLiveLeft(
    title,
    minutesLeft,
  ),
  DotState.live => l10n.dotLive(title),
  DotState.done => l10n.dotDone(title),
  DotState.skipped => l10n.dotSkipped(title),
  DotState.missed => l10n.dotMissed(title),
};

/// The icon dot every task is drawn as (docs/10 §3 `TaskDot`): outline,
/// conic (live), filled-check (done) or dashed (skipped).
///
/// With [onTap] it is the done toggle ("Tap a dot = mark done", §6) and
/// its hit area is at least 48 dp whatever its [size]; without, it is
/// decorative and merges into the row's own label.
class TaskDot extends StatelessWidget {
  const TaskDot({
    required this.color,
    required this.icon,
    required this.state,
    required this.label,
    this.progress = 0,
    this.size = DotSize.rowDot,
    this.onTap,
    this.tapHint,
    super.key,
  });

  final TaskColor color;
  final TaskIcon icon;
  final DotState state;

  /// From [taskDotLabel].
  final String label;

  /// 0–1 share of a live task that has elapsed; ignored in other states.
  final double progress;

  /// [DotSize.rowDot] (36), [DotSize.liveDot] (42), [DotSize.macRowDot]
  /// (26) or [DotSize.pickerDot] (22).
  final double size;
  final VoidCallback? onTap;

  /// What a tap does, read after the label ("Mark done").
  final String? tapHint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final dot = TweenAnimationBuilder<double>(
      tween: Tween(end: state == DotState.live ? progress.clamp(0, 1) : 0),
      duration: t.motion.base,
      curve: t.motion.curve,
      builder: (context, sweep, child) => CustomPaint(
        size: Size.square(size),
        painter: _DotPainter(
          color: color.color,
          state: state,
          sweep: sweep,
          ring: _ring(size),
          inner: t.colors.raised,
        ),
        child: child,
      ),
      child: SizedBox.square(dimension: size, child: _glyph(t)),
    );
    if (onTap == null) {
      return Semantics(label: label, excludeSemantics: true, child: dot);
    }
    final target = math.max(size, DotTouch.android);
    return Semantics(
      button: true,
      checked: state == DotState.done,
      label: label,
      onTapHint: tapHint,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: target / 2,
        child: SizedBox.square(
          dimension: target,
          child: Center(child: dot),
        ),
      ),
    );
  }

  Widget? _glyph(DotTheme t) {
    final iconSize = size * DotSize.rowIcon / DotSize.rowDot;
    if (state == DotState.done) {
      return Center(
        child: DotIcon(
          DotGlyphs.check,
          color: t.colors.raised,
          size: iconSize,
          active: true,
        ),
      );
    }
    final glyph = icon.glyph;
    if (glyph == null) return null;
    final faded = state == DotState.skipped;
    return Center(
      child: DotIcon(
        glyph,
        color: faded
            ? color.color.withValues(alpha: TaskAlpha.faded)
            : color.color,
        size: iconSize,
      ),
    );
  }
}

double _ring(double size) => size >= DotSize.liveDot
    ? DotSize.liveRing
    : size >= DotSize.rowDot
    ? DotSize.dotOutline
    : DotSize.smallDotOutline;

final class _DotPainter extends CustomPainter {
  const _DotPainter({
    required this.color,
    required this.state,
    required this.sweep,
    required this.ring,
    required this.inner,
  });

  final Color color;
  final DotState state;
  final double sweep;
  final double ring;
  final Color inner;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - ring / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring
      ..color = color;
    switch (state) {
      case DotState.done:
        canvas.drawCircle(c, size.shortestSide / 2, Paint()..color = color);
      case DotState.upcoming || DotState.missed:
        canvas.drawCircle(c, r, Paint()..color = inner);
        canvas.drawCircle(c, r, stroke);
      case DotState.live:
        canvas.drawCircle(c, r, Paint()..color = inner);
        _live(canvas, c, r, stroke);
      case DotState.skipped:
        canvas.drawCircle(c, r, Paint()..color = inner);
        _dashed(
          canvas,
          c,
          r,
          stroke..color = color.withValues(alpha: TaskAlpha.faded),
        );
    }
  }

  /// Faint full track, then the elapsed share clockwise from 12 o'clock.
  void _live(Canvas canvas, Offset c, double r, Paint stroke) {
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint.from(stroke)..color = color.withValues(alpha: TaskAlpha.track),
    );
    if (sweep <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * sweep,
      false,
      stroke..strokeCap = StrokeCap.round,
    );
  }

  void _dashed(Canvas canvas, Offset c, double r, Paint stroke) {
    const dashes = 10;
    final rect = Rect.fromCircle(center: c, radius: r);
    const step = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * step, step * 0.55, false, stroke);
    }
  }

  @override
  bool shouldRepaint(_DotPainter old) =>
      old.color != color ||
      old.state != state ||
      old.sweep != sweep ||
      old.ring != ring ||
      old.inner != inner;
}
