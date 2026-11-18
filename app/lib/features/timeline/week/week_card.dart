import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A task on the hour grid (E-FullA-v2 Week, M19.2 part 2): a card as tall
/// as its time with its ring on the column's thread, the title and the
/// time. A task under half an hour is a one-line pill; a block narrowed by
/// an overlap keeps a small ring and its title. Done titles go quiet; a
/// calendar event is sunk with a dashed edge.
///
/// A task Smallest step or Unstick asks about (M10.6, M10.7) shows that
/// cue as the card's last line, its own tap target ([onCue]); a card too
/// short for it keeps the cue as a screen-reader action.
class WeekCard extends StatelessWidget {
  const WeekCard({
    required this.task,
    required this.height,
    this.narrow = false,
    this.onOpen,
    this.onCue,
    super.key,
  });

  final ThreadTask task;
  final double height;

  /// Sharing its column with an overlapping task.
  final bool narrow;
  final VoidCallback? onOpen;

  /// The cue tapped: Smallest step's Start or Unstick's question.
  final VoidCallback? onCue;

  /// Tall enough for the cue under the title and time (an hour).
  static const double _cueRoom = DotSize.gridHour - DotSpace.s;

  bool get _pill => task.minutes < WeekScale.pillUnder;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final l10n = context.l10n;
    final cue = onCue == null ? null : weekCardCue(l10n, task);
    final cueLine = cue != null && !_pill && !narrow && height >= _cueRoom;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        _pill ? DotSize.gridPill / 2 : DotRadii.block,
      ),
    );
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Semantics(
            button: onOpen != null,
            label: taskRowLabel(l10n, task),
            excludeSemantics: true,
            child: InkWell(onTap: onOpen, customBorder: shape, child: _lines()),
          ),
        ),
        if (cueLine) GridCueLine(text: cue, onTap: onCue!),
      ],
    );
    return Semantics(
      container: true,
      customSemanticsActions: cue == null || cueLine
          ? null
          : {CustomSemanticsAction(label: cue): onCue!},
      child: Material(
        color: task.imported ? c.sunk : c.card,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: task.imported
            ? CustomPaint(
                foregroundPainter: DashedPillPainter(
                  color: c.hairlineStrong,
                  radius: _pill ? null : DotRadii.block,
                ),
                child: body,
              )
            : body,
      ),
    );
  }

  Widget _lines() {
    if (_pill) return _Pill(task: task);
    if (narrow) return _Narrow(task: task);
    return _Block(task: task);
  }
}

/// The cue a grid block carries for [task], if any: "Just Gather
/// documents · 10 min?" or "What's the very first thing you'd physically
/// do?".
String? weekCardCue(AppLocalizations l10n, ThreadTask task) =>
    task.smallestStep ?? (task.unstick ? l10n.unstickPrompt : null);

/// The ring for [task] at [size], on the column's thread.
Widget _ring(ThreadTask task, double size) => TaskDot(
  color: task.color,
  icon: task.icon,
  state: task.state,
  progress: task.progress,
  calendar: task.imported,
  size: size,
  label: task.title,
);

/// Done and skipped titles go quiet (E-FullA-v2's Monday).
Color? _titleColor(DotColors c, ThreadTask task) =>
    task.state == DotState.done || task.state == DotState.skipped
    ? c.secondary
    : null;

/// A block (E-FullA-v2): the 32 ring at 5, 5; title and time beside it.
/// Its height is its time, so at large text the lines clip at its edge
/// (the label carries the whole reading).
class _Block extends StatelessWidget {
  const _Block({required this.task});

  final ThreadTask task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    const pad = DotSpace.xs + DotSpace.hairline;
    return Padding(
      padding: const EdgeInsets.all(pad),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxHeight: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.xs + DotSpace.xxs,
            children: [
              _ring(task, DotSize.gridRing),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: DotSpace.hairline),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.styles.gridTitle.copyWith(
                          color: _titleColor(t.colors, task),
                        ),
                      ),
                      Text(
                        _time(context.l10n, task),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.styles.gridMeta,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "9:00 – 11:00", "18 min left" while live, "… · skipped".
  static String _time(AppLocalizations l10n, ThreadTask task) => switch (task) {
    ThreadTask(state: DotState.live, minutesLeft: final left?) =>
      l10n.weekCardLeft(left),
    ThreadTask(state: DotState.skipped) => l10n.weekCardSkipped(task.timeRange),
    _ => task.timeRange,
  };
}

/// A short task's pill (E-FullA-v2's Team standup): the 17 dot on the
/// thread and one line of title.
class _Pill extends StatelessWidget {
  const _Pill({required this.task});

  final ThreadTask task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    // The dot's centre sits on the thread, 25 in from the column's edge.
    const left =
        DotSize.gridThreadX +
        DotSize.gridThread / 2 -
        DotSize.gridInset -
        DotSize.gridPillDot / 2;
    return ClipRect(
      child: OverflowBox(
        alignment: AlignmentDirectional.centerStart,
        maxHeight: double.infinity,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: left,
            end: DotSpace.xs,
          ),
          child: Row(
            spacing: DotSpace.s - DotSpace.xxs / 2,
            children: [
              _ring(task, DotSize.gridPillDot),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.styles.gridPill.copyWith(
                    color: _titleColor(t.colors, task),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A block narrowed by an overlap (E-FullA-v2's Call with Sam): a 20 ring
/// and two lines of title.
class _Narrow extends StatelessWidget {
  const _Narrow({required this.task});

  final ThreadTask task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DotSpace.xs),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxHeight: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.xs,
            children: [
              _ring(
                task,
                DotSize.gridPillDot + DotSpace.xs - DotSpace.hairline,
              ),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.styles.gridPill.copyWith(
                    color: _titleColor(t.colors, task),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
