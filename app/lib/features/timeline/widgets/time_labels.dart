import 'package:dottoday/domain/time/clock_time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Whether to show 24-h times: the user's setting, else the OS (docs/05).
bool use24hFor(BuildContext context, bool? setting) =>
    setting ?? MediaQuery.alwaysUse24HourFormatOf(context);

/// Compact hour label for the gutter: `09:00` (24 h) or `9 AM` (12 h).
String hourLabel(BuildContext context, ClockTime t, {required bool use24h}) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final at = DateTime(2000, 1, 1, t.hour, t.minute);
  if (use24h) return DateFormat.Hm(locale).format(at);
  return t.minute == 0
      ? DateFormat.j(locale).format(at)
      : DateFormat.jm(locale).format(at);
}

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
