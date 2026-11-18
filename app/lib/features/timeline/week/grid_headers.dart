import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/week_summary.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A day's header (E-FullA-v2 Week): the weekday, the date and "4 done" /
/// "3 planned"; today tinted, "Tue · Today", its date in the accent circle
/// and "3 of 9 · 7 h 40".
class GridDayHeader extends StatelessWidget {
  const GridDayHeader({super.key, required this.load, required this.today});

  final DayLoad load;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final c = t.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final count = NumberFormat.decimalPattern(locale);
    final date = load.date;
    final isToday = date == today;
    final day = DateFormat.E(locale).format(date);
    final number = DateFormat.d(locale).format(date);
    final meta = isToday
        ? l10n.gridTodayCount(
            count.format(load.done),
            count.format(load.total),
            formatDurationShort(l10n, load.plannedMinutes),
          )
        : date.isBefore(today)
        ? l10n.gridDayDone(count.format(load.done))
        : l10n.spreadPlanned(load.total);
    return Semantics(
      header: true,
      label: l10n.statusHintJoin(
        DateFormat.MMMMEEEEd(locale).format(date),
        meta,
      ),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: DotSize.gridHeader),
        color: isToday ? c.gridTodayHead : null,
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.s + DotSpace.xxs,
          vertical: DotSpace.xs + DotSpace.xxs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isToday ? l10n.weekTodayDay(day) : day,
              style: isToday
                  ? t.styles.gridHour.copyWith(
                      color: c.accentText,
                      fontWeight: FontWeight.w700,
                    )
                  : t.styles.gridHour,
            ),
            Wrap(
              spacing: DotSpace.xs + DotSpace.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (isToday)
                  _TodayDate(text: number)
                else
                  Text(number, style: t.styles.gridDate),
                Text(
                  meta,
                  style: isToday
                      ? t.styles.gridDayMeta.copyWith(color: c.ink2)
                      : t.styles.gridDayMeta,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A 3 days header (E-R2-30): the whole date with Yesterday, Today or
/// Tomorrow, over "3 of 9 done"; today tinted.
class GridLongHeader extends StatelessWidget {
  const GridLongHeader({super.key, required this.load, required this.today});

  final DayLoad load;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final c = t.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = load.date;
    final isToday = date == today;
    final away = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
    final suffix = switch (away) {
      -1 => l10n.dayCardYesterdaySuffix,
      0 => l10n.dayCardTodaySuffix,
      1 => l10n.dayCardTomorrowSuffix,
      _ => '', // l10n-ignore: no suffix away from today
    };
    final date0 = DateFormat.MMMMEEEEd(locale).format(date);
    final title = '$date0$suffix'; // l10n-ignore: both parts localized
    final meta = l10n.monthDoneOf(load.done, load.total);
    return Semantics(
      header: true,
      label: l10n.statusHintJoin(title, meta),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: DotSize.gridHeader),
        color: isToday ? c.gridTodayHead : null,
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.s + DotSpace.xxs,
          vertical: DotSpace.xs + DotSpace.xxs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: t.styles.gridTitle.copyWith(
                color: isToday ? c.accentText : null,
              ),
            ),
            Text(meta, style: t.styles.gridMeta),
          ],
        ),
      ),
    );
  }
}

/// Today's date in the 22 accent circle.
class _TodayDate extends StatelessWidget {
  const _TodayDate({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Container(
      constraints: const BoxConstraints(
        minWidth: DotSize.gridKnot - DotSpace.xxs,
        minHeight: DotSize.gridKnot - DotSpace.xxs,
      ),
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.xs),
      decoration: ShapeDecoration(
        color: t.colors.accent,
        shape: const StadiumBorder(),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          text,
          style: t.styles.gridDayMeta.copyWith(
            color: t.colors.onAccent,
            fontWeight: FontWeight.w800,
            fontSize: t.styles.gridDayMeta.fontSize! + 1,
          ),
        ),
      ),
    );
  }
}
