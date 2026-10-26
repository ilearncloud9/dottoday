import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// How many of a day's tasks its thread lists before "+4 more".
const weekThreadRows = 3;

/// The tapped day's thread (`B-ios-week-review` popover): its first
/// [weekThreadRows] tasks with their times — done ones ticked and struck —
/// then its planned time and "+N more".
class WeekDayThread extends StatelessWidget {
  const WeekDayThread({
    required this.day,
    required this.busiest,
    required this.time,
    super.key,
  });

  final WeekReviewDay day;
  final bool busiest;

  /// "7:30 – 8:00" for a task's planned span.
  final String Function(DateTime startUtc, DateTime endUtc) time;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final dots = day.snapshot.dots;
    final planned = formatDurationShort(l10n, day.plannedMinutes);
    final more = dots.length - weekThreadRows;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.card),
        border: Border.all(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.s,
          children: [
            if (dots.isEmpty) Text(l10n.spreadNothing, style: t.styles.rowMeta),
            for (final d in dots.take(weekThreadRows))
              Row(
                spacing: DotSpace.s,
                children: [
                  TaskDot(
                    color: TaskColor.fromKey(d.colorKey),
                    icon: TaskIcon.fromKey(d.iconKey),
                    state: d.done ? DotState.done : DotState.upcoming,
                    label: taskDotLabel(
                      l10n,
                      title: d.title,
                      state: d.done ? DotState.done : DotState.upcoming,
                    ),
                    size: DotSize.pickerDot,
                  ),
                  Expanded(
                    child: Text(
                      d.title,
                      style: t.styles.body.copyWith(
                        color: d.done ? t.colors.muted : null,
                        decoration: d.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Text(time(d.startUtc, d.endUtc), style: t.styles.rowMeta),
                ],
              ),
            if (dots.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      busiest
                          ? l10n.weekReviewPlannedBusiest(planned)
                          : l10n.weekReviewPlanned(planned),
                      style: t.styles.rowMeta.copyWith(color: t.colors.text),
                    ),
                  ),
                  if (more > 0)
                    Text(l10n.monthMore(more), style: t.styles.rowMeta),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// "● 29 of 34 done", "Busiest · Thu", "Lightest · Sat": text chips that
/// wrap at large text.
class WeekReviewChips extends StatelessWidget {
  const WeekReviewChips({required this.review, super.key});

  final WeekReview review;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String day(WeekReviewDay d) => DateFormat.E(locale).format(d.date);
    Widget chip(String text, {bool dot = false}) => DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DotRadii.pill),
        border: Border.all(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.s,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.s,
          children: [
            if (dot)
              const SizedBox.square(
                dimension: DotSize.tabDot,
                child: _AccentDot(),
              ),
            Flexible(child: Text(text, style: t.styles.body)),
          ],
        ),
      ),
    );
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        chip(l10n.reviewSummary(review.done, review.total), dot: true),
        if (review.busiest case final b?) chip(l10n.weekReviewBusiest(day(b))),
        if (review.lightest case final l?)
          chip(l10n.weekReviewLightest(day(l))),
      ],
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: DotTheme.of(context).colors.accent,
      shape: BoxShape.circle,
    ),
  );
}

/// The one rule-written sentence (11 D1): how the week's real starts went
/// against the plan, then which day carried the most and which breathed.
/// Only this week; never a comparison with another one (owner, M12.1).
String weekSentence(BuildContext context, WeekReview review) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  String day(WeekReviewDay d) => DateFormat.EEEE(locale).format(d.date);
  final pace = switch (review.pace) {
    WeekPace.morningsToPlan => l10n.weekPaceMornings,
    WeekPace.afternoonsToPlan => l10n.weekPaceAfternoons,
    WeekPace.allDone => l10n.weekPaceAllDone,
    WeekPace.quiet => l10n.weekPaceQuiet,
    WeekPace.none => null,
  };
  final load = switch ((review.busiest, review.lightest)) {
    (final b?, final l?) => l10n.weekLoadBoth(day(b), day(l)),
    (final b?, null) => l10n.weekLoadBusiest(day(b)),
    _ => null,
  };
  return [?pace, ?load].join(' '); // l10n-ignore: joins two sentences
}

/// "○ 3 unfinished · move them to next week?  Place  Leave in Inbox".
class WeekCarryCard extends StatelessWidget {
  const WeekCarryCard({
    required this.count,
    required this.onPlace,
    required this.onInbox,
    super.key,
  });

  final int count;
  final VoidCallback onPlace;
  final VoidCallback onInbox;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DotRadii.card),
        border: Border.all(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.m),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: DotSpace.s,
          runSpacing: DotSpace.s,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DotSpace.s,
              children: [
                SizedBox.square(
                  dimension: DotSize.rowIcon,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: t.colors.muted,
                        width: DotSize.smallDotOutline,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: DotSize.wideRowFrom - DotSpace.xxl,
                  ),
                  child: Text(l10n.weekCarryAsk(count), style: t.styles.body),
                ),
              ],
            ),
            FilledButton(onPressed: onPlace, child: Text(l10n.weekCarryPlace)),
            TextButton(onPressed: onInbox, child: Text(l10n.weekCarryInbox)),
          ],
        ),
      ),
    );
  }
}
