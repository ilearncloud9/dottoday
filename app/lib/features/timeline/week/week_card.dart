import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// A task on the Week board (`A-mac-week-alt3-board`): its dot and title,
/// and when there is room the time ("38 min left" while live, "· skipped").
/// Done titles are struck; the live card has the accent outline.
class WeekCard extends StatelessWidget {
  const WeekCard({
    required this.task,
    required this.height,
    this.onOpen,
    super.key,
  });

  final ThreadTask task;
  final double height;
  final VoidCallback? onOpen;

  /// Tall enough for a second line.
  static const double _twoLines = 48;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final live = task.state == DotState.live;
    return Semantics(
      button: onOpen != null,
      label: taskRowLabel(context.l10n, task),
      excludeSemantics: true,
      child: Material(
        color: c.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.card),
          side: BorderSide(
            color: live ? c.accent : c.hairline,
            width: live ? DotSize.smallDotOutline : DotSpace.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DotSpace.s,
              vertical: DotSpace.xxs,
            ),
            // A card's height is its time; at large text the lines clip at
            // the card's edge (the label carries the whole reading).
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxHeight: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleLine(task: task),
                    if (height >= _twoLines) _SecondLine(task: task),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleLine extends StatelessWidget {
  const _TitleLine({required this.task});

  final ThreadTask task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final done = task.state == DotState.done;
    final faded = done || task.state == DotState.skipped;
    return Row(
      spacing: DotSpace.xs,
      children: [
        TaskDot(
          color: task.color,
          icon: task.icon,
          state: task.state,
          progress: task.progress,
          size: DotSize.pickerDot,
          label: task.title,
        ),
        Expanded(
          child: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.styles.body.copyWith(
              color: faded ? c.muted : null,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: c.muted,
            ),
          ),
        ),
      ],
    );
  }
}

/// "9:00 – 11:30", "38 min left" or "3:00 – 5:00 · skipped".
class _SecondLine extends StatelessWidget {
  const _SecondLine({required this.task});

  final ThreadTask task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final live = task.state == DotState.live;
    final text = switch (task) {
      ThreadTask(state: DotState.live, minutesLeft: final left?) =>
        l10n.weekCardLeft(left),
      ThreadTask(state: DotState.skipped) => l10n.weekCardSkipped(
        task.timeRange,
      ),
      _ => task.timeRange,
    };
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: t.styles.rowMeta.copyWith(color: live ? t.colors.accentInk : null),
    );
  }
}
