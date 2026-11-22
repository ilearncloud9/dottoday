import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

/// A proposed task on the proposal's list (E-Phones-2, ED-150): its 34 pt
/// ahead dot inside a 2 px dashed ring in the task's ring colour, 2 px
/// off the dot. A task leaving the day shows its skipped dot.
class ProposedDot extends StatelessWidget {
  const ProposedDot({required this.dot, this.leaving = false, super.key});

  final SnapshotDot dot;
  final bool leaving;

  /// The dot, the 2 px gap and the 2 px ring on each side.
  static const double extent =
      DotSize.threadDot + 2 * (DotSpace.xxs + DotSize.smallDotOutline);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final color = TaskColor.fromKey(dot.colorKey);
    return ExcludeSemantics(
      child: CustomPaint(
        painter: DashedRingPainter(
          t.tasks[color].ring.withValues(alpha: TaskAlpha.proposed),
        ),
        child: SizedBox.square(
          dimension: extent,
          child: Center(
            child: TaskDot(
              color: color,
              icon: TaskIcon.fromKey(dot.iconKey),
              state: leaving ? DotState.skipped : DotState.upcoming,
              label: dot.title,
              size: DotSize.threadDot,
            ),
          ),
        ),
      ),
    );
  }
}

/// The task as the day has it now, before the plan (E-R2-35): a faded
/// hollow ring in its colour, beside its [ProposedDot].
class NowRing extends StatelessWidget {
  const NowRing({required this.dot, super.key});

  final SnapshotDot dot;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final color = TaskColor.fromKey(dot.colorKey);
    return ExcludeSemantics(
      child: Container(
        width: DotSize.proposalNowRing,
        height: DotSize.proposalNowRing,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: t.tasks[color].ring.withValues(alpha: TaskAlpha.upcoming),
            width: DotSize.smallDotOutline,
          ),
        ),
      ),
    );
  }
}

/// A 2 px dashed circle just inside its box: the proposed dot's ring and
/// the legend's "proposed" mark.
final class DashedRingPainter extends CustomPainter {
  const DashedRingPainter(this.color);

  final Color color;

  static const _dashes = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = DotSize.smallDotOutline;
    final r = size.shortestSide / 2 - DotSize.smallDotOutline / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    const step = 2 * math.pi / _dashes;
    for (var i = 0; i < _dashes; i++) {
      canvas.drawArc(rect, i * step, step * 0.55, false, stroke);
    }
  }

  @override
  bool shouldRepaint(DashedRingPainter old) => old.color != color;
}
