import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/month_cells.dart';
import 'package:dottoday/shared/dot/month_models.dart';
import 'package:flutter/material.dart';

export 'month_models.dart';

/// Which cell a [MonthGrid] draws (docs/10 §3 `MonthGrid`).
enum MonthCellStyle {
  /// Date + completion or planned dots: the Today pull-open and the
  /// future-month planner (`A-ios-today-month`, `A-ios-future-month`).
  compact,

  /// Cards with struck done titles, "missed", "N of M done" (`A-mac-month`).
  expanded,
}

/// A month as 7 × 5–6 cells (docs/10 §3 `MonthGrid`).
///
/// [days] is the grid in reading order with `null` for the blanks before
/// the 1st and after the last day, so the feature decides where the week
/// starts (Settings › Week starts).
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.weekdays,
    required this.days,
    this.style = MonthCellStyle.compact,
    this.selected,
    this.onSelect,
    super.key,
  }) : assert(weekdays.length == 7);

  /// Column headers in display order: "Sun" … "Sat" or "Mon" … "Sun".
  final List<String> weekdays;
  final List<MonthDay?> days;
  final MonthCellStyle style;

  /// Index into [days] of the day shown below (accent filled, compact).
  final int? selected;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final rows = (days.length / 7).ceil();
    final gap = style == MonthCellStyle.expanded ? DotSpace.s : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              for (final w in weekdays)
                Expanded(
                  child: Text(
                    w,
                    textAlign: style == MonthCellStyle.compact
                        ? TextAlign.center
                        : TextAlign.start,
                    style: t.styles.rowTitle.copyWith(color: t.colors.muted),
                  ),
                ),
            ],
          ),
        ),
        for (var r = 0; r < rows; r++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: [for (var c = 0; c < 7; c++) _cell(r * 7 + c)],
            ),
          ),
      ],
    );
  }

  Widget _cell(int i) {
    final day = i < days.length ? days[i] : null;
    if (day == null) return const Expanded(child: SizedBox.shrink());
    final onTap = onSelect == null ? null : () => onSelect!(i);
    return Expanded(
      child: switch (style) {
        MonthCellStyle.compact => CompactMonthCell(
          day: day,
          selected: i == selected,
          onTap: onTap,
        ),
        MonthCellStyle.expanded => ExpandedMonthCell(day: day, onTap: onTap),
      },
    );
  }
}
