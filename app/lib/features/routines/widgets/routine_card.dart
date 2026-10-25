import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/features/routines/widgets/routine_text.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:flutter/material.dart';

/// One routine on the Routines page (`B-ios-routines`, 11 C2): its mini
/// thread, name, "4 steps · 1 h 15 · starts at Wake Up", its steps as
/// colour chips, Drop on today and Edit.
class RoutineCard extends StatelessWidget {
  const RoutineCard({
    required this.routine,
    required this.dropLabel,
    required this.onDrop,
    required this.onEdit,
    this.use24h,
    super.key,
  });

  final Routine routine;

  /// "Drop on today", or "Drop on Thu, Oct 22" for the strip's day.
  final String dropLabel;
  final VoidCallback? onDrop;
  final VoidCallback onEdit;
  final bool? use24h;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline, width: DotSpace.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.l,
          children: [
            ExcludeSemantics(child: RoutineMiniThread(routine: routine)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.s,
                children: [
                  Semantics(
                    header: true,
                    child: Text(routine.title, style: t.styles.cardTitle),
                  ),
                  Text(
                    routineSummary(context, routine, use24h: use24h),
                    style: t.styles.body.copyWith(color: t.colors.muted),
                  ),
                  Wrap(
                    spacing: DotSpace.xs,
                    runSpacing: DotSpace.xs,
                    children: [
                      for (final i in routine.items) _StepChip(item: i),
                    ],
                  ),
                  const SizedBox(height: DotSpace.s),
                  Wrap(
                    spacing: DotSpace.s,
                    runSpacing: DotSpace.s,
                    children: [
                      FilledButton(onPressed: onDrop, child: Text(dropLabel)),
                      OutlinedButton(
                        onPressed: onEdit,
                        child: Text(l10n.routineEdit),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A step's name on its colour's tint (the all-day chip style).
class _StepChip extends StatelessWidget {
  const _StepChip({required this.item});

  final RoutineItem item;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final tone = t.tasks[TaskColor.fromKey(item.colorKey)];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.tint,
        borderRadius: BorderRadius.circular(DotRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.xs,
        ),
        child: Text(
          item.title,
          style: t.styles.rowMeta.copyWith(color: tone.ink),
        ),
      ),
    );
  }
}

/// The routine as a small vertical thread: a picker-size dot per step and
/// a short dotted segment in its colour, the moon cap under a routine that
/// ends at Bedtime.
class RoutineMiniThread extends StatelessWidget {
  const RoutineMiniThread({required this.routine, super.key});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final steps = [...routine.items]
      ..sort((a, b) => a.offsetMin.compareTo(b.offsetMin));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final i in steps) ...[
          TaskDot(
            color: TaskColor.fromKey(i.colorKey),
            icon: TaskIcon.fromKey(i.iconKey),
            state: DotState.upcoming,
            label: i.title,
            size: DotSize.pickerDot,
          ),
          CustomPaint(
            size: Size(DotSize.pickerDot, _segment(i.durationMin)),
            painter: ThreadAxisPainter(
              piece: SegmentPiece(
                color: TaskColor.fromKey(i.colorKey).color,
                state: DotState.upcoming,
                dotSize: 0,
              ),
              hairline: t.colors.hairline,
              accent: t.colors.accent,
              accentTint: t.colors.accentTint,
            ),
          ),
        ],
        if (routine.anchor == RoutineAnchor.bed)
          DotIcon(
            DotGlyphs.moon,
            color: t.tasks[TaskColor.violet].ink,
            size: DotSize.rowIcon,
          ),
      ],
    );
  }

  /// A step's segment grows with its length, within two sizes.
  static double _segment(int minutes) =>
      (DotSpace.l * minutes / 30).clamp(DotSpace.m, DotSpace.xxl * 1.5);
}
