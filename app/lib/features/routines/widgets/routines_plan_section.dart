import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/routines/routine_providers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/features/routines/routine_flows.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Plan panel's Routines (E-FullA-v2, ED-184): each routine as a card,
/// "4 steps · 40 min"; a tap proposes its steps on [day] (the shown day),
/// written only on Accept (the proposal rule).
class RoutinesPlanSection extends ConsumerWidget {
  const RoutinesPlanSection({
    required this.day,
    required this.today,
    super.key,
  });

  final DateTime day;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider).value ?? const <Routine>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        for (final r in routines)
          _Card(
            key: ValueKey(r.id),
            routine: r,
            onTap: () =>
                unawaited(dropRoutine(context, r, date: day, today: today)),
          ),
      ],
    );
  }
}

/// The number of routines, for the section's heading.
int routineCount(WidgetRef ref) =>
    ref.watch(routinesProvider).value?.length ?? 0;

class _Card extends StatelessWidget {
  const _Card({required this.routine, required this.onTap, super.key});

  final Routine routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final first = routine.items.firstOrNull;
    final meta = l10n.statusHintJoin(
      l10n.routineSteps(routine.items.length),
      formatDurationShort(l10n, routine.spanMinutes),
    );
    return Semantics(
      button: true,
      label: l10n.statusHintJoin(routine.title, meta),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: t.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.card),
          side: BorderSide(color: t.colors.hairline),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DotRadii.card),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.s + DotSpace.xxs),
            child: Row(
              spacing: DotSpace.s + DotSpace.xxs,
              children: [
                TaskDot(
                  color: TaskColor.fromKey(first?.colorKey),
                  icon: TaskIcon.fromKey(first?.iconKey),
                  state: DotState.upcoming,
                  label: routine.title,
                  size: DotSize.pickerDot + DotSpace.s + DotSpace.xxs,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(routine.title, style: t.styles.cardTitle),
                      Text(meta, style: t.styles.rowMeta),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
