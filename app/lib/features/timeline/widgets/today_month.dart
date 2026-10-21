import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/state/month_cells.dart';
import 'package:dottoday/features/timeline/state/month_data.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The month pulled open from the week strip (T2 `A-ios-today-month`, T3
/// `A-ios-future-month`): month navigation, the grid with completion or
/// planned dots, and the footer. Picking a day pages Today to it.
class TodayMonth extends ConsumerWidget {
  const TodayMonth({
    required this.month,
    required this.shown,
    required this.today,
    required this.onSelect,
    required this.onMonth,
    super.key,
  });

  /// Year/month on screen.
  final DateTime month;
  final DateTime shown;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  /// The ‹ › buttons ask for another month.
  final ValueChanged<DateTime> onMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l10n = context.l10n;
    final first =
        ref.watch(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1;
    final byDay = ref.watch(monthOccurrencesProvider(month)).value ?? const {};
    final cells = compactMonthCells(
      month: month,
      firstDayOfWeek: first,
      today: today,
      byDay: byDay,
      dateText: (d) => DateFormat.d(locale).format(d),
      label: (d, c) {
        final name = DateFormat.MMMMEEEEd(locale).format(d);
        return c.total == 0 ? name : l10n.monthCellLabel(name, c.done, c.total);
      },
    );
    final lead = cells.indexWhere((c) => c != null);
    final start = weekStart(DateTime(month.year, month.month), first);
    final shownHere = shown.year == month.year && shown.month == month.month;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MonthNav(month: month, onMonth: onMonth),
          MonthGrid(
            weekdays: [
              for (var i = 0; i < 7; i++)
                DateFormat.E(
                  locale,
                ).format(DateTime(start.year, start.month, start.day + i)),
            ],
            days: cells,
            selected: shownHere ? lead + shown.day - 1 : null,
            onSelect: (i) =>
                onSelect(DateTime(month.year, month.month, i - lead + 1)),
          ),
          _Footer(
            month: month,
            today: today,
            showsToday: shown == today,
            planned: plannedDays(byDay, month),
            onToday: () => onSelect(today),
          ),
        ],
      ),
    );
  }
}

/// "‹  Nov · Dec · Jan  ›".
class _MonthNav extends StatelessWidget {
  const _MonthNav({required this.month, required this.onMonth});

  final DateTime month;
  final ValueChanged<DateTime> onMonth;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String name(int delta) => DateFormat.MMM(
      locale,
    ).format(DateTime(month.year, month.month + delta));
    return Row(
      children: [
        _NavButton(
          glyph: DotGlyphs.chevronLeft,
          label: l10n.monthPrevious,
          onTap: () => onMonth(DateTime(month.year, month.month - 1)),
        ),
        Expanded(
          child: Text(
            l10n.monthNav(name(-1), name(0), name(1)),
            textAlign: TextAlign.center,
            style: t.styles.rowTitle.copyWith(color: t.colors.muted),
          ),
        ),
        _NavButton(
          glyph: DotGlyphs.chevronRight,
          label: l10n.monthNext,
          onTap: () => onMonth(DateTime(month.year, month.month + 1)),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.glyph,
    required this.label,
    required this.onTap,
  });

  final DotGlyph glyph;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return IconButton(
      onPressed: onTap,
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: c.raised,
        side: BorderSide(color: c.outline, width: DotSpace.hairline),
        minimumSize: const Size.square(DotTouch.android),
      ),
      icon: DotIcon(glyph, color: c.text, size: DotSize.rowIcon),
    );
  }
}

/// This month: "October · 14 of 31 days planned" and a Today link.
/// Another month: the planned / repeats legend and "10 days planned".
class _Footer extends StatelessWidget {
  const _Footer({
    required this.month,
    required this.today,
    required this.showsToday,
    required this.planned,
    required this.onToday,
  });

  final DateTime month;
  final DateTime today;
  final bool showsToday;
  final int planned;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final current = month.year == today.year && month.month == today.month;
    final meta = t.styles.rowTitle.copyWith(color: t.colors.muted);
    final days = DateTime(month.year, month.month + 1, 0).day;
    return Row(
      children: [
        if (!current) ...[
          _Legend(filled: true, label: l10n.monthLegendPlanned),
          const SizedBox(width: DotSpace.m),
          _Legend(filled: false, label: l10n.monthLegendRepeats),
        ],
        Expanded(
          child: Text(
            current
                ? l10n.monthFooterPlanned(
                    DateFormat.MMMM(locale).format(month),
                    planned,
                    days,
                  )
                : l10n.monthDaysPlanned(planned),
            textAlign: current ? TextAlign.start : TextAlign.end,
            style: meta,
          ),
        ),
        if (current && !showsToday)
          TextButton(
            onPressed: onToday,
            child: Text(
              l10n.todayPill,
              style: t.styles.rowTitle.copyWith(color: t.colors.accentInk),
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.filled, required this.label});

  final bool filled;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.xs,
      children: [
        Container(
          width: DotSize.weekDot,
          height: DotSize.weekDot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? t.colors.accent : null,
            border: filled
                ? null
                : Border.all(
                    color: t.colors.hairline,
                    width: DotSpace.hairline * 1.5,
                  ),
          ),
        ),
        Text(label, style: t.styles.rowTitle.copyWith(color: t.colors.muted)),
      ],
    );
  }
}
