import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// How many of a day's tasks its thread lists before "+4 more".
const weekThreadRows = 3;

/// The tapped day's tasks (E-R2-24 §1, ED-496), under a hairline in the
/// week card: its first [weekThreadRows] tasks — a dot in the task's colour
/// (filled once done, a ring while open), the title (struck once done) and
/// the time — then its planned time and "+N more".
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
    final c = t.colors;
    final l10n = context.l10n;
    final dots = day.snapshot.dots;
    final planned = formatDurationShort(l10n, day.plannedMinutes);
    final more = dots.length - weekThreadRows;
    final foot = WeekType.foot(t.styles, c);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.outline, width: 0.5)),
      ),
      child: Padding(
        padding: WeekSize.threadPad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dots.isEmpty) Text(l10n.spreadNothing, style: foot),
            for (final d in dots.take(weekThreadRows))
              Semantics(
                container: true,
                label: taskDotLabel(
                  l10n,
                  title: d.title,
                  state: d.done ? DotState.done : DotState.upcoming,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: WeekSize.threadRow,
                  ),
                  child: Row(
                    spacing: WeekSize.threadGap,
                    children: [
                      _Dot(
                        color: t.tasks[TaskColor.fromKey(d.colorKey)].color,
                        done: d.done,
                      ),
                      Expanded(
                        child: ExcludeSemantics(
                          child: Text(
                            d.title,
                            style: WeekType.task(t.styles, c, done: d.done),
                          ),
                        ),
                      ),
                      Text(
                        time(d.startUtc, d.endUtc),
                        style: WeekType.time(t.styles, c),
                      ),
                    ],
                  ),
                ),
              ),
            if (dots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: WeekSize.threadFoot),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        busiest
                            ? l10n.weekReviewPlannedBusiest(planned)
                            : l10n.weekReviewPlanned(planned),
                        style: foot,
                      ),
                    ),
                    if (more > 0) Text(l10n.monthMore(more), style: foot),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A task in the open day: filled once done, a ring while open; the row's
/// words say which.
class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.done});

  final Color color;
  final bool done;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: WeekSize.threadDot,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? color : null,
        border: done
            ? null
            : Border.all(color: color, width: WeekSize.threadDotRing),
      ),
    ),
  );
}

/// "29 of 39 done", "Busiest · Tuesday", "Lightest · Sunday": filled chips
/// with the day's full name (owner, ED-496), wrapping at large text.
class WeekReviewChips extends StatelessWidget {
  const WeekReviewChips({required this.review, super.key});

  final WeekReview review;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String day(WeekReviewDay d) => DateFormat.EEEE(locale).format(d.date);
    Widget chip(String text) => ConstrainedBox(
      constraints: const BoxConstraints(minHeight: WeekSize.chip),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WeekColors.chip(c),
          borderRadius: BorderRadius.circular(WeekSize.chip / 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: WeekSize.chipPad),
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(text, style: WeekType.chip(t.styles, c)),
          ),
        ),
      ),
    );
    return Wrap(
      spacing: WeekSize.chipGap,
      runSpacing: WeekSize.chipGap,
      children: [
        chip(l10n.reviewSummary(review.done, review.total)),
        if (review.busiest case final b?) chip(l10n.weekReviewBusiest(day(b))),
        if (review.lightest case final l?)
          chip(l10n.weekReviewLightest(day(l))),
      ],
    );
  }
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

/// "3 unfinished · move them to next week?" with Place and Leave in Inbox
/// (E-R2-24 §1, ED-496).
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
    final c = t.colors;
    final l10n = context.l10n;
    final label = WeekType.carryButton(t.styles);
    ButtonStyle pill(double pad) => ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(WeekSize.carryButton, WeekSize.carryButton),
      ),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: pad)),
      textStyle: WidgetStatePropertyAll(label),
      tapTargetSize: MaterialTapTargetSize.padded,
      shape: const WidgetStatePropertyAll(StadiumBorder()),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(WeekSize.carryRadius),
        border: Border.all(color: c.outline),
      ),
      child: Padding(
        padding: WeekSize.carryPad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: WeekSize.carryActionsTop,
          children: [
            Text(l10n.weekCarryAsk(count), style: WeekType.carry(t.styles, c)),
            Wrap(
              spacing: WeekSize.carryButtonGap,
              runSpacing: WeekSize.carryButtonGap,
              children: [
                FilledButton(
                  style: pill(WeekSize.carryPlacePad),
                  onPressed: onPlace,
                  child: Text(l10n.weekCarryPlace),
                ),
                TextButton(
                  style: pill(WeekSize.carryInboxPad).copyWith(
                    foregroundColor: WidgetStatePropertyAll(c.accentInk),
                  ),
                  onPressed: onInbox,
                  child: Text(l10n.weekCarryInbox),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
