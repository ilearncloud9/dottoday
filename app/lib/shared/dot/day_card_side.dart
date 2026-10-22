import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// [DayCard.side]: the header, then the side [Thread] scrolling under it.
class SideDayColumn extends StatelessWidget {
  const SideDayColumn({
    required this.title,
    required this.side,
    required this.summary,
    required this.entries,
    required this.actions,
    this.footer,
    super.key,
  });

  final String title;
  final SideDay side;
  final DaySummary summary;
  final List<ThreadEntry> entries;
  final ThreadActions actions;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SideHeader(title: title, side: side, summary: summary),
      Expanded(
        child: CustomScrollView(
          slivers: [
            Thread.sliver(
              entries: entries,
              actions: actions,
              side: true,
              dayLabel: title,
            ),
            if (footer case final f?) SliverToBoxAdapter(child: f),
          ],
        ),
      ),
    ],
  );
}

/// Which side of the spread a [DayCard.side] stands on.
@immutable
final class SideDay {
  const SideDay({required this.past, this.suffix = ''});

  /// Before the card's day: muted title, "● 7 of 7"; after it: "○ 4
  /// planned".
  final bool past;

  /// " · Yesterday" / " · Tomorrow" next to today, else empty.
  final String suffix;
}

class _SideHeader extends StatelessWidget {
  const _SideHeader({
    required this.title,
    required this.side,
    required this.summary,
  });

  final String title;
  final SideDay side;
  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.l,
          DotSpace.page,
          DotSpace.l,
          DotSpace.m,
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: DotSpace.s,
          children: [
            Text(
              '$title${side.suffix}', // l10n-ignore: two localised parts
              style: t.styles.rowTitle.copyWith(
                color: side.past ? t.colors.muted : null,
                fontWeight: side.past ? null : FontWeight.w600,
              ),
            ),
            _SideNumbers(side: side, summary: summary),
          ],
        ),
      ),
    );
  }
}

/// "● 7 of 7" (a past day) or "○ 4 planned".
class _SideNumbers extends StatelessWidget {
  const _SideNumbers({required this.side, required this.summary});

  final SideDay side;
  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final c = t.colors;
    final past = side.past;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.xs,
      children: [
        Container(
          width: DotSize.weekDot,
          height: DotSize.weekDot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: past ? c.accent : null,
            border: past ? null : Border.all(color: c.hairline),
          ),
        ),
        // A narrow window's side day wraps the words, never overflows.
        Flexible(
          child: Text(
            summary.total == 0
                ? l10n.spreadNothing
                : past
                ? l10n.spreadDoneOf(summary.done, summary.total)
                : l10n.spreadPlanned(summary.total),
            style: t.styles.rowMeta.copyWith(color: past ? c.accentInk : null),
          ),
        ),
      ],
    );
  }
}
