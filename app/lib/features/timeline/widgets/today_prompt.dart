import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/scheduling/day_review.dart';
import 'package:dottoday/domain/scheduling/running_late.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_prompts.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:dottoday/features/timeline/widgets/inbox_nudge_card.dart';
import 'package:dottoday/features/timeline/widgets/prompt_card.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Above today's thread (docs/09 M3f.5): from Bedtime, the Day review
/// while one-off tasks are unfinished; before it, with "Running-late
/// nudge" on, "Running late?" once a task ended unticked; otherwise, with
/// the "Plan your inbox" nudge on, that card (F3.3, [InboxNudgeCard]).
/// "Not now" puts it away for the day (this session). Nothing on other
/// days.
class TodayPrompt extends ConsumerWidget {
  const TodayPrompt({required this.date, required this.today, super.key});

  final DateTime date;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (date != today) return const SizedBox.shrink();
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
      final show =
          !dismissed.contains((TodayPromptKind.review, today)) &&
          reviewOf(data.blocks).hasRest;
      return show ? _review(context, notNow) : const SizedBox.shrink();
    }
    final missed = missedTask(data.blocks, now);
    if (!data.settings.runningLateNudge ||
        missed == null ||
        dismissed.contains((TodayPromptKind.late, today))) {
      // Nothing more pressing: the once-a-day inbox card (F3.3).
      return InboxNudgeCard(
        enabled: data.settings.inboxNudge,
        today: today,
        shape: shape,
        now: now,
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
        onAction: () => unawaited(showRunningLateSheet(context, today)),
        onNotNow: () => notNow(TodayPromptKind.late),
      ),
    );
  }
}

extension on TodayPrompt {
  Widget _review(BuildContext context, void Function(TodayPromptKind) notNow) =>
      PromptCard(
        title: context.l10n.reviewTitle,
        child: DayReviewBody(
          day: today,
          onNotNow: () => notNow(TodayPromptKind.review),
        ),
      );
}
