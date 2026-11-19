import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/grid_scale.dart';
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
    final scale = GridScale.of(context);
    return Padding(
      padding: EdgeInsets.all(scale.blockPad),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxHeight: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: scale.touch ? DotSpace.s : DotSpace.xs + DotSpace.xxs,
            children: [
              _ring(task, scale.ringFor(live: task.state == DotState.live)),
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
                        style: scale
                            .title(t.styles)
                            .copyWith(color: _titleColor(t.colors, task)),
                      ),
                      Text(
                        _time(context.l10n, task),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: scale.meta(t.styles),
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
    final scale = GridScale.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final dot = scale.pillDot(box.maxHeight);
        // The dot's centre sits on the thread (pointer: 25 in from the
        // column's edge).
        final left =
            scale.threadX +
            DotSize.gridThread / 2 -
            DotSize.gridInset -
            dot / 2;
        return _pillRow(t, scale, dot, left);
      },
    );
  }

  Widget _pillRow(DotTheme t, GridScale scale, double dot, double left) {
    return ClipRect(
      child: OverflowBox(
        alignment: AlignmentDirectional.centerStart,
        maxHeight: double.infinity,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: left, end: DotSpace.xs),
          child: Row(
            spacing: scale.touch ? DotSpace.s : DotSpace.s - DotSpace.xxs / 2,
            children: [
              _ring(task, dot),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: scale
                      .pill(t.styles)
                      .copyWith(color: _titleColor(t.colors, task)),
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
    final scale = GridScale.of(context);
    return Padding(
      padding: EdgeInsets.all(scale.touch ? DotSpace.s : DotSpace.xs),
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
                scale.touch
                    ? DotSize.gridTouchPillDotTall
                    : DotSize.gridPillDot + DotSpace.xs - DotSpace.hairline,
              ),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: scale
                      .pill(t.styles)
                      .copyWith(color: _titleColor(t.colors, task)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
