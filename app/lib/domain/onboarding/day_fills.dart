import 'dart:math' as math;

import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/series.dart';

/// The four things "What fills your days?" offers (onboarding prototype
/// `RT`, ED-305): Morning run, Deep work, Gym and Read, with their colour,
/// icon and length (`kind`). Titles come from the app's strings.
enum FillPreset {
  morningRun('coral', 'run', 45),
  deepWork('indigo', 'target', 90),
  gym('violet', 'gym', 60),
  read('brown', 'book', 30);

  const FillPreset(this.colorKey, this.iconKey, this.durationMin);

  final String colorKey;
  final String iconKey;
  final int durationMin;

  /// Where it lands on a day from [wake] to [wind] (minutes from the day's
  /// midnight; `rtime`): a run 15 minutes after Wake Up, deep work an hour
  /// after it but not before 9:00, the gym two hours before Wind Down but
  /// not after 18:00, reading 90 minutes before Wind Down; on 15 minutes.
  ///
  /// ```dart
  /// FillPreset.read.minuteOn(420, 1380); // 1290: 21:30
  /// ```
  int minuteOn(int wake, int wind) => _quarter(switch (this) {
    morningRun => wake + 15,
    deepWork => math.max(9 * 60, wake + 60),
    gym => math.min(18 * 60, wind - 120),
    read => wind - 90,
  });
}

/// At most this many picks ("Five is plenty to start with.").
const maxFills = 5;

/// One thing picked or typed on "What fills your days?": it becomes a
/// task that repeats every day (ED-485).
final class DayFill {
  /// A typed one, at its own [minute].
  const DayFill.typed({
    required this.id,
    required this.title,
    required this.colorKey,
    required this.iconKey,
    required int this.minute,
    required this.durationMin,
  }) : preset = null;

  /// One of the four, whose time follows Wake Up and Wind Down.
  DayFill.preset({
    required this.id,
    required this.title,
    required FillPreset this.preset,
  }) : colorKey = preset.colorKey,
       iconKey = preset.iconKey,
       durationMin = preset.durationMin,
       minute = null;

  /// Its series' id: the same each time it is saved, so saving again
  /// (Back, then That's my day) updates rather than duplicates.
  final String id;
  final String title;
  final String colorKey;
  final String iconKey;
  final int durationMin;

  /// A typed one's time, minutes from the day's midnight (past 1440 is
  /// after midnight); null for a preset.
  final int? minute;
  final FillPreset? preset;

  /// Its time on a day from [wake] to [wind].
  int minuteOn(int wake, int wind) => preset?.minuteOn(wake, wind) ?? minute!;
}

/// The middle of the longest gap between Wake Up, the picks and Wind
/// Down, on 15 minutes (`gapTime`): where something typed without a time
/// goes.
///
/// ```dart
/// fillGapMinute(420, 1380, [435]); // 915: 15:15
/// ```
int fillGapMinute(int wake, int wind, Iterable<int> taken) {
  final ts = [wake, ...taken, wind]..sort();
  var best = 0;
  for (var i = 1; i < ts.length - 1; i++) {
    if (ts[i + 1] - ts[i] > ts[best + 1] - ts[best]) best = i;
  }
  return _quarter((ts[best] + ts[best + 1]) / 2);
}

/// A typed time kept inside the day: 15 minutes after Wake Up at the
/// earliest, 15 before Wind Down at the latest (`mountRhythm`).
int clampFillMinute(int minute, int wake, int wind) =>
    math.min(wind - 15, math.max(wake + 15, minute));

/// [fills] as tasks that repeat every day from [day] (the user's today,
/// local), each at its time on a day from [wake] to [wind] and its length
/// in [tzId], with [alerts] (Settings
/// › Reminders' defaults, as every new task gets).
///
/// ```dart
/// fillsSeries([run], userId: me, tzId: 'Europe/Berlin',
///   day: DateTime(2026, 10, 21), wake: 420, wind: 1380, nowUtc: now)
///   .single.rrule; // FREQ=DAILY
/// ```
List<Series> fillsSeries(
  Iterable<DayFill> fills, {
  required String userId,
  required String tzId,
  required DateTime day,
  required int wake,
  required int wind,
  required DateTime nowUtc,
  List<Alert> alerts = const [],
}) => [
  for (final f in fills.take(maxFills))
    Series(
      id: f.id,
      userId: userId,
      title: f.title,
      colorKey: f.colorKey,
      iconKey: f.iconKey,
      durationMin: f.durationMin,
      rrule: 'FREQ=DAILY',
      dtstartLocal: _isoLocal(day, f.minuteOn(wake, wind)),
      tzId: tzId,
      alerts: alerts,
      createdAt: nowUtc,
      updatedAt: nowUtc,
    ),
];

/// What the nudge is about (`setSubject`): of [picked], the first after
/// [now] on a day from [wake] to [wind], else the first; null when none
/// was picked (the nudge is about Wind Down then).
///
/// ```dart
/// nudgeSubject([run, read], 420, 1380, 581)?.title; // Read
/// ```
DayFill? nudgeSubject(List<DayFill> picked, int wake, int wind, int now) {
  if (picked.isEmpty) return null;
  final sorted = [...picked]
    ..sort((a, b) => a.minuteOn(wake, wind).compareTo(b.minuteOn(wake, wind)));
  for (final f in sorted) {
    if (f.minuteOn(wake, wind) > now) return f;
  }
  return sorted.first;
}

int _quarter(num minutes) => (minutes / 15).round() * 15;

/// `2026-10-21T07:15`; a minute past midnight starts the next day.
String _isoLocal(DateTime day, int minute) {
  final t = DateTime(day.year, day.month, day.day, 0, minute);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)}T'
      '${two(t.hour)}:${two(t.minute)}';
}
