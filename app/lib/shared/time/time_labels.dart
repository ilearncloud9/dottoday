import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Whether to show 24-h times: the user's setting, else the OS (docs/05).
bool use24hFor(BuildContext context, bool? setting) =>
    setting ?? MediaQuery.alwaysUse24HourFormatOf(context);

/// [utc] as a local clock time, formatted like `TimeInput` shows it.
String timeOfUtc(
  BuildContext context,
  tz.Location location,
  DateTime utc, {
  required bool use24h,
}) {
  final t = ClockTime.ofUtc(location, utc);
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay(hour: t.hour, minute: t.minute),
    alwaysUse24HourFormat: use24h,
  );
}

/// "Today", "Tomorrow", else "Thu, Oct 23" for the local date [day]
/// (y/m/d) seen from [today].
String relativeDayName(BuildContext context, DateTime day, DateTime? today) {
  final l10n = context.l10n;
  if (day == today) return l10n.sheetToday;
  if (today != null &&
      day == DateTime(today.year, today.month, today.day + 1)) {
    return l10n.sheetTomorrow;
  }
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.MMMEd(locale).format(day);
}

/// Clock texts for one local [day] in [zone] and the 12/24 h setting, as
/// the `ThreadPicker` and its captions show them.
final class DayTimeText {
  DayTimeText(this.context, this.zone, this.day, {required this.use24h});

  final BuildContext context;
  final tz.Location zone;
  final DateTime day;
  final bool use24h;

  /// "5:00 PM" for an instant.
  String utc(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);

  /// "5:00 PM" for minutes after [day]'s local midnight.
  String at(int minute) => utc(ClockTime.fromMinutes(minute).onDate(zone, day));

  /// "5:00 – 6:00 PM".
  String range(int start, int length) =>
      context.l10n.threadTimeRange(at(start), at(start + length));

  /// "4 PM" / "16:00".
  String hour(int minute) => use24h
      ? at(minute)
      : DateFormat.j(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(DateTime(2000, 1, 1, minute ~/ 60));

  /// "Wind Down · 22:00".
  String bed(DateTime bedUtc) => context.l10n.threadBed(utc(bedUtc));
}
