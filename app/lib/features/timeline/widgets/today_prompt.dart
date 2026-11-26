import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/calendar/calendar_moves.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/domain/scheduling/calendar_move_prompt.dart';
import 'package:dottoday/domain/scheduling/day_review.dart';
import 'package:dottoday/domain/scheduling/running_late.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/first_today/first_sync_card.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/review/review_presenter.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/features/timeline/state/day_ends.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
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

/// Above today's thread (docs/09 M3f.5): before Wind Down, with the "Plan
/// your inbox" nudge on, that card (F3.3, [InboxNudgeCard]) and the Siri
/// tip, when nothing more pressing floats at the foot ([TodayFloatPrompt]:
/// "Need more time?", "Calendar changed", the Day review, This week).
/// Nothing on other days. A task over [rebalanceOverrunMin] past its end
/// opens Rebalance from "Need more time?".
///
/// Minimal layout (docs/14 §3): no "Need more time?", This week, Inbox or
/// Siri card; in their place, at most one reveal hint a day ([hint]). The
/// full layout draws [hint] under them: Wake Up's discovery (docs/15 §11).
class TodayPrompt extends ConsumerWidget {
  const TodayPrompt({
    required this.date,
    required this.today,
    this.hint,
    super.key,
  });

  final DateTime date;
  final DateTime today;

  /// The reveal hint row (minimal mode's, Wake Up's discovery), drawn when
  /// nothing more pressing is due.
  final Widget? hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (date != today) return const SizedBox.shrink();
    final at = _promptState(ref, today);
    if (at == null) return const SizedBox.shrink();
    final (:data, :dismissed, :now, :shape) = at;
    // After Wind Down the Day review or This week floats at the foot
    // ([TodayFloatPrompt], E-R2-27).
    if (!now.isBefore(shape.bedUtc)) return const SizedBox.shrink();
    // A pressing one floats at Today's foot instead ([TodayFloatPrompt]).
    if (_pressing(context, ref, today, at) != null) {
      return const SizedBox.shrink();
    }
    // Nothing more pressing: the once-a-day inbox card (F3.3), and the
    // once-ever Siri tip on iPhone (M14.3; each hides itself).
    if (!watchOnScreen(ref, FeatureId.inboxNudge)) {
      return hint ?? const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InboxNudgeCard(
          enabled: data.settings.inboxNudge,
          today: today,
          shape: shape,
          now: now,
        ),
        if (watchOnScreen(ref, FeatureId.siri)) const SiriTipCard(),
        ?hint,
      ],
    );
  }
}

/// The card floating at the foot of Today, above the tab bar, until
/// answered: before Wind Down "Need more time?" or "Calendar changed …
/// Rebalance?" (E-R2-26 §1, ED-329; owner, M20.6 part 2), after it the Day
/// review or This week (E-R2-27 §1; part 3). Nothing on other days, while
/// tasks are picked, or in low-energy mode.
class TodayFloatPrompt extends ConsumerWidget {
  const TodayFloatPrompt({required this.today, super.key});

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The selection bar has the foot while tasks are picked.
    if (!ref.watch(taskSelectionProvider.select((p) => p.isEmpty))) {
      return const SizedBox.shrink();
    }
    final at = _promptState(ref, today);
    final sync = _firstSync(ref);
    if (at == null) return sync;
    if (!at.now.isBefore(at.shape.bedUtc)) return _night(context, ref, at);
    return _pressing(context, ref, today, at) ?? sync;
  }

  /// The first Today's "Sign in to sync", when nothing more pressing is
  /// at the foot (M20.11 part 5, ED-490): a device with no account, until
  /// dismissed; not in Minimal.
  Widget _firstSync(WidgetRef ref) {
    final offer =
        watchOnScreen(ref, FeatureId.firstToday) &&
        (ref.watch(firstTodayProvider).value?.sync ?? false) &&
        ref.watch(syncStatusProvider).value?.state == SyncState.localOnly;
    return offer ? const FirstSyncCard() : const SizedBox.shrink();
  }
}

/// What both prompts read about today; null while it loads or in
/// low-energy mode (every nudge is off until Wake Up, 11 D2, M12.2).
typedef _PromptState = ({
  TimelineData data,
  Set<(TodayPromptKind, DateTime)> dismissed,
  DateTime now,
  DayShape shape,
});

_PromptState? _promptState(WidgetRef ref, DateTime today) {
  if (watchLowEnergy(ref)) return null;
  final data = ref.watch(timelineDataProvider(today)).value;
  if (data == null) return null;
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
  // The effective Wind Down opens the review (docs/15 W4).
  final shape =
      ref.watch(dayEndsProvider(today)).value?.shape ??
      DayShape.on(
        data.day.location,
        today,
        data.settings.boundaryFor(data.day.weekday),
      );
  return (
    data: data,
    dismissed: ref.watch(dismissedPromptsProvider),
    now: now,
    shape: shape,
  );
}

/// Before Wind Down: an event the calendar moved into the plan
/// ([CalendarMovedPrompt], M11.1b), else "Need more time?" once a task
/// ended unticked, with the "Running-late nudge" on; null when neither.
Widget? _pressing(
  BuildContext context,
  WidgetRef ref,
  DateTime today,
  _PromptState at,
) {
  final (:data, :dismissed, :now, shape: _) = at;
  final move = moveToRebalance(
    ref.watch(calendarMovesProvider).values,
    data.blocks,
    now,
  );
  if (move != null) return CalendarMovedPrompt(move: move, data: data);
  final missed = watchOnScreen(ref, FeatureId.needMoreTimeNudge)
      ? missedTask(data.blocks, now)
      : null;
  if (!data.settings.runningLateNudge ||
      missed == null ||
      dismissed.contains((TodayPromptKind.late, today))) {
    return null;
  }
  return PromptCard(
    title: context.l10n.lateNudgeTitle,
    floating: true,
    child: PromptNudge(
      detail: context.l10n.lateNudgeDetail(
        missed.title,
        now.difference(missed.endUtc!).inMinutes,
      ),
      action: context.l10n.lateNudgeAction,
      onAction: () => unawaited(_late(context, today, missed, now)),
      onNotNow: () => ref
          .read(dismissedPromptsProvider.notifier)
          .dismiss(TodayPromptKind.late, today),
    ),
  );
}

/// The nudge's action: a task more than [rebalanceOverrunMin] past its end
/// opens Rebalance straight away (11 C1, M11.1) with the overrun rounded
/// up to 5 min; a fresher one the Running late sheet.
Future<void> _late(
  BuildContext context,
  DateTime today,
  Occurrence missed,
  DateTime now,
) {
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

/// After Wind Down (E-R2-27 §1, owner M20.6 part 3): the Day review while
/// the day had tasks (a fully-done day too: the night line and the sleep
/// offer live there, owner 2026-10-31), else on the week's last day "This
/// week" (M12.1); "Not now" puts each away for the day.
Widget _night(BuildContext context, WidgetRef ref, _PromptState at) {
  final (:data, :dismissed, now: _, shape: _) = at;
  final today = data.day.date;
  void notNow(TodayPromptKind kind) =>
      ref.read(dismissedPromptsProvider.notifier).dismiss(kind, today);
  if (!dismissed.contains((TodayPromptKind.review, today)) &&
      reviewOf(data.blocks).total > 0) {
    return PromptCard(
      title: context.l10n.reviewTitle,
      floating: true,
      // The card opens the whole review where this layout keeps it.
      onTap: () => unawaited(openReview(context, day: today)),
      child: DayReviewBody(
        day: today,
        onNotNow: () => notNow(TodayPromptKind.review),
      ),
    );
  }
  final weekEnds =
      reviewWeek(today, data.settings.firstDayOfWeek).last == today &&
      watchOnScreen(ref, FeatureId.weekPrompt);
  if (!weekEnds || dismissed.contains((TodayPromptKind.week, today))) {
    return const SizedBox.shrink();
  }
  // Sunday at Wind Down (the week's last day): the weekly review (11 D1).
  return PromptCard(
    title: context.l10n.weekReviewTitle,
    floating: true,
    child: PromptNudge(
      detail: context.l10n.weekPromptDetail,
      action: context.l10n.weekPromptAction,
      onAction: () =>
          unawaited(openReview(context, day: today, page: ReviewPage.week)),
      onNotNow: () => notNow(TodayPromptKind.week),
    ),
  );
}
