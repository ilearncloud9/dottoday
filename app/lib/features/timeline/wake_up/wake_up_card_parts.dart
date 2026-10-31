import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

// The Wake Up card's pieces (docs/15 §5; derived from Today's live-dot
// artboard and the Wind Down review, no reference render). Concept A
// components only: DayDot, TaskRow, TaskDot.

/// "Good morning. Saturday, October 31." and the day dot with "5 planned
/// · ends 21:30" (15 §5 steps 1–2). Nothing is done yet, so the ring is
/// empty; no name, no streak.
class WakeUpGreeting extends StatelessWidget {
  const WakeUpGreeting({
    required this.date,
    required this.planned,
    required this.ends,
    this.showDot = true,
    super.key,
  });

  final String date;
  final int planned;
  final String ends;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      spacing: DotSpace.m,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.wakeUpCardGreeting(date),
            style: t.styles.pageTitle,
            textAlign: TextAlign.center,
          ),
        ),
        if (showDot && planned > 0) ...[
          const DayDot(progress: 0, size: DotSize.wakeUpDayDot),
          Text(
            l10n.wakeUpCardPlanned(planned, ends),
            style: t.styles.rowMeta,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// A small caption over a section ("First", "Next").
class WakeUpCaption extends StatelessWidget {
  const WakeUpCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text.toUpperCase(), style: DotTheme.of(context).styles.caption),
  );
}

/// The first dot, large, with its first step when it has one (15 §5
/// step 3). Tapping it opens its sheet.
class WakeUpFirstDot extends StatelessWidget {
  const WakeUpFirstDot({
    required this.task,
    required this.onOpen,
    this.step,
    super.key,
  });

  final ThreadTask task;
  final Subtask? step;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final step = this.step;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WakeUpCaption(l10n.wakeUpCardFirst),
        TaskRow(task: task, doneCircle: false, onOpen: onOpen),
        if (step != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: DotSize.threadDot + DotSpace.m,
            ),
            child: Text(switch (step.durationMin) {
              final min? => l10n.wakeUpCardFirstStep(
                step.title,
                formatDurationShort(l10n, min),
              ),
              null => l10n.wakeUpCardFirstStepShort(step.title),
            }, style: t.styles.rowMeta),
          ),
      ],
    );
  }
}

/// The next dots as a short row of dots, each opening its sheet (15 §5
/// step 4).
class WakeUpNextDots extends StatelessWidget {
  const WakeUpNextDots({required this.tasks, required this.onOpen, super.key});

  final List<ThreadTask> tasks;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: DotSpace.s,
    children: [
      WakeUpCaption(context.l10n.wakeUpCardNext),
      Wrap(
        spacing: DotSpace.m,
        runSpacing: DotSpace.s,
        children: [
          for (final task in tasks)
            TaskDot(
              color: task.color,
              icon: task.icon,
              state: task.state,
              label: context.l10n.rowLabel(task.title, task.timeRange),
              size: DotSize.rowDot,
              onTap: () => onOpen(task.id),
            ),
        ],
      ),
    ],
  );
}

/// Today's events and the Inbox count, each only while its switch is on
/// (15 §5 step 5).
class WakeUpChips extends StatelessWidget {
  const WakeUpChips({required this.lines, super.key});

  final List<(DotGlyph, String)> lines;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        for (final (glyph, text) in lines)
          Row(
            spacing: DotSpace.s,
            children: [
              DotIcon(glyph, color: t.colors.muted, size: DotSize.navIcon),
              Expanded(child: Text(text, style: t.styles.body)),
            ],
          ),
      ],
    );
  }
}

/// "You're up 25 min after plan." with **Shift the rest?** (15 §5 step 6):
/// a fact and an offer, never a reproach (15 §12).
class WakeUpLateLine extends StatelessWidget {
  const WakeUpLateLine({
    required this.minutes,
    required this.onShift,
    super.key,
  });

  final int minutes;
  final VoidCallback onShift;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.wakeUpCardLate(minutes), style: t.styles.body),
        TextButton(onPressed: onShift, child: Text(l10n.wakeUpCardShift)),
      ],
    );
  }
}
