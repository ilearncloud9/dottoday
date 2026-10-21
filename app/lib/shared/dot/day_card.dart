import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// Header numbers of a [DayCard]: "2 of 7 · 5 h 45 planned", or "Nothing
/// planned · 15 h free" for an empty day (`A-ios-future-month`).
@immutable
final class DaySummary {
  const DaySummary({
    required this.done,
    required this.total,
    required this.plannedMinutes,
    required this.freeMinutes,
  });

  final int done;
  final int total;
  final int plannedMinutes;
  final int freeMinutes;
}

/// One day on a raised card (docs/10 §3 `DayCard`, `Main`): "Wednesday ·
/// Today" and its numbers, then the day's [Thread], which scrolls inside
/// the card so the header stays put.
class DayCard extends StatelessWidget {
  const DayCard({
    required this.title,
    required this.summary,
    required this.entries,
    this.isToday = false,
    this.actions = const ThreadActions(),
    this.footer,
    super.key,
  });

  /// "Wednesday", or "Monday 14 Dec" away from this week.
  final String title;
  final bool isToday;
  final DaySummary summary;
  final List<ThreadEntry> entries;
  final ThreadActions actions;

  /// Below the thread, e.g. the empty-day actions of `A-ios-future-month`.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: c.outline, width: DotSpace.hairline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(title: title, isToday: isToday, summary: summary),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  0,
                  DotSpace.xs,
                  DotSpace.xs,
                  DotSpace.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Thread(entries: entries, actions: actions),
                    ?footer,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.isToday,
    required this.summary,
  });

  final String title;
  final bool isToday;
  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final s = summary;
    final numbers = s.total == 0
        ? l10n.dayCardNothing(formatDurationShort(l10n, s.freeMinutes))
        : l10n.dayCardSummary(
            s.done,
            s.total,
            formatDurationShort(l10n, s.plannedMinutes),
          );
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.l,
          DotSpace.page,
          DotSpace.l,
          DotSpace.xs,
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: DotSpace.s,
          children: [
            Text.rich(
              TextSpan(
                text: title,
                children: [
                  if (isToday)
                    TextSpan(
                      text: l10n.dayCardTodaySuffix,
                      style: TextStyle(color: t.colors.accentInk),
                    ),
                ],
              ),
              style: t.styles.cardTitle,
            ),
            // Same size as the rows' time meta, as in `Main`.
            Text(numbers, style: t.styles.rowMeta),
          ],
        ),
      ),
    );
  }
}
