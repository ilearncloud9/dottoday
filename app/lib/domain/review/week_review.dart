import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:timezone/timezone.dart' as tz;

/// The seven days the weekly review shows (11 D1, docs/09 M12.1) for
/// [today]: the week (starting on [firstDayOfWeek], 1 = Monday … 7 =
/// Sunday) that holds today, or, on the first day of a week, the week that
/// just ended — so Sunday at Wind Down shows the week ending tonight when
/// weeks start on Monday, and the one ending yesterday when they start on
/// Sunday (`B-ios-week-review`: Sunday 25 Oct shows 18 – 24 October).
///
/// ```dart
/// reviewWeek(DateTime(2026, 10, 25), 7).first; // 2026-10-18
/// ```
List<DateTime> reviewWeek(DateTime today, int firstDayOfWeek) {
  final back = (today.weekday - firstDayOfWeek) % DateTime.daysPerWeek;
  final offset = back == 0 ? DateTime.daysPerWeek : back;
  final first = DateTime(today.year, today.month, today.day - offset);
  return [
    for (var i = 0; i < DateTime.daysPerWeek; i++)
      DateTime(first.year, first.month, first.day + i),
  ];
}

/// One day of the review: its date and the day as it is ([DaySnapshot.ofDay]).
final class WeekReviewDay {
  const WeekReviewDay({required this.date, required this.snapshot});

  /// Local date (y/m/d).
  final DateTime date;
  final DaySnapshot snapshot;

  int get done => snapshot.dayDone;
  int get total => snapshot.dayTotal;

  /// Planned minutes: what sizes the day's dot.
  int get plannedMinutes =>
      snapshot.dots.fold(0, (sum, d) => sum + d.durationMin);
}

/// How the week's real starts (B1) went against the plan, for the first
/// half of the sentence. Never a judgement: there is no "slipped" case —
/// a week that doesn't fit one of these says nothing about timing.
enum WeekPace {
  /// Most morning tasks started within [WeekReview.onPlanMinutes] of plan.
  morningsToPlan,

  /// The same for the afternoon (from noon), when mornings don't qualify.
  afternoonsToPlan,

  /// Every planned task is done.
  allDone,

  /// Nothing was planned all week.
  quiet,

  /// None of the above: the sentence is only the busiest / lightest half.
  none,
}

/// "Seven dots" (11 D1, `B-ios-week-review`): one dot per day sized by
/// hours planned, "29 of 34 done", Busiest / Lightest, and one rule-written
/// sentence. No streaks, no count of days with something left, and no
/// comparison with another week (owner, 2026-10-25): every number is about
/// this week alone.
final class WeekReview {
  const WeekReview({
    required this.days,
    required this.pace,
    this.busiest,
    this.lightest,
  });

  /// Reviews [days] (seven, in order); [zone] decides what a morning is.
  ///
  /// ```dart
  /// final r = WeekReview.of(days, berlin);
  /// '${r.done} of ${r.total} done'; // "29 of 34 done"
  /// ```
  factory WeekReview.of(List<WeekReviewDay> days, tz.Location zone) {
    final planned = days.where((d) => d.plannedMinutes > 0);
    WeekReviewDay? pick(bool Function(WeekReviewDay a, WeekReviewDay b) b) =>
        planned.fold<WeekReviewDay?>(
          null,
          (best, d) => best == null || b(d, best) ? d : best,
        );
    final busiest = pick((a, b) => a.plannedMinutes > b.plannedMinutes);
    final lightest = pick((a, b) => a.plannedMinutes < b.plannedMinutes);
    return WeekReview(
      days: List.unmodifiable(days),
      pace: _pace(days, zone),
      busiest: busiest,
      // One planned day is both: name it once.
      lightest: identical(busiest, lightest) ? null : lightest,
    );
  }

  /// A real start this close after the planned one is "to plan".
  static const onPlanMinutes = 15;

  /// Fewest real starts in a part of the day before it is talked about.
  static const minStarts = 3;

  /// Share of those starts that must be to plan.
  static const onPlanShare = 0.8;

  /// Noon, local: mornings end here.
  static const _noon = 12;

  final List<WeekReviewDay> days;
  final WeekPace pace;

  /// Most planned time (ties: the earlier day); null for an empty week.
  final WeekReviewDay? busiest;

  /// Least planned time among days with something planned; null when only
  /// one day had anything.
  final WeekReviewDay? lightest;

  int get done => days.fold(0, (s, d) => s + d.done);
  int get total => days.fold(0, (s, d) => s + d.total);

  /// The most planned minutes on any day: the largest dot.
  int get maxPlannedMinutes =>
      days.fold(0, (m, d) => d.plannedMinutes > m ? d.plannedMinutes : m);

  static WeekPace _pace(List<WeekReviewDay> days, tz.Location zone) {
    final dots = [for (final d in days) ...d.snapshot.dots];
    if (dots.isEmpty) return WeekPace.quiet;
    bool morning(SnapshotDot d) =>
        tz.TZDateTime.from(d.startUtc, zone).hour < _noon;
    if (_toPlan(dots.where(morning))) return WeekPace.morningsToPlan;
    if (_toPlan(dots.where((d) => !morning(d)))) {
      return WeekPace.afternoonsToPlan;
    }
    if (dots.every((d) => d.done)) return WeekPace.allDone;
    return WeekPace.none;
  }

  /// Whether enough of [dots] really started and most of those on plan.
  static bool _toPlan(Iterable<SnapshotDot> dots) {
    final started = [
      for (final d in dots)
        if (d.actualStartUtc case final at?) at.difference(d.startUtc),
    ];
    if (started.length < minStarts) return false;
    final onPlan = started
        .where((gap) => gap.inMinutes <= onPlanMinutes)
        .length;
    return onPlan / started.length >= onPlanShare;
  }
}
