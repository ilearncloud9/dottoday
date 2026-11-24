import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// A schedule's name on its card and sheet: Every day, Weekdays, Weekend
/// or Days (ED-084).
String scheduleName(AppLocalizations l10n, Iterable<Weekday> days) =>
    switch (scheduleKind(days.toList())) {
      ScheduleKind.everyDay => l10n.wwdEveryDay,
      ScheduleKind.weekdays => l10n.wwdWeekdays,
      ScheduleKind.weekend => l10n.wwdWeekend,
      ScheduleKind.days => l10n.wwdDays,
    };

/// [days] in week order from [firstDay] (ISO 1–7).
List<Weekday> weekOrder(Iterable<Weekday> days, int firstDay) {
  final set = days.toSet();
  return [
    for (var i = 0; i < 7; i++)
      if (Weekday.values[(firstDay - 1 + i) % 7] case final d
          when set.contains(d))
        d,
  ];
}

/// "Mon–Fri" for three or more days in a row, else "Mon, Wed".
String daysText(BuildContext context, List<Weekday> days) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final names = [for (final d in days) weekdayName(locale, d)];
  final run = [
    for (var i = 1; i < days.length; i++)
      (days[i].index - days[i - 1].index) % 7 == 1,
  ].every((b) => b);
  if (days.length > 2 && run) {
    return l10n.wwdDayRange(names.first, names.last);
  }
  return names.reduce(l10n.listJoin);
}

/// "Saturday's and Sunday's" for the after-midnight note (E-Phones
/// Weekend).
String daysOwnText(BuildContext context, List<Weekday> days) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final names = [
    for (final d in days)
      l10n.schDayOf(
        DateFormat.EEEE(locale).format(DateTime(2024, 1, 1 + d.index)),
      ),
  ];
  if (names.length == 1) return names.single;
  final head = names.sublist(0, names.length - 1).reduce(l10n.listJoin);
  return l10n.schAnd(head, names.last);
}

/// The weekday's full name ("Saturday").
String weekdayFull(BuildContext context, Weekday d) => DateFormat.EEEE(
  Localizations.localeOf(context).toLanguageTag(),
).format(DateTime(2024, 1, 1 + d.index));

/// The hour labels around the dial: 12 AM, 6 AM, 12 PM, 6 PM in the
/// person's clock ("00", "06", "12", "18" in 24-hour time).
({String top, String right, String bottom, String left}) dialLabels(
  BuildContext context,
  bool? use24h,
) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final f = switch (use24h) {
    true => DateFormat('HH', locale), // l10n-ignore: date pattern
    false => DateFormat('h a', locale), // l10n-ignore: date pattern
    null => DateFormat.j(locale),
  };
  String at(int h) => f.format(DateTime(2024, 1, 1, h));
  return (top: at(0), right: at(6), bottom: at(12), left: at(18));
}

/// "30 min under your 8 h sleep target", "Matches your 8 h sleep target";
/// null without a target. [night] is the night's minutes.
String? sleepTargetLine(AppLocalizations l10n, Settings settings, int night) {
  final target = settings.sleepTargetMin;
  if (target == null) return null;
  final goal = formatDurationShort(l10n, target);
  final gap = night - target;
  if (gap == 0) return l10n.schMatchesTarget(goal);
  final by = formatDurationShort(l10n, gap.abs());
  return gap < 0 ? l10n.schUnderTarget(by, goal) : l10n.schOverTarget(by, goal);
}
