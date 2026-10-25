import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A task on the Week board (`A-mac-week-alt3-board`): its dot and title,
/// and when there is room the time ("38 min left" while live, "· skipped").
/// Done titles are struck; the live card has the accent outline.
///
/// A task Smallest step or Unstick asks about (M10.6, M10.7) shows that
/// cue as the card's last line, its own tap target ([onCue]); a card too
/// short for it keeps the cue as a screen-reader action.
class WeekCard extends StatelessWidget {
  const WeekCard({
    required this.task,
    required this.height,
    this.onOpen,
    this.onCue,
    super.key,
  });

  final ThreadTask task;
  final double height;
  final VoidCallback? onOpen;

  /// The cue tapped: Smallest step's Start or Unstick's question.
  final VoidCallback? onCue;

  /// Tall enough for a second line.
  static const double _twoLines = 48;

  /// Tall enough for the time and the cue under the title.
  static const double _threeLines = 68;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final l10n = context.l10n;
    final live = task.state == DotState.live;
    final cue = onCue == null ? null : weekCardCue(l10n, task);
    final cueLine = cue != null && height >= _twoLines;
    final timeLine = height >= (cueLine ? _threeLines : _twoLines);
    return Semantics(
      container: true,
      customSemanticsActions: cue == null || cueLine
          ? null
          : {CustomSemanticsAction(label: cue): onCue!},
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Semantics(
                button: onOpen != null,
                label: taskRowLabel(l10n, task),
                excludeSemantics: true,
                child: InkWell(
                  onTap: onOpen,
                  child: _Lines(
                    children: [
                      _TitleLine(task: task),
                      if (timeLine) _SecondLine(task: task),
                    ],
                  ),
                ),
              ),
            ),
            if (cueLine) _CueLine(text: cue, onTap: onCue!),
          ],
        ),
      ),
    );
  }
}

/// The cue a Week card carries for [task], if any: "Just Gather
/// documents · 10 min?" or "What's the very first thing you'd physically
/// do?".
String? weekCardCue(AppLocalizations l10n, ThreadTask task) =>
    task.smallestStep ?? (task.unstick ? l10n.unstickPrompt : null);

/// A card's text, padded; a card's height is its time, so at large text
/// the lines clip at the card's edge (the label carries the whole reading).
class _Lines extends StatelessWidget {
  const _Lines({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: DotSpace.s,
      vertical: DotSpace.xxs,
    ),
    child: ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        maxHeight: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ),
  );
}

/// The cue line: quiet accent text (11 §D, no warning colour).
class _CueLine extends StatelessWidget {
  const _CueLine({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: text,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.s,
            vertical: DotSpace.xxs,
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.styles.rowMeta.copyWith(color: t.colors.accentInk),
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
