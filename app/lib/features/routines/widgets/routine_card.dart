import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/features/routines/widgets/routine_text.dart';
import 'package:dottoday/shared/dot/mini_ring.dart';
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
        color: t.colors.card,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.hairline, width: DotSpace.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.m,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: DotSpace.xs),
              child: ExcludeSemantics(
                child: RoutineMiniThread(routine: routine),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.xs,
                children: [
                  Semantics(
                    header: true,
                    child: Text(routine.title, style: t.styles.cardTitle),
                  ),
                  Text(
                    routineSummary(context, routine, use24h: use24h),
                    style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
                  ),
                  Wrap(
                    spacing: DotSpace.xs,
                    runSpacing: DotSpace.xs,
                    children: [
                      for (final i in routine.items) _StepChip(item: i),
                    ],
                  ),
                  const SizedBox(height: DotSpace.xs),
                  Wrap(
                    spacing: DotSpace.s,
                    runSpacing: DotSpace.s,
                    children: [
                      FilledButton(
                        onPressed: onDrop,
                        style: _compact(t),
                        child: Text(dropLabel),
                      ),
                      OutlinedButton(
                        onPressed: onEdit,
                        style: _compact(t),
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

/// The card's buttons at the board's size (E-R2-22): the button face,
/// 44 high, a 44 target kept.
ButtonStyle _compact(DotTheme t) => ButtonStyle(
  textStyle: WidgetStatePropertyAll(t.styles.button),
  minimumSize: const WidgetStatePropertyAll(Size(0, DotTouch.min)),
  padding: const WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: DotSpace.l),
  ),
);

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
          horizontal: DotSpace.s + DotSpace.xxs,
          vertical: DotSpace.xxs + DotSpace.xxs,
        ),
        child: Text(
          item.title,
          style: t.styles.rowMeta.copyWith(color: tone.ink),
        ),
      ),
    );
  }
}

/// The routine as a small vertical thread (E-R2-22): a hollow ring per
/// step in its colour, joined by a short link, and the moon under a
/// routine that ends at Wind Down.
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
        for (final (i, s) in steps.indexed) ...[
          if (i > 0)
            Container(
              width: DotSize.miniRingStroke,
              height: DotSize.miniLink,
              color: t.tasks[TaskColor.fromKey(s.colorKey)].color,
            ),
          MiniRing(color: TaskColor.fromKey(s.colorKey)),
        ],
        if (routine.anchor == RoutineAnchor.bed) ...[
          const SizedBox(height: DotSpace.xxs),
          DotIcon(
            DotGlyphs.moon,
            color: t.tasks[TaskColor.violet].ink,
            size: DotSize.miniRing,
          ),
        ],
      ],
    );
  }
}
