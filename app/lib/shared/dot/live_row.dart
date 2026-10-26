import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/dot/unstick_line.dart';
import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:flutter/material.dart';

/// The current task, expanded (docs/10 §3 `LiveRow`, `Main`): conic dot,
/// solid segment down to the now-marker, subtask ring "1 of 3", "38 min
/// left", and Done / +15 min / Shift the rest.
class LiveRow extends StatelessWidget {
  const LiveRow({
    required this.task,
    this.onToggleDone,
    this.onOpen,
    this.onFocus,
    this.onUnstick,
    this.onResize,
    this.onExtend,
    this.onShiftRest,
    super.key,
  });

  final ThreadTask task;
  final VoidCallback? onToggleDone;
  final VoidCallback? onOpen;

  /// One tap on the live dot (11 A3, docs/09 M10.5); null: the dot ticks.
  final VoidCallback? onFocus;

  /// The Unstick answer (11 B3, M10.7); null hides the row.
  final ValueChanged<String>? onUnstick;

  /// Resize grip at the segment end (R-05).
  final ValueChanged<int>? onResize;

  /// +15 min.
  final VoidCallback? onExtend;

  /// Moves every later task by the overrun (R-04).
  final VoidCallback? onShiftRest;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ThreadRowFrame(
      piece: SegmentPiece(
        color: task.color.color,
        state: task.state,
        dotSize: DotSize.liveDot,
        progress: task.progress,
        ghost: task.reality?.ghost,
      ),
      dot: taskRowDot(
        context,
        task,
        DotSize.liveDot,
        onToggleDone,
        onFocus: onFocus,
      ),
      trailing: DoneCircle(
        color: t.colors.accent,
        width: DotSize.dotOutline,
        onTap: onToggleDone,
      ),
      grip: onResize == null
          ? null
          : ResizeGrip(
              onSteps: onResize!,
              label: context.l10n.resizeLabel(task.title),
            ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DotSpace.xl),
        child: LayoutBuilder(builder: (context, box) => _body(box.maxWidth)),
      ),
    );
  }

  /// Wide (the Mac spread's card): the time in its own column, as on
  /// [TaskRow]; else above the title.
  Widget _body(double width) {
    final wide = width >= DotSize.wideRowFrom;
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.m,
      children: [
        _Summary(task: task, onOpen: onOpen, showMeta: !wide),
        // Smallest step (M10.6): only the first step, and Start.
        if (task.smallestStep case final text?)
          SmallestStepLine(text: text, onStart: onFocus),
        if (onUnstick case final answer?) UnstickLine(onAnswer: answer),
        // A read-only thread (the Inbox's Drop onto today) wires none.
        if (onToggleDone != null || onExtend != null)
          _Actions(
            onDone: onToggleDone,
            onExtend: onExtend,
            onShiftRest: onShiftRest,
          ),
      ],
    );
    if (!wide) return column;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: DotSize.wideRowMeta,
          child: _WideMeta(task: task),
        ),
        Expanded(child: column),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.task, this.onOpen, this.showMeta = true});

  final ThreadTask task;
  final VoidCallback? onOpen;

  /// The time line above the title; off when [LiveRow] shows it beside.
  final bool showMeta;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final meta = switch ((task.reality, task.duration)) {
      (final r?, _) => _realityMeta(l10n, task, r),
      (null, final d?) => l10n.liveMeta(task.timeRange, d),
      (null, null) => task.timeRange,
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
            if (showMeta) Text(meta, style: t.styles.rowMeta),
            Text(task.title, style: t.styles.liveRowTitle),
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

/// The time range in the wide layout's own column (read with the title).
class _WideMeta extends StatelessWidget {
  const _WideMeta({required this.task});

  final ThreadTask task;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Text(switch (task.reality) {
      final r? => _realityMeta(context.l10n, task, r),
      null => task.timeRange,
    }, style: DotTheme.of(context).styles.rowMeta),
  );
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
        // The Reality thread says how long it has run instead (11 C3).
        if (task.reality?.note case final ran?)
          Text(ran, style: t.styles.stripWeekday)
        else if (task.minutesLeft case final left?)
          Text(l10n.liveMinutesLeft(left), style: t.styles.stripWeekday),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({this.onDone, this.onExtend, this.onShiftRest});

  final VoidCallback? onDone;
  final VoidCallback? onExtend;
  final VoidCallback? onShiftRest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        FilledButton(onPressed: onDone, child: Text(l10n.liveDone)),
        OutlinedButton(onPressed: onExtend, child: Text(l10n.liveExtend)),
        OutlinedButton(onPressed: onShiftRest, child: Text(l10n.liveShiftRest)),
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
