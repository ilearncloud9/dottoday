import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';

/// One schedule as the sheet edits it (ED-084, ED-448): its days, its Wake
/// Up and Wind Down, and whether those days ring and remind.
typedef ScheduleDraft = ({
  Set<Weekday> days,
  TimeWindow window,
  bool ring,
  bool remind,
});

/// The shortest night and day before the sheet asks "Keep it?" (E-Phones
/// "New schedule checks"): a warning, never a block.
const int shortNightMinutes = 3 * 60;
const int shortDayMinutes = 4 * 60;

/// [s] with [draft] saved over the schedule that had [before] (empty for
/// a new one). Its days take its window, ring and reminder; days taken
/// from another schedule leave it. Days dropped from [before] go back to
/// the default day ([Settings.defaultDayBoundary]) with no alarm and the
/// Wind Down reminder on (owner 2026-11-24, ED-448).
///
/// ```dart
/// saveSchedule(s, before: {}, draft: (days: {Weekday.sat}, window: w,
///     ring: false, remind: true)); // Saturday has its own schedule
/// ```
Settings saveSchedule(
  Settings s, {
  required Set<Weekday> before,
  required ScheduleDraft draft,
}) {
  final dropped = before.difference(draft.days);
  final boundaries = {
    for (final d in Weekday.values)
      if (!dropped.contains(d)) d: s.boundaryFor(d),
  };
  for (final d in draft.days) {
    boundaries[d] = draft.window;
  }
  Set<Weekday> mark(Set<Weekday> set, {required bool on}) => {
    for (final d in Weekday.values)
      if (draft.days.contains(d) ? on : set.contains(d)) d,
  };
  return s.copyWith(
    dayBoundaries: boundaries,
    wakeUpAlarmDays: mark(
      s.wakeUpAlarmDays,
      on: draft.ring,
    ).difference(dropped),
    windDownReminderDays: mark(
      s.windDownReminderDays,
      on: draft.remind,
    ).union(dropped),
  );
}

/// [s] without the schedule on [days]: they go back to the default day
/// with no alarm and the Wind Down reminder on ("Remove this schedule",
/// owner 2026-11-24, ED-448).
Settings removeSchedule(Settings s, Set<Weekday> days) => saveSchedule(
  s,
  before: days,
  draft: (
    days: const {},
    window: Settings.defaultDayBoundary,
    ring: false,
    remind: true,
  ),
);

/// Minutes from Wind Down to Wake Up, across midnight: 23:00 → 06:30 is
/// 450.
int nightMinutes(TimeWindow w) =>
    (windowMinutes(w.start) - windowMinutes(w.end)) % Duration.minutesPerDay;

/// What the sheet says about a draft (E-Phones "New schedule checks").
enum ScheduleCheck {
  /// Wake Up and Wind Down are the same time: Save stays off.
  sameTime,

  /// No day is picked: Save stays off.
  noDays,

  /// "That's a 2 h 30 night. Keep it?" Save still works.
  shortNight,

  /// "That leaves 3 h of day." Save still works.
  shortDay,

  /// Wind Down is after midnight: it ends the evening of the days before.
  afterMidnight,
}

/// [draft]'s checks, blocking ones first.
List<ScheduleCheck> scheduleChecks(ScheduleDraft draft) {
  final wake = windowMinutes(draft.window.start);
  final windDown = windowMinutes(draft.window.end);
  final same =
      wake % Duration.minutesPerDay == windDown % Duration.minutesPerDay;
  if (same || draft.days.isEmpty) {
    return [
      if (same) ScheduleCheck.sameTime,
      if (draft.days.isEmpty) ScheduleCheck.noDays,
    ];
  }
  final night = nightMinutes(draft.window);
  return [
    if (night < shortNightMinutes) ScheduleCheck.shortNight,
    if (Duration.minutesPerDay - night < shortDayMinutes)
      ScheduleCheck.shortDay,
    if (windDownNextDay(windDown)) ScheduleCheck.afterMidnight,
  ];
}

/// Whether [checks] keep Save off.
bool blocksSave(List<ScheduleCheck> checks) =>
    checks.contains(ScheduleCheck.sameTime) ||
    checks.contains(ScheduleCheck.noDays);
