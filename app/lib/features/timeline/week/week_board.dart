import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/week_summary.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/shared/dot/capacity_ring.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The Week board's columns (`A-mac-week-alt3-board`): a header per day
/// (weekday, date, free time, `CapacityRing`, Busiest / Lightest), then
/// the hour axis and the seven [columns], scrolling together under it.
class WeekBoard extends StatelessWidget {
  const WeekBoard({
    required this.loads,
    required this.summary,
    required this.today,
    required this.hourLabels,
    required this.axisMinutes,
    required this.columns,
    super.key,
  });

  final List<DayLoad> loads;
  final WeekSummary summary;
  final DateTime today;

  /// "7 AM", "10 AM" … every three hours down the axis.
  final List<String> hourLabels;
  final int axisMinutes;
  final List<Widget> columns;

  static const double _gutter = 56;

  /// Below this the board scrolls sideways rather than squeeze its days.
  static const double _minWidth = 840;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final board = _board(context);
      if (box.maxWidth >= _minWidth) return board;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: _minWidth, child: board),
      );
    },
  );

  Widget _board(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const SizedBox(width: _gutter),
          for (final d in loads)
            Expanded(
              child: _DayHeader(
                load: d,
                isToday: d.date == today,
                tag: identical(d, summary.busiest)
                    ? context.l10n.weekBusiestTag
                    : identical(d, summary.lightest)
                    ? context.l10n.weekLightestTag
                    : null,
              ),
            ),
        ],
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: DotSpace.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _gutter,
                child: _HourLabels(labels: hourLabels, minutes: axisMinutes),
              ),
              for (final c in columns) Expanded(child: c),
            ],
          ),
        ),
      ),
    ],
  );
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.load, required this.isToday, this.tag});

  final DayLoad load;
  final bool isToday;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final c = t.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final day = DateFormat.E(locale).format(load.date);
    final ink = isToday ? c.accentInk : null;
    String length(int m) => formatDurationShort(l10n, m);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.xs,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? l10n.weekTodayDay(day) : day,
                        style: t.styles.rowMeta.copyWith(color: ink),
                      ),
                      Text(
                        DateFormat.d(locale).format(load.date),
                        style: t.styles.cardTitle.copyWith(color: ink),
                      ),
                    ],
                  ),
                ),
              ),
              CapacityRing(
                share: load.share,
                plannedMinutes: load.plannedMinutes,
                label: l10n.capacityRingLabel(
                  length(load.plannedMinutes),
                  length(load.awakeMinutes),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: DotSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.weekDayFree(length(load.freeMinutes)),
                style: t.styles.rowMeta,
              ),
              if (tag case final text?) WeekTag(text: text, accent: isToday),
            ],
          ),
        ],
      ),
    );
  }
}

/// "7 AM", "10 AM" … beside the axis, every three hours.
class _HourLabels extends StatelessWidget {
  const _HourLabels({required this.labels, required this.minutes});

  final List<String> labels;
  final int minutes;

  static const _every = 180;

  @override
  Widget build(BuildContext context) {
    final style = DotTheme.of(context).styles.rowMeta;
    return SizedBox(
      height: minutes * WeekScale.pxPerMinute,
      child: Stack(
        children: [
          for (final (i, label) in labels.indexed)
            Positioned(
              top: i * _every * WeekScale.pxPerMinute,
              right: DotSpace.s,
              child: ExcludeSemantics(child: Text(label, style: style)),
            ),
        ],
      ),
    );
  }
}
