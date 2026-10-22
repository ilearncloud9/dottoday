import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_card_side.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

export 'day_card_side.dart' show SideDay;

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
  }) : side = null;

  /// A side day of the Mac/web spread (`A-mac-today-alt1-spread`): no
  /// raised card, a muted "Tuesday · Yesterday" header with "● 7 of 7" or
  /// "○ 4 planned", and the [Thread]'s side rows.
  const DayCard.side({
    required this.title,
    required this.summary,
    required this.entries,
    required SideDay this.side,
    this.actions = const ThreadActions(),
    this.footer,
    super.key,
  }) : isToday = false;

  /// "Wednesday", or "Monday 14 Dec" away from this week.
  final String title;
  final bool isToday;
  final DaySummary summary;
  final List<ThreadEntry> entries;
  final ThreadActions actions;

  /// Below the thread, e.g. the empty-day actions of `A-ios-future-month`.
  final Widget? footer;

  /// Set on [DayCard.side].
  final SideDay? side;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    if (side case final day?) {
      return SideDayColumn(
        title: title,
        side: day,
        summary: summary,
        entries: entries,
        actions: actions,
        footer: footer,
      );
    }
    final header = _Header(title: title, isToday: isToday, summary: summary);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: c.outline, width: DotSpace.hairline),
      ),
      // No rounded clip: an anti-aliased clip over a scrolling list costs
      // the raster thread every frame (R-15). The list's own rectangular
      // clip stops a radius short of the bottom, so rows never reach the
      // rounded corners; the header covers the top ones.
      child: Padding(
        padding: const EdgeInsets.only(bottom: DotRadii.cardLarge),
        child: LayoutBuilder(builder: (_, box) => _body(box, header)),
      ),
    );
  }

  /// Header over the scrolling thread; in a very short card (a small phone
  /// with a prompt above it) the header scrolls with it instead of
  /// overflowing (M4.9).
  Widget _body(BoxConstraints box, Widget header) {
    if (box.maxHeight < _shortCard) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: header),
          _thread(),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        // Lazy: only the rows on screen are built (R-15).
        Expanded(child: CustomScrollView(slivers: [_thread()])),
      ],
    );
  }

  /// The day's thread (and footer), with the card's insets.
  Widget _thread() => SliverPadding(
    padding: const EdgeInsetsDirectional.fromSTEB(
      0,
      DotSpace.xs,
      DotSpace.xs,
      0,
    ),
    sliver: SliverMainAxisGroup(
      slivers: [
        Thread.sliver(entries: entries, actions: actions),
        if (footer case final f?) SliverToBoxAdapter(child: f),
      ],
    ),
  );
}

/// Below this height the header scrolls with the thread.
const _shortCard = 160.0;

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
