import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:intl/intl.dart';

/// "Every 2 weeks on Mon, Fri · until Dec 31" for [rule] starting on
/// [start] (a local date; it names the monthly day) (docs/09 M3f.1).
String repeatRuleText(
  AppLocalizations l10n,
  String locale,
  RepeatRule rule,
  DateTime start,
) {
  final n = rule.interval;
  final base = switch (rule.frequency) {
    RepeatFrequency.daily => l10n.repeatEveryDays(n),
    RepeatFrequency.weekly when rule.isWeekdays => l10n.repeatEveryWeekday,
    RepeatFrequency.weekly when rule.days.isEmpty => l10n.repeatEveryWeeks(n),
    RepeatFrequency.weekly => l10n.repeatEveryWeeksOn(
      n,
      weekdayList(l10n, locale, rule.days),
    ),
    RepeatFrequency.monthly when rule.monthlyBy == MonthlyBy.weekday =>
      l10n.repeatEveryMonthsOnNth(
        n,
        l10n.repeatNth(RepeatRule.nthOfMonth(start)),
        DateFormat.EEEE(locale).format(start),
      ),
    RepeatFrequency.monthly => l10n.repeatEveryMonthsOnDay(n, start.day),
    RepeatFrequency.yearly => l10n.repeatEveryYears(n),
  };
  return switch (rule.end) {
    EndsAfter(:final count) => l10n.repeatTimes(base, count),
    EndsOn(:final until) => l10n.repeatUntil(
      base,
      DateFormat.MMMd(locale).format(until),
    ),
    EndsNever() => base,
  };
}

/// "Mon, Wed, Fri" in week order.
String weekdayList(AppLocalizations l10n, String locale, Set<Weekday> days) => [
  for (final d in Weekday.values)
    if (days.contains(d)) weekdayShort(locale, d),
].reduce(l10n.listJoin);

/// Short local weekday name; 2024-01-01 was a Monday.
String weekdayShort(String locale, Weekday d) =>
    DateFormat.E(locale).format(DateTime(2024, 1, 1 + d.index));
