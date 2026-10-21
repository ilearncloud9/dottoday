import 'package:dottoday/domain/time/clock_time.dart';
import 'package:flutter/material.dart';
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
