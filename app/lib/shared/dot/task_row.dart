import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/material.dart';

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
    this.onResize,
    this.onStart,
    this.dotSize = DotSize.rowDot,
    this.doneCircle = true,
    super.key,
  });

  final ThreadTask task;

  /// The round done circle at the end; the spread's side days have none
  /// (`A-mac-today-alt1-spread`), the dot still toggles.
  final bool doneCircle;

  /// Tap on the dot or the done circle (§6 "Tap a dot = mark done").
  final VoidCallback? onToggleDone;

  /// Tap on the row: the task sheet (§6).
  final VoidCallback? onOpen;

  /// Resize grip at the segment end (R-05); null hides it.
  final ValueChanged<int>? onResize;

  /// Smallest step's Start (M10.6), under the title while it asks.
  final VoidCallback? onStart;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ThreadRowFrame(
      piece: SegmentPiece(
        color: task.color.color,
        state: task.state,
        dotSize: dotSize,
      ),
      dot: taskRowDot(context, task, dotSize, onToggleDone),
      grip: onResize == null
          ? null
          : ResizeGrip(
              onSteps: onResize!,
              label: context.l10n.resizeLabel(task.title),
            ),
      trailing:
          task.state == DotState.done || !doneCircle || onToggleDone == null
          ? null
          : DoneCircle(color: t.colors.hairline, onTap: onToggleDone),
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
                  bottom: task.smallestStep == null ? DotSpace.xl : DotSpace.xs,
                ),
                child: _Text(task: task),
              ),
            ),
          ),
          if (task.smallestStep case final text?)
            Padding(
              padding: const EdgeInsets.only(bottom: DotSpace.l),
              child: SmallestStepLine(text: text, onStart: onStart),
            ),
        ],
      ),
    );
  }
}

/// "Just Gather documents · 10 min?" and Start (11 B2, docs/09 M10.6): a
/// quiet line in the accent, never a warning colour (11 §D no shame).
class SmallestStepLine extends StatelessWidget {
  const SmallestStepLine({required this.text, this.onStart, super.key});

  final String text;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Wrap(
      spacing: DotSpace.s,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: t.styles.rowMeta.copyWith(color: t.colors.accentInk)),
        if (onStart != null)
          FilledButton.tonal(
            onPressed: onStart,
            style: FilledButton.styleFrom(shape: dotChipShape(context)),
            child: Text(context.l10n.smallestStepStart),
          ),
      ],
    );
  }
}

/// The dot of a thread row, wired as the done toggle.
Widget taskRowDot(
  BuildContext context,
  ThreadTask task,
  double size,
  VoidCallback? onToggleDone, {
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
    // The live dot opens Focus (11 A3); other dots tick.
    onTap: onFocus ?? onToggleDone,
    tapHint: onFocus != null
        ? l10n.focusOpenHint
        : task.state == DotState.done
        ? l10n.dotMarkNotDoneHint
        : l10n.dotMarkDoneHint,
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
  const _Text({required this.task});

  final ThreadTask task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final done = task.state == DotState.done;
    final muted = t.colors.muted;
    final meta = Wrap(
      spacing: DotSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(task.timeRange, style: t.styles.rowMeta),
        if (task.state == DotState.missed)
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
      style: t.styles.rowTitle.copyWith(
        color: done || task.state == DotState.skipped ? muted : null,
        decoration: done ? TextDecoration.lineThrough : null,
        decorationColor: muted,
      ),
    );
    // Wide (the Mac spread's card): time beside the title; else above it.
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth >= DotSize.wideRowFrom
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: DotSize.wideRowMeta, child: meta),
                Expanded(child: title),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [meta, title],
            ),
    );
  }
}

/// The round done circle at a row's end (`Main`): a second, larger target
/// for the same toggle as the dot, so it adds no semantics of its own.
class DoneCircle extends StatelessWidget {
  const DoneCircle({required this.color, this.onTap, this.width, super.key});

  final Color color;
  final VoidCallback? onTap;

  /// Stroke width; the live row's circle is heavier.
  final double? width;

  static const double diameter = DotSize.rowDot - DotSpace.s;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: DotTouch.android,
          child: Center(
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: width ?? DotSize.smallDotOutline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    this.grip,
    super.key,
  });

  final AxisPiece piece;
  final Widget child;
  final Widget? dot;
  final Widget? trailing;

  /// Resize grip at the bottom of the axis, over the segment's end.
  final Widget? grip;

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
        if (grip case final g?)
          PositionedDirectional(
            start: (threadAxisWidth - DotTouch.min) / 2,
            bottom: 0,
            child: g,
          ),
      ],
    );
  }
}
