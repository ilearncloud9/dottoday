import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// What a grid block shows inside its card: a short task's pill, a block
/// narrowed by an overlap, or the full block (E-FullA-v2 Week).
class GridBlockLines extends StatelessWidget {
  const GridBlockLines({
    required this.task,
    required this.pill,
    required this.narrow,
    super.key,
  });

  final ThreadTask task;
  final bool pill;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    if (pill) return _Pill(task: task);
    if (narrow) return _Narrow(task: task);
    return _Block(task: task);
  }
}

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
