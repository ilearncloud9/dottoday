import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:timezone/timezone.dart' as tz;

/// How many recent mornings the median reads (15 W0: "the last 10").
const learnWakeUpDays = 10;

/// Fewest mornings before anything is learned: one late morning is a
/// morning, not a habit (doc 13's reveal rules).
const learnMinMornings = 5;

/// A median under this is how waking up goes, not a pattern to act on.
const learnMinOffsetMin = 10;

/// The offer is never repeated inside this (15 §7b).
const learnOfferQuiet = Duration(days: 30);

/// The median minutes between each day's Wake Up time and "I'm up" over
/// [days] (`medianDismissOffsetMin`, 15 W0), or null with fewer than
/// [learnMinMornings]. Each day's Wake Up is its own weekday's, in
/// [location]. Local only: it is read from this phone's mornings.
///
/// ```dart
/// medianDismissOffsetMin(days, settings: s, location: berlin); // 12
/// ```
int? medianDismissOffsetMin(
  Iterable<WakeUpDay> days, {
  required Settings settings,
  required tz.Location location,
}) {
  final offsets = <int>[
    for (final d in days.take(learnWakeUpDays))
      if ((d.stoppedAtUtc, DateTime.tryParse(d.date)) case (
        final up?,
        final date?,
      ))
        up.difference(_wakeOn(date, settings, location)).inMinutes,
  ]..sort();
  if (offsets.length < learnMinMornings) return null;
  final mid = offsets.length ~/ 2;
  return offsets.length.isOdd
      ? offsets[mid]
      : ((offsets[mid - 1] + offsets[mid]) / 2).round();
}

/// The minutes the learned offer proposes moving Wind Down earlier, or
/// null when it isn't due (15 §7b): its switch on, a sleep target set
/// (Wind Down follows it), a median of at least [learnMinOffsetMin], room
/// left under the longest target, and not answered in [learnOfferQuiet].
/// The proposal is the median rounded up to the target's 15-min steps, so
/// Yes lands on a target Settings can show.
///
/// ```dart
/// windDownLearnOfferMin(s, offsetMin: 12, nowUtc: now); // 15
/// ```
int? windDownLearnOfferMin(
  Settings settings, {
  required int? offsetMin,
  required DateTime nowUtc,
}) {
  final target = settings.sleepTargetMin;
  if (!settings.windDownLearnOffer || target == null || offsetMin == null) {
    return null;
  }
  if (offsetMin < learnMinOffsetMin) return null;
  if (settings.windDownLearnOfferAt case final at?
      when nowUtc.difference(at) < learnOfferQuiet) {
    return null;
  }
  const step = 15;
  final more = (offsetMin + step - 1) ~/ step * step;
  return target + more <= sleepTargetChoices.last ? more : null;
}

DateTime _wakeOn(DateTime date, Settings settings, tz.Location location) =>
    DayShape.on(
      location,
      date,
      settings.boundaryFor(Weekday.values[date.weekday - 1]),
    ).wakeUtc;
