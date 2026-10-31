import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/done_circle.dart';
import 'package:dottoday/shared/dot/smallest_step_line.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/dot/unstick_line.dart';
import 'package:flutter/material.dart';

export 'done_circle.dart';
export 'smallest_step_line.dart';

/// A task on the thread (docs/10 §3 `TaskRow`): dot + segment on the axis,
/// time meta, title, and the done circle at the end.
///
/// States: upcoming, done (struck, muted), missed ("missed" in the meta),
/// skipped, pinned (lock), recurring (repeat glyph) and imported (calendar
/// badge, docs/02 F1.10). The live task is
/// a `LiveRow`.
class TaskRow extends StatelessWidget {
  const TaskRow({
    required this.task,
    this.onToggleDone,
    this.onOpen,
    this.onStart,
    this.onUnstick,
    this.dotSize = DotSize.threadDot,
    this.doneCircle = true,
    super.key,
  });

  final ThreadTask task;

  /// The round done circle at the end; the spread's side days have none
  /// (`A-mac-today-alt1-spread`): their tasks are marked done in the sheet.
  final bool doneCircle;

  /// Tap on the done circle (ADR-0015: the circle, not the dot, marks done).
  final VoidCallback? onToggleDone;

  /// Tap on the row or the dot: the task sheet (§6, ADR-0015).
  final VoidCallback? onOpen;

  /// Smallest step's Start (M10.6), under the title while it asks.
  final VoidCallback? onStart;

  /// The Unstick answer (11 B3, M10.7); null hides the row.
  final ValueChanged<String>? onUnstick;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return ThreadRowFrame(
      piece: SegmentPiece(
        color: task.color.color,
        state: task.state,
        dotSize: dotSize,
        ghost: task.reality?.ghost,
      ),
      dot: taskRowDot(context, task, dotSize, onOpen),
      trailing: !doneCircle || onToggleDone == null
          ? null
          : DoneCircle(
              color: task.color,
              done: task.state == DotState.done,
              title: task.title,
              onTap: onToggleDone,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: onOpen != null,
            label: taskRowLabel(context.l10n, task),
            excludeSemantics: true,
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(DotRadii.card),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: task.smallestStep == null && onUnstick == null
                      ? DotSpace.xl
                      : DotSpace.xs,
                ),
                child: _Text(task: task, large: dotSize >= DotSize.threadDot),
              ),
            ),
          ),
          if (task.smallestStep case final text?)
            Padding(
              padding: const EdgeInsets.only(bottom: DotSpace.l),
              child: SmallestStepLine(text: text, onStart: onStart),
            ),
          if (onUnstick case final answer?)
            Padding(
              padding: const EdgeInsets.only(bottom: DotSpace.l),
              child: UnstickLine(onAnswer: answer),
            ),
        ],
      ),
    );
  }
}

/// The dot of a thread row: opens the task, or Focus on the live one
/// (11 A3). Marking done is the [DoneCircle]'s job (ADR-0015).
Widget taskRowDot(
  BuildContext context,
  ThreadTask task,
  double size,
  VoidCallback? onOpen, {
  VoidCallback? onFocus,
}) {
  final l10n = context.l10n;
  return TaskDot(
    color: task.color,
    icon: task.icon,
    state: task.state,
    progress: task.progress,
    size: size,
    label: taskDotLabel(
      l10n,
      title: task.title,
      state: task.state,
      minutesLeft: task.minutesLeft,
    ),
    onTap: onFocus ?? onOpen,
    tapHint: onFocus != null ? l10n.focusOpenHint : l10n.dotOpenHint,
  );
}

/// Screen-reader label of a row's text: "Reply to email, 11:00 – 11:30,
/// pinned, repeats, from your calendar".
String taskRowLabel(AppLocalizations l10n, ThreadTask task) {
  var label = l10n.rowLabel(task.title, task.timeRange);
  if (task.state == DotState.missed) label = l10n.rowMissed(label);
  if (task.pinned) label = l10n.rowPinned(label);
  if (task.recurring) label = l10n.rowRepeats(label);
  if (task.imported) label = l10n.rowFromCalendar(label);
  if (task.travel case final travel?) label = l10n.rowTravel(label, travel);
  return label;
}

class _Text extends StatelessWidget {
  const _Text({required this.task, this.large = false});

  final ThreadTask task;

  /// The day thread's bold row (ADR-0015); off for the Mac side days.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final done = task.state == DotState.done;
    final muted = t.colors.muted;
    final metaStyle = large ? t.styles.threadMeta : t.styles.rowMeta;
    final meta = Wrap(
      spacing: DotSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(task.reality?.range ?? task.timeRange, style: metaStyle),
        if (task.reality?.meta case final m?)
          Text(l10n.realityMetaJoin(m), style: _plan(t)),
        if (task.state == DotState.missed && task.reality == null)
          Text(l10n.rowMissedMeta, style: t.styles.rowMeta),
        if (task.pinned)
          DotIcon(DotGlyphs.lock, color: muted, size: DotSize.weekDot * 2),
        if (task.recurring)
          DotIcon(DotGlyphs.repeat, color: muted, size: DotSize.weekDot * 2),
        if (task.imported)
          DotIcon(DotGlyphs.calendar, color: muted, size: DotSize.weekDot * 2),
        if (task.travel case final travel?)
          Text(l10n.rowTravelMeta(travel), style: t.styles.rowMeta),
      ],
    );
    final title = Text(
      task.title,
      style: (large ? t.styles.threadTitle : t.styles.rowTitle).copyWith(
        color: done || task.state == DotState.skipped ? muted : null,
        decoration: done ? TextDecoration.lineThrough : null,
        decorationColor: muted,
      ),
    );
    final note = switch (task.reality?.note) {
      final n? => Text(n, style: _plan(t)),
      null => null,
    };
    // Wide (the Mac spread's card): time beside the title; else above it.
    return LayoutBuilder(
      builder: (context, box) =>
          box.maxWidth >=
              (large ? DotSize.wideThreadRowFrom : DotSize.wideRowFrom)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: large
                      ? DotSize.wideThreadRowMeta
                      : DotSize.wideRowMeta,
                  child: meta,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, ?note],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [meta, title, ?note],
            ),
    );
  }

  /// The plan's words on the Reality thread: quieter than the times.
  static TextStyle _plan(DotTheme t) =>
      t.styles.rowMeta.copyWith(color: t.colors.muted);
}

/// Lays out one thread row: [dot] on the axis over the [piece] painted
/// down it, [child] beside it and an optional [trailing] control.
/// Geometry is directional, so the thread runs down the start edge in RTL.
class ThreadRowFrame extends StatelessWidget {
  const ThreadRowFrame({
    required this.piece,
    required this.child,
    this.dot,
    this.trailing,
    super.key,
  });

  final AxisPiece piece;
  final Widget child;
  final Widget? dot;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Stack(
      children: [
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: threadAxisWidth,
          child: CustomPaint(
            painter: ThreadAxisPainter(
              piece: piece,
              hairline: c.hairline,
              accent: c.accent,
              accentTint: Color.alphaBlend(c.accentTint, c.raised),
              ghostSide: Directionality.of(context) == TextDirection.rtl
                  ? 1
                  : -1,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: threadAxisWidth,
              child: dot == null ? null : Center(child: dot),
            ),
            const SizedBox(width: threadTextGap),
            Expanded(child: child),
            ?trailing,
          ],
        ),
      ],
    );
  }
}
