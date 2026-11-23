import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/controls/dot_segmented.dart';
import 'package:dottoday/shared/dot/day_card_scroll.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/motion/reveal_highlight.dart';
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

/// The day card's Plan / Reality switch (11 C3, `B-ios-reality-thread`).
@immutable
final class RealityToggle {
  const RealityToggle({
    required this.on,
    required this.onChanged,
    this.highlight,
  });

  /// Showing the Reality thread.
  final bool on;
  final ValueChanged<bool> onChanged;

  /// The one-time reveal (docs/13 §4.3): what to announce and what to do
  /// once it has run; null when it already has, here.
  final ({String announcement, VoidCallback onDone})? highlight;
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
    this.reality,
    this.note,
    this.openAtNow = false,
    super.key,
  }) : hours = null;

  /// Today's day on the page itself (E-Phones, M19.1): no raised sheet and
  /// no handle (the strip and the title open the month), no title row
  /// (the screen's header carries the day and its numbers); the Plan /
  /// Reality switch, when shown, over the thread.
  const DayCard.page({
    required this.entries,
    this.actions = const ThreadActions(),
    this.footer,
    this.reality,
    this.note,
    this.openAtNow = false,
    this.hours,
    super.key,
  }) : title = '',
       isToday = false,
       summary = null;

  /// "Wednesday", or "Monday 14 Dec" away from this week.
  final String title;
  final bool isToday;

  /// The header's numbers; null on [DayCard.page].
  final DaySummary? summary;
  final List<ThreadEntry> entries;
  final ThreadActions actions;

  /// Below the thread, e.g. the empty-day actions of `A-ios-future-month`.
  final Widget? footer;

  /// The Plan / Reality switch in the header; null hides it. While the
  /// Reality thread shows, the header drops its numbers (as rendered).
  final RealityToggle? reality;

  /// One line at the top of the thread, under the header (the learning
  /// caption, "nothing started yet today"; docs/13 §4.2).
  final Widget? note;

  /// Today's card: open scrolled to the live task or the now marker,
  /// clear of the floating controls (ED-336); other days open at the top.
  final bool openAtNow;

  /// The Day view's hour scale on [DayCard.page] (M19.2 part 2).
  final ThreadHours? hours;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final numbers = summary;
    if (numbers == null) return _page(context);
    final header = _Header(
      title: title,
      isToday: isToday,
      summary: numbers,
      reality: reality,
    );
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
        child: LayoutBuilder(builder: (c, box) => _body(c, box, header)),
      ),
    );
  }

  /// [DayCard.page]: the Plan / Reality switch, when shown, pinned over
  /// the scrolling thread, straight on the page.
  Widget _page(BuildContext context) {
    final top = [
      if (reality case final r?)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: DotSpace.l),
          // At the start, under the date (E-R2-23 §4).
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: _RealitySwitch(toggle: r),
          ),
        ),
    ];
    return LayoutBuilder(
      builder: (context, box) => _pageBody(context, box, top),
    );
  }

  /// The page's pinned [top] over its thread. Squeezed below [_shortCard]
  /// (a keyboard and a prompt over a small phone), [top] scrolls with the
  /// thread instead of overflowing, as the card's header does (M4.9).
  Widget _pageBody(BuildContext context, BoxConstraints box, List<Widget> top) {
    List<Widget> thread(GlobalKey? key) => [
      _thread(key),
      // The last row scrolls clear of the floating tab bar and + button
      // (their height is in the bottom padding).
      SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.paddingOf(context).bottom + DotSpace.l,
        ),
      ),
    ];
    // The thread keeps clear of the sheet's edge (`Main`'s inset).
    Widget inset(Widget child) => Padding(
      padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
      child: child,
    );
    if (box.maxHeight < _shortCard) {
      return _scroll(
        context,
        (key) => [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: top,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
            sliver: SliverMainAxisGroup(slivers: thread(key)),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...top,
        // Lazy: only the rows on screen are built (R-15). The list's
        // rectangular clip sits below the rounded corners.
        Expanded(child: inset(_scroll(context, thread))),
      ],
    );
  }

  /// Header over the scrolling thread; in a very short card (a small phone
  /// with a prompt above it) the header scrolls with it instead of
  /// overflowing (M4.9).
  Widget _body(BuildContext context, BoxConstraints box, Widget header) {
    if (box.maxHeight < _shortCard) {
      return _scroll(
        context,
        (key) => [SliverToBoxAdapter(child: header), _thread(key)],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        // Lazy: only the rows on screen are built (R-15).
        Expanded(child: _scroll(context, (key) => [_thread(key)])),
      ],
    );
  }

  /// The card's scroll view, opened at now when [openAtNow] (ED-336).
  Widget _scroll(BuildContext context, List<Widget> Function(GlobalKey?) of) {
    final anchor = openAtNow ? _anchor : null;
    return DayCardScroll(
      anchor: anchor?.fraction,
      clearance: MediaQuery.paddingOf(context).bottom,
      slivers: of,
    );
  }

  ThreadAnchor? get _anchor => nowAnchor(entries);

  /// The day's thread (and footer), with the card's insets; the now row
  /// carries [anchorKey] while the card opens at it.
  Widget _thread(GlobalKey? anchorKey) => SliverPadding(
    // Concept E's 20 gutter (E rules §5.2: thread centre at 44); the now
    // card reaches 10 past it on each side.
    padding: const EdgeInsetsDirectional.fromSTEB(
      DotSpace.page,
      DotSpace.xs,
      DotSpace.page,
      0,
    ),
    sliver: SliverMainAxisGroup(
      slivers: [
        // The note scrolls with the thread: pinned, it would grow the
        // header past a short card at the largest text (docs/13 §4.2).
        if (note case final n?) SliverToBoxAdapter(child: n),
        Thread.sliver(
          entries: entries,
          actions: actions,
          anchorIndex: openAtNow ? _anchor?.index : null,
          anchorKey: anchorKey,
          hours: hours,
        ),
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
    this.reality,
  });

  final String title;
  final bool isToday;
  final DaySummary summary;
  final RealityToggle? reality;

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
            if (reality?.on != true) Text(numbers, style: t.styles.rowMeta),
            if (reality case final r?) _RealitySwitch(toggle: r),
          ],
        ),
      ),
    );
  }
}

/// "Plan | Reality" (`B-ios-reality-thread`).
class _RealitySwitch extends StatelessWidget {
  const _RealitySwitch({required this.toggle});

  final RealityToggle toggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final button = DotSegmented<bool>(
      segments: [(false, l10n.realityPlan), (true, l10n.realityReality)],
      selected: toggle.on,
      onChanged: toggle.onChanged,
    );
    final h = toggle.highlight;
    return h == null
        ? button
        : RevealHighlight(
            active: true,
            announcement: h.announcement,
            onDone: h.onDone,
            child: button,
          );
  }
}
