import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/widgets/sheet_actions.dart';
import 'package:dottoday/shared/dot/done_circle.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Also now" and "Next" under the running task (E-PhonesMinimal frame
/// 1; E rules §5.2: label 700 12, the 32 / 36 dot, title 700 16, time 14).
/// A tap opens the task.
class NowRow extends StatelessWidget {
  const NowRow({
    required this.label,
    required this.task,
    required this.time,
    required this.state,
    required this.onTap,
    this.progress = 0,
    this.meta,
    this.trailing,
    this.more,
    super.key,
  });

  final String label;
  final Occurrence task;

  /// "10:30 AM": its start.
  final String time;
  final DotState state;
  final double progress;
  final VoidCallback onTap;

  /// "· not done" under the title, for an earlier task (ED-329).
  final String? meta;

  /// The row's done circle, for an earlier task.
  final Widget? trailing;

  /// "· 4 more" after Next's title in the wide pane (E-Minimal).
  final String? more;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final android = DotIdiom.of(context) == DotIdiom.material;
    final size = android ? DotSize.nowRowDotAndroid : DotSize.nowRowDot;
    // Large text: the time under the title, so the title keeps its room.
    final below =
        MediaQuery.textScalerOf(context).scale(1) > DotSize.stackAbove;
    final when = Text(
      time,
      style: (meta == null ? t.styles.rowTitle : t.styles.rowMeta).copyWith(
        color: below ? t.colors.muted : t.colors.text,
      ),
    );
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Row(
            spacing: DotSpace.m,
            children: [
              SizedBox(
                width: DotSize.nowRowLabel,
                child: Text(
                  label,
                  style: t.styles.rowMeta.copyWith(
                    color: t.colors.muted,
                    fontWeight: android ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
              ),
              TaskDot(
                color: TaskColor.fromKey(task.colorKey),
                icon: TaskIcon.fromKey(task.iconKey),
                state: state,
                progress: progress,
                label: task.title,
                size: size,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: task.title,
                        children: [
                          if (more case final m?)
                            TextSpan(
                              text: ' $m', // l10n-ignore: a space before
                              style: t.styles.rowMeta.copyWith(
                                color: t.colors.muted,
                              ),
                            ),
                        ],
                      ),
                      // An earlier task is quieter (E-R2-26 frame 7).
                      style: meta == null
                          ? t.styles.rowTitle.copyWith(
                              fontWeight: FontWeight.w700,
                            )
                          : t.styles.rowMeta.copyWith(color: t.colors.text),
                    ),
                    if (meta case final m?)
                      Text(
                        m,
                        style: t.styles.rowMeta.copyWith(color: t.colors.muted),
                      ),
                    if (below) when,
                  ],
                ),
              ),
              if (!below) when,
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// A task that ended without a tick, under Next up (E-R2-26 frames 7–8,
/// ED-329): "Earlier" on the first, "· not done", never red, and its done
/// circle, so it stays one tap from done.
class EarlierRow extends ConsumerWidget {
  const EarlierRow({
    required this.task,
    required this.first,
    required this.time,
    super.key,
  });

  final Occurrence task;
  final bool first;
  final String time;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return NowRow(
      label: first ? l10n.threadEarlier : '',
      task: task,
      time: time,
      state: DotState.upcoming,
      meta: l10n.rowMissedMeta,
      onTap: () => openTask(context, task.id),
      trailing: DoneCircle(
        color: TaskColor.fromKey(task.colorKey),
        done: false,
        title: task.title,
        onTap: () => unawaited(markDone(context, ref, task)),
      ),
    );
  }
}

/// Next up between tasks (E-R2-26 "Now at 8:30, between tasks"): the next
/// task as a large ring in its colour with its icon; "NEXT UP", its title,
/// its time and the free time until it.
class NextUpRing extends StatelessWidget {
  const NextUpRing({required this.task, super.key});

  final Occurrence task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final s = t.tasks[TaskColor.fromKey(task.colorKey)];
    final glyph = TaskIcon.fromKey(task.iconKey).glyph;
    return ExcludeSemantics(
      child: Container(
        width: DotSize.nextUpRing,
        height: DotSize.nextUpRing,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: t.colors.raised,
          border: Border.all(color: s.ring, width: DotSize.nextUpStroke),
        ),
        child: glyph == null
            ? null
            : DotIcon(glyph, color: s.ring, size: DotSize.nextUpGlyph),
      ),
    );
  }
}
