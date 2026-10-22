import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/day_review.dart';
import 'package:dottoday/domain/scheduling/running_late.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_prompts.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Above today's thread (docs/09 M3f.5): from Bedtime, the Day review
/// while one-off tasks are unfinished; before it, with "Running-late
/// nudge" on, "Running late?" once a task ended unticked. "Not now" puts
/// it away for the day (this session). Nothing on other days.
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
      return const SizedBox.shrink();
    }
    return _PromptCard(
      title: context.l10n.lateNudgeTitle,
      child: _Nudge(
        detail: context.l10n.lateNudgeDetail(
          missed.title,
          now.difference(missed.endUtc!).inMinutes,
        ),
        onCatchUp: () => unawaited(showRunningLateSheet(context, today)),
        onNotNow: () => notNow(TodayPromptKind.late),
      ),
    );
  }
}

extension on TodayPrompt {
  Widget _review(BuildContext context, void Function(TodayPromptKind) notNow) =>
      _PromptCard(
        title: context.l10n.reviewTitle,
        child: DayReviewBody(
          day: today,
          onNotNow: () => notNow(TodayPromptKind.review),
        ),
      );
}

class _Nudge extends StatelessWidget {
  const _Nudge({
    required this.detail,
    required this.onCatchUp,
    required this.onNotNow,
  });

  final String detail;
  final VoidCallback onCatchUp;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        Text(detail, style: DotTheme.of(context).styles.body),
        Wrap(
          spacing: DotSpace.s,
          children: [
            FilledButton(
              onPressed: onCatchUp,
              child: Text(l10n.lateNudgeAction),
            ),
            TextButton(onPressed: onNotNow, child: Text(l10n.promptNotNow)),
          ],
        ),
      ],
    );
  }
}

/// A raised card with a caption, between the header and the day card.
class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.page,
        vertical: DotSpace.xs,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.raised,
          borderRadius: BorderRadius.circular(DotRadii.card),
          border: Border.all(color: t.colors.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.l),
          child: Semantics(
            container: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DotSpace.xs,
              children: [
                Semantics(
                  header: true,
                  child: Text(title.toUpperCase(), style: t.styles.caption),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
