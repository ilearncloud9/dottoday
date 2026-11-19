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
/// skipped, pinned (lock), recurring (repeat glyph), imported (calendar
/// badge, docs/02 F1.10) and today's one thing (ring + "Your one thing",
/// docs/15 §8). The live task is
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
    this.solid,
    super.key,
  });

  final ThreadTask task;

  /// The colour the thread arrives in when this row is behind now (from
  /// `threadSolid`); null draws it dotted, ahead (E rules §5.2).
  final TaskColor? solid;

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
    final tasks = DotTheme.of(context).tasks;
    final done = task.state == DotState.done;
    return ThreadRowFrame(
      piece: SegmentPiece(
        color: tasks[task.color].color,
        state: task.state,
        above: switch (solid) {
          final c? => tasks[c].color,
          null => null,
        },
        ghost: task.reality?.ghost,
      ),
      // Done dots are a size smaller (E rules §5.1).
      dot: taskRowDot(
        context,
        task,
        done && dotSize == DotSize.threadDot ? DotSize.threadDoneDot : dotSize,
        onOpen,
      ),
      // A calendar event is read-only: no done check (E rules §4.4).
      trailing: !doneCircle || onToggleDone == null || task.imported
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
                padding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
                child: _Text(task: task, large: dotSize >= DotSize.threadDot),
              ),
            ),
          ),
          if (task.smallestStep case final text?)
            Padding(
              padding: const EdgeInsets.only(bottom: DotSpace.s),
              child: SmallestStepLine(text: text, onStart: onStart),
            ),
          if (onUnstick case final answer?)
            Padding(
              padding: const EdgeInsets.only(bottom: DotSpace.s),
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
    oneThing: task.oneThing,
    calendar: task.imported,
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
  if (task.oneThing) label = l10n.rowOneThing(label);
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
        if (task.oneThing) Text(l10n.oneThingMeta, style: metaStyle),
      ],
    );
    final title = Text(
      task.title,
      // Done reads grey, never struck through (E rules §4.4).
      style: (large ? t.styles.threadTitle : t.styles.rowTitle).copyWith(
        color: done || task.state == DotState.skipped ? muted : null,
      ),
    );
    final note = switch (task.reality?.note) {
      final n? => Text(n, style: _plan(t)),
      null => null,
    };
    final stacked = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [meta, title, ?note],
    );
    // The day thread's rows keep the time above the title at every width
    // (Concept E, E-FullA-v2 web Day). Smaller wide rows put it beside.
    if (large) return stacked;
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth >= DotSize.wideRowFrom
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: DotSize.wideRowMeta, child: meta),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, ?note],
                  ),
                ),
              ],
            )
          : stacked,
    );
  }

  /// The plan's words on the Reality thread: quieter than the times.
  static TextStyle _plan(DotTheme t) =>
      t.styles.rowMeta.copyWith(color: t.colors.muted);
}

/// Lays out one thread row: [dot] on the axis over the [piece] painted
/// down it, [child] beside it and an optional [trailing] control, all
/// centred on the row (E rules §5.2), which is at least [minHeight] tall.
/// Geometry is directional, so the thread runs down the start edge in RTL.
class ThreadRowFrame extends StatelessWidget {
  const ThreadRowFrame({
    required this.piece,
    required this.child,
    this.dot,
    this.trailing,
    this.minHeight = 0,
    this.card = false,
    super.key,
  });

  final AxisPiece piece;
  final Widget child;
  final Widget? dot;
  final Widget? trailing;
  final double minHeight;

  /// The now card (E rules §5.3): the row sits on a card that reaches
  /// [DotSpace.nowCard] past each side and covers the thread.
  final bool card;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return CustomPaint(
      painter: _AxisAtStart(
        ThreadAxisPainter(
          piece: piece,
          hairline: c.threadAhead,
          accent: c.accent,
          card: c.raised,
          ghostSide: Directionality.of(context) == TextDirection.rtl ? 1 : -1,
        ),
        rtl: Directionality.of(context) == TextDirection.rtl,
        card: card ? (fill: c.raised, edge: c.hairline) : null,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Row(
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
      ),
    );
  }
}

/// Paints [axis] in the [threadAxisWidth] column at the row's start edge.
/// With [card], the now card over it: radius 24, a 1 px inset hairline.
final class _AxisAtStart extends CustomPainter {
  const _AxisAtStart(this.axis, {required this.rtl, this.card});

  final ThreadAxisPainter axis;
  final bool rtl;
  final ({Color fill, Color edge})? card;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(rtl ? size.width - threadAxisWidth : 0, 0);
    axis.paint(canvas, Size(threadAxisWidth, size.height));
    canvas.restore();
    final card = this.card;
    if (card == null) return;
    final box = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        -DotSpace.nowCard,
        0,
        size.width + DotSpace.nowCard,
        size.height,
      ),
      const Radius.circular(DotRadii.cardLarge),
    );
    canvas
      ..drawRRect(box, Paint()..color = card.fill)
      ..drawRRect(
        box.deflate(DotSpace.hairline / 2),
        Paint()
          ..color = card.edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSpace.hairline,
      );
  }

  @override
  bool shouldRepaint(_AxisAtStart old) =>
      old.rtl != rtl || old.card != card || axis.shouldRepaint(old.axis);
}
