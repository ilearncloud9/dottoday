import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/calendar/calendar_moves.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/domain/scheduling/calendar_move_prompt.dart';
import 'package:dottoday/domain/scheduling/day_review.dart';
import 'package:dottoday/domain/scheduling/running_late.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_prompts.dart';
import 'package:dottoday/features/timeline/widgets/calendar_moved_prompt.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:dottoday/features/timeline/widgets/inbox_nudge_card.dart';
import 'package:dottoday/features/timeline/widgets/prompt_card.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:dottoday/features/timeline/widgets/siri_tip_card.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Above today's thread (docs/09 M3f.5): from Bedtime, the Day review
/// while one-off tasks are unfinished; before it, with "Running-late
/// nudge" on, "Running late?" once a task ended unticked; otherwise, with
/// the "Plan your inbox" nudge on, that card (F3.3, [InboxNudgeCard]).
/// On the week's last day, after the Day review, "This week" (M12.1).
/// "Not now" puts it away for the day (this session). Nothing on other
/// days. A task over [rebalanceOverrunMin] past its end opens Rebalance;
/// before the nudge, an event the calendar moved into the plan offers it
/// ([CalendarMovedPrompt], M11.1b).
class TodayPrompt extends ConsumerWidget {
  const TodayPrompt({required this.date, required this.today, super.key});

  final DateTime date;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (date != today) return const SizedBox.shrink();
    // Low-energy mode: every nudge is off until Wake Up (11 D2, M12.2).
    if (watchLowEnergy(ref)) return const SizedBox.shrink();
    final data = ref.watch(timelineDataProvider(today)).value;
    if (data == null) return const SizedBox.shrink();
    final dismissed = ref.watch(dismissedPromptsProvider);
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final shape = DayShape.on(
      data.day.location,
      today,
      data.settings.boundaryFor(data.day.weekday),
    );
    void notNow(TodayPromptKind kind) =>
        ref.read(dismissedPromptsProvider.notifier).dismiss(kind, today);
    if (!now.isBefore(shape.bedUtc)) {
      if (!dismissed.contains((TodayPromptKind.review, today)) &&
          reviewOf(data.blocks).hasRest) {
        return _review(context, notNow);
      }
      final weekEnds =
          reviewWeek(today, data.settings.firstDayOfWeek).last == today;
      return weekEnds && !dismissed.contains((TodayPromptKind.week, today))
          ? _week(context, notNow)
          : const SizedBox.shrink();
    }
    final move = moveToRebalance(
      ref.watch(calendarMovesProvider).values,
      data.blocks,
      now,
    );
    if (move != null) return CalendarMovedPrompt(move: move, data: data);
    final missed = missedTask(data.blocks, now);
    if (!data.settings.runningLateNudge ||
        missed == null ||
        dismissed.contains((TodayPromptKind.late, today))) {
      // Nothing more pressing: the once-a-day inbox card (F3.3), and the
      // once-ever Siri tip on iPhone (M14.3; each hides itself).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InboxNudgeCard(
            enabled: data.settings.inboxNudge,
            today: today,
            shape: shape,
            now: now,
          ),
          const SiriTipCard(),
        ],
      );
    }
    return PromptCard(
      title: context.l10n.lateNudgeTitle,
      child: PromptNudge(
        detail: context.l10n.lateNudgeDetail(
          missed.title,
          now.difference(missed.endUtc!).inMinutes,
        ),
        action: context.l10n.lateNudgeAction,
        onAction: () => unawaited(_late(context, missed, now)),
        onNotNow: () => notNow(TodayPromptKind.late),
      ),
    );
  }
}

extension on TodayPrompt {
  /// The nudge's action: a task more than [rebalanceOverrunMin] past its
  /// end opens Rebalance straight away (11 C1, M11.1) with the overrun
  /// rounded up to 5 min; a fresher one the Running late sheet.
  Future<void> _late(BuildContext context, Occurrence missed, DateTime now) {
    final over = now.difference(missed.endUtc!).inMinutes;
    if (over <= rebalanceOverrunMin) {
      return showRunningLateSheet(context, today);
    }
    final l10n = context.l10n;
    final delta = (over / 5).ceil() * 5;
    return openRebalance(
      ProviderScope.containerOf(context, listen: false),
      l10n,
      today: today,
      fromUtc: now,
      deltaMin: delta,
      subtitle: l10n.rebalanceRanOver(
        missed.title,
        formatDurationShort(l10n, delta),
      ),
    );
  }

  /// Sunday at Bedtime (the week's last day): the weekly review (11 D1).
  Widget _week(BuildContext context, void Function(TodayPromptKind) notNow) =>
      PromptCard(
        title: context.l10n.weekReviewTitle,
        child: PromptNudge(
          detail: context.l10n.weekPromptDetail,
          action: context.l10n.weekPromptAction,
          onAction: () => unawaited(showWeekReview(context, today)),
          onNotNow: () => notNow(TodayPromptKind.week),
        ),
      );

  Widget _review(BuildContext context, void Function(TodayPromptKind) notNow) =>
      PromptCard(
        title: context.l10n.reviewTitle,
        child: DayReviewBody(
          day: today,
          onNotNow: () => notNow(TodayPromptKind.review),
        ),
      );
}
