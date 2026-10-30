import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// What a task's dot shows (docs/10 §1, §3 `TaskDot`).
enum DotState {
  /// The task has not started.
  upcoming,

  /// A ring inside the dot fills with the task's progress.
  live,

  /// Done: the dot is unchanged; the row's done circle is filled.
  done,

  /// Dashed ring, faded icon: skipped, or a repeat not yet materialised.
  skipped,

  /// Drawn like [upcoming]; its row says "not done" (§5.2, `A-mac-month`).
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

/// The icon dot every task is drawn as (docs/10 §3 `TaskDot`, ADR-0015): a
/// tint of the task's colour with the bold icon in the colour itself. The
/// dot looks the same upcoming, done or missed (done shows in the row's
/// done circle and struck title); a live dot adds its progress ring and a
/// skipped one fades its icon inside a dashed ring.
///
/// With [onTap] it opens the task (or Focus for the live one) and its hit
/// area is at least 48 dp whatever its [size]; without, it is decorative
/// and merges into the row's own label.
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

  /// [DotSize.threadDot] (56), [DotSize.rowDot] (36), [DotSize.macRowDot]
  /// (26) or [DotSize.pickerDot] (22).
  final double size;
  final VoidCallback? onTap;

  /// What a tap does, read after the label ("Open").
  final String? tapHint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final dot = TweenAnimationBuilder<double>(
      tween: Tween(end: state == DotState.live ? progress.clamp(0, 1) : 0),
      duration: t.motion.base,
      curve: t.motion.curve,
      builder: (context, sweep, child) => CustomPaint(
        size: Size.square(size),
        painter: _DotPainter(
          color: color.color,
          fill: swatch.tint,
          state: state,
          sweep: sweep,
          ring: _ring(size),
        ),
        child: child,
      ),
      child: SizedBox.square(dimension: size, child: _glyph(swatch.glyph)),
    );
    if (onTap == null) {
      return Semantics(label: label, excludeSemantics: true, child: dot);
    }
    final target = math.max(size, DotTouch.android);
    return Semantics(
      button: true,
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

  Widget? _glyph(Color ink) {
    final glyph = icon.glyph;
    if (glyph == null) return null;
    final faded = state == DotState.skipped;
    return Center(
      child: DotIcon(
        glyph,
        color: faded ? ink.withValues(alpha: TaskAlpha.faded) : ink,
        size: size * DotSize.rowIcon / DotSize.rowDot,
        bold: true,
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
    required this.fill,
    required this.state,
    required this.sweep,
    required this.ring,
  });

  final Color color;
  final Color fill;
  final DotState state;
  final double sweep;
  final double ring;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, size.shortestSide / 2, Paint()..color = fill);
    final r = size.shortestSide / 2 - ring / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring
      ..color = color;
    switch (state) {
      case DotState.live:
        _live(canvas, c, r, stroke);
      case DotState.skipped:
        _dashed(
          canvas,
          c,
          r,
          stroke..color = color.withValues(alpha: TaskAlpha.faded),
        );
      case DotState.upcoming || DotState.done || DotState.missed:
        break;
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
      old.fill != fill ||
      old.state != state ||
      old.sweep != sweep ||
      old.ring != ring;
}
