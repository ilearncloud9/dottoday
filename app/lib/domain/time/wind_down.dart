import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:timezone/timezone.dart' as tz;

/// Sleep targets Settings and onboarding offer, in minutes: 6 h–10 h in
/// 15-minute steps (docs/15 §7, §9).
final List<int> sleepTargetChoices = List.unmodifiable([
  for (var m = 6 * 60; m <= 10 * 60; m += 15) m,
]);

/// A new account's sleep target (15 §7b: onboarding defaults to 8 h).
const defaultSleepTargetMin = 8 * 60;

/// A derived Wind Down closer than this to now is not offered: the
/// configured one wins and nothing is said (15 §7).
const _windDownLead = Duration(hours: 1);

/// Day [date]'s shape with its *effective* Wind Down (docs/15 W4): with a
/// sleep target, `min(configured, tomorrow's Wake Up − target)`. It is
/// derived and never stored; the review, the reminder, the snapshot and
/// Today's Wind Down cap all read it. The configured Wind Down stays when:
/// - there is no target;
/// - [tomorrowHasThread] is false;
/// - the derived one would fall before [nowUtc] + 1 h.
///
/// ```dart
/// effectiveDayShape(berlin, DateTime(2026, 11, 2), s.copyWith(
///     sleepTargetMin: 480), nowUtc: noon, tomorrowHasThread: true);
/// // Wind Down 22:00 for a 06:00 Wake Up tomorrow
/// ```
DayShape effectiveDayShape(
  tz.Location location,
  DateTime date,
  Settings settings, {
  required DateTime nowUtc,
  required bool tomorrowHasThread,
}) {
  final today = DayShape.on(location, date, settings.boundaryFor(_day(date)));
  final target = settings.sleepTargetMin;
  if (target == null || !tomorrowHasThread) return today;
  final derived = nextWakeUtc(
    location,
    date,
    settings,
  ).subtract(Duration(minutes: target));
  if (!derived.isBefore(today.bedUtc)) return today;
  if (derived.isBefore(nowUtc.add(_windDownLead))) return today;
  if (!derived.isAfter(today.wakeUtc)) return today;
  return DayShape(wakeUtc: today.wakeUtc, bedUtc: derived);
}

/// The Wake Up after day [date]: tomorrow's, on its own weekday window.
DateTime nextWakeUtc(tz.Location location, DateTime date, Settings settings) {
  final next = DateTime(date.year, date.month, date.day + 1);
  return DayShape.on(location, next, settings.boundaryFor(_day(next))).wakeUtc;
}

/// Minutes of night between [windDownUtc] and [nextWakeUtc] ("Night · 7 h
/// 45"); never negative.
int nightMinutes(DateTime windDownUtc, DateTime nextWakeUtc) {
  final m = nextWakeUtc.difference(windDownUtc).inMinutes;
  return m < 0 ? 0 : m;
}

Weekday _day(DateTime date) => Weekday.values[date.weekday - 1];
