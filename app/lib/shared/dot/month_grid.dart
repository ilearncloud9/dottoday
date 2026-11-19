import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/month_cells.dart';
import 'package:dottoday/shared/dot/month_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'month_models.dart';

/// Which cell a [MonthGrid] draws (docs/10 §3 `MonthGrid`).
enum MonthCellStyle {
  /// Date + completion or planned dots: the Today pull-open and the
  /// future-month planner (`A-ios-today-month`, `A-ios-future-month`).
  compact,

  /// Cards with struck done titles, "N of M done" and Light day, with the
  /// days of the months either side faded (E-R2-30, ED-333).
  expanded,
}

/// A month as 7 × 5–6 cells (docs/10 §3 `MonthGrid`).
///
/// [days] is the grid in reading order with `null` for the blanks before
/// the 1st and after the last day, so the feature decides where the week
/// starts (Settings › Week starts).
class MonthGrid extends StatefulWidget {
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
  State<MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<MonthGrid> {
  /// The cards' focus, by index, for the arrow keys (M19.2 part 3b).
  final _nodes = <int, FocusNode>{};

  List<MonthDay?> get days => widget.days;
  MonthCellStyle get style => widget.style;

  @override
  void dispose() {
    for (final n in _nodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final weekdays = widget.weekdays;
    final rows = (days.length / 7).ceil();
    final expanded = style == MonthCellStyle.expanded;
    // E-R2-30: 6 between cards and under the weekday heads.
    final gap = expanded ? DotSpace.xs + DotSpace.xxs : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              for (final w in weekdays)
                Expanded(
                  child: expanded
                      // E-R2-30 sets the heads in capitals: "MON".
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DotSpace.s,
                          ),
                          child: Text(
                            w.toUpperCase(),
                            style: t.styles.monthWeekday,
                          ),
                        )
                      : Text(
                          w,
                          textAlign: TextAlign.center,
                          style: t.styles.stripWeekday,
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
    final onSelect = widget.onSelect;
    final onTap = onSelect == null || day.outside ? null : () => onSelect(i);
    return Expanded(
      child: switch (style) {
        MonthCellStyle.compact => CompactMonthCell(
          day: day,
          selected: i == widget.selected,
          onTap: onTap,
        ),
        MonthCellStyle.expanded => Focus(
          canRequestFocus: false,
          skipTraversal: true,
          includeSemantics: false,
          onKeyEvent: (_, event) => _arrow(i, event),
          child: ExpandedMonthCell(
            day: day,
            onTap: onTap,
            focusNode: _nodes.putIfAbsent(i, FocusNode.new),
          ),
        ),
      },
    );
  }

  /// Arrow keys between the cards (handoff "Week", owner M19.2 part 3b):
  /// ← → a day, ↑ ↓ a week, over the days of the months either side.
  KeyEventResult _arrow(int i, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final by = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => rtl ? 1 : -1,
      LogicalKeyboardKey.arrowRight => rtl ? -1 : 1,
      LogicalKeyboardKey.arrowUp => -7,
      LogicalKeyboardKey.arrowDown => 7,
      _ => 0,
    };
    final keys = HardwareKeyboard.instance;
    if (by == 0 || keys.isAltPressed || keys.isMetaPressed) {
      return KeyEventResult.ignored;
    }
    for (var j = i + by; j >= 0 && j < days.length; j += by) {
      final d = days[j];
      if (d == null || d.outside) continue;
      _nodes[j]?.requestFocus();
      break;
    }
    // At the month's edge the key stays here.
    return KeyEventResult.handled;
  }
}
