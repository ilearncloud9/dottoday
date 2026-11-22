import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/live_row_meta.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/dot/thread_scale.dart';
import 'package:dottoday/shared/dot/unstick_line.dart';
import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:flutter/material.dart';

/// The now card (E rules §5.3, ED-104): the 45 ring (52 on phones,
/// ED-419), time, title and done circle on a card over the thread. Full
/// has no buttons on it (M18.3); Minimal keeps Running late (docs/14 §4).
class LiveRow extends StatelessWidget {
  const LiveRow({
    required this.task,
    this.onToggleDone,
    this.onOpen,
    this.onFocus,
    this.onUnstick,
    this.onRunningLate,
    this.solid,
    super.key,
  });

  final ThreadTask task;
  final VoidCallback? onToggleDone;
  final VoidCallback? onOpen;

  /// One tap on the live dot (11 A3, docs/09 M10.5); null: the dot opens
  /// the task.
  final VoidCallback? onFocus;

  /// The Unstick answer (11 B3, M10.7); null hides the row.
  final ValueChanged<String>? onUnstick;

  /// Running late (minimal layout, docs/14 §4); null: no button.
  final VoidCallback? onRunningLate;

  /// The colour the thread arrives in (from `threadSolid`).
  final TaskColor? solid;

  @override
  Widget build(BuildContext context) {
    final tasks = DotTheme.of(context).tasks;
    final size = ThreadScale.of(context).liveDot;
    return ThreadRowFrame(
      card: true,
      minHeight: DotSize.nowCard,
      piece: SegmentPiece(
        color: tasks[task.color].color,
        state: task.state,
        above: switch (solid) {
          final c? => tasks[c].color,
          null => null,
        },
        ghost: task.reality?.ghost,
      ),
      dot: taskRowDot(context, task, size, onOpen, onFocus: onFocus),
      trailing: onToggleDone == null
          ? null
          : DoneCircle(
              color: task.color,
              done: false,
              live: true,
              title: task.title,
              onTap: onToggleDone,
            ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
        child: _body(),
      ),
    );
  }

  /// The time above the title at every width (Concept E, E-FullA-v2 web
  /// Day), then the cues.
  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        _Summary(task: task, onOpen: onOpen),
        // Smallest step (M10.6): only the first step, and Start.
        if (task.smallestStep case final text?)
          SmallestStepLine(text: text, onStart: onFocus),
        if (onUnstick case final answer?) UnstickLine(onAnswer: answer),
        if (onRunningLate case final late?)
          Builder(
            builder: (context) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton(
                onPressed: late,
                child: Text(context.l10n.runningLate),
              ),
            ),
          ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.task, this.onOpen});

  final ThreadTask task;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final now = switch ((task.reality, task.minutesLeft)) {
      (null, final left?) => l10n.liveNowLeft(left),
      _ => null,
    };
    final range = switch (task.reality) {
      final r? => _realityMeta(l10n, task, r),
      null => task.timeRange,
    };
    final rowLabel = taskRowLabel(l10n, task);
    final summary = Semantics(
      button: onOpen != null,
      label: task.hasSubtasks
          ? l10n.rowWithSubtasks(
              rowLabel,
              l10n.liveSubtasks(task.subtasksDone, task.subtasksTotal),
            )
          : rowLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.xxs,
          children: [
            // "9:00 – 11:00 · Now, 18 min left · Your one thing" (E-R2-34).
            NowMeta(
              range: range,
              now: now,
              tail: task.oneThing ? l10n.oneThingMeta : null,
              style: t.styles.threadMeta,
            ),
            Text(task.title, style: t.styles.liveRowTitle),
            if (task.hasSubtasks || task.reality?.note != null)
              _Progress(task: task),
          ],
        ),
      ),
    );
    final usual = task.reality?.usual;
    if (usual == null) return summary;
    // Outside the row's merged label, so the explanation is its own
    // control for screen readers (docs/13 §6).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        summary,
        LearnedLine(
          text: usual,
          explanation: task.reality?.usualWhy,
          style: t.styles.rowMeta.copyWith(color: t.colors.muted),
        ),
      ],
    );
  }
}

/// "9:10 – now · planned 9:00 – 11:00" on the Reality thread (11 C3).
String _realityMeta(AppLocalizations l10n, ThreadTask task, ThreadReality r) {
  final range = r.range ?? task.timeRange;
  return switch (r.meta) {
    final m? => l10n.liveMeta(range, m),
    null => range,
  };
}

/// "◔ 1 of 3   38 min left" under the live title.
class _Progress extends StatelessWidget {
  const _Progress({required this.task});

  final ThreadTask task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Wrap(
      spacing: DotSpace.m,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (task.hasSubtasks)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              SubtaskRing(done: task.subtasksDone, total: task.subtasksTotal),
              Text(
                l10n.liveSubtasks(task.subtasksDone, task.subtasksTotal),
                style: t.styles.stripWeekday.copyWith(
                  color: t.colors.accentInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        // The Reality thread says how long it has run (11 C3); the plan's
        // time left is on the meta line (E rules §5.3).
        if (task.reality?.note case final ran?)
          Text(ran, style: t.styles.stripWeekday),
      ],
    );
  }
}

/// The small pie of subtask progress (`Main` "1 of 3").
class SubtaskRing extends StatelessWidget {
  const SubtaskRing({required this.done, required this.total, super.key});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return CustomPaint(
      size: const Size.square(DotSize.weekDot * 2),
      painter: _PiePainter(
        share: total == 0 ? 0 : done / total,
        fill: c.accent,
        track: Color.alphaBlend(c.accentTint, c.raised),
      ),
    );
  }
}

final class _PiePainter extends CustomPainter {
  const _PiePainter({
    required this.share,
    required this.fill,
    required this.track,
  });

  final double share;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..drawOval(rect, Paint()..color = track)
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * share,
        true,
        Paint()..color = fill,
      );
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.share != share || old.fill != fill || old.track != track;
}
