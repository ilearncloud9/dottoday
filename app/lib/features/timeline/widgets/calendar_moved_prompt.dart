import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/calendar/calendar_moves.dart';
import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/prompt_card.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Standup moved to 10:30 · Rebalance?" (docs/09 M11.1b, 11 C1): the
/// calendar moved an event later into today's plan. Rebalance opens from
/// the event's old end with the move as the delay, the event itself kept
/// where the calendar put it. Either button puts the prompt away.
class CalendarMovedPrompt extends ConsumerWidget {
  const CalendarMovedPrompt({
    required this.move,
    required this.data,
    super.key,
  });

  final CalendarMove move;
  final TimelineData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final time = timeOfUtc(
      context,
      data.day.location,
      move.toUtc,
      use24h: use24hFor(context, data.settings.use24h),
    );
    void dismiss() =>
        ref.read(calendarMovesProvider.notifier).dismiss(move.occurrenceId);
    return PromptCard(
      title: l10n.calendarMovedTitle,
      child: PromptNudge(
        detail: l10n.calendarMovedDetail(move.title, time),
        action: l10n.calendarMovedAction,
        onAction: () {
          dismiss();
          unawaited(
            openRebalance(
              ProviderScope.containerOf(context, listen: false),
              l10n,
              today: data.day.date,
              fromUtc: move.oldEndUtc,
              deltaMin: move.deltaMin,
              subtitle: l10n.rebalanceMoved(move.title, time),
              keep: {move.occurrenceId},
              title: l10n.calendarMovedTitle,
            ),
          );
        },
        onNotNow: dismiss,
      ),
    );
  }
}
