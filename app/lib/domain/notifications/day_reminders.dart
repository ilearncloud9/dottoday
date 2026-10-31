import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_id.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:timezone/timezone.dart' as tz;

/// The once-a-day reminders the planner adds from Settings › Reminders:
/// Wind Down (M3d.3) and the day-start summary (docs/02 F6.2, M8.4d). Pure:
/// ids are stable per local date, so re-planning replaces rather than
/// duplicates (R-10).
abstract final class DayReminders {
  /// One reminder at each day's Wind Down in `(fromUtc, toUtc]`, on that
  /// weekday's own window (Settings › DAY SHAPE, per weekday), with the
  /// id of the next day's first planned task.
  ///
  /// ```dart
  /// DayReminders.Wind Down(settings: s, location: berlin, occurrences: rows,
  ///     fromUtc: now, toUtc: now.add(week), used: {}).length; // 7
  /// ```
  static List<PlannedNotification> windDown({
    required Settings settings,
    required tz.Location location,
    required Iterable<Occurrence> occurrences,
    required DateTime fromUtc,
    required DateTime toUtc,
    required Set<int> used,
  }) => [
    for (final (date, shape) in _days(settings, location, fromUtc, toUtc))
      if (shape.bedUtc.isAfter(fromUtc) && !shape.bedUtc.isAfter(toUtc))
        PlannedNotification(
          id: uniqueNotificationId(
            used,
            'windDown:${_key(date)}',
            PlannedNotification.windDownIndex,
          ),
          occurrenceId:
              _blocksOn(occurrences, location, _next(date)).firstOrNull?.id ??
              '',
          alertIndex: PlannedNotification.windDownIndex,
          fireAtUtc: shape.bedUtc,
          kind: AlertKind.atEnd,
          silent: inQuietHours(location, shape.bedUtc, settings.quietHours),
          purpose: NotificationPurpose.windDown,
        ),
  ];

  /// The Wake Up alarm (docs/15 W1, M17.1): loud at each day's Wake Up in
  /// `(fromUtc, toUtc]`, on that weekday's own window, for days that have a
  /// block ("only days I've planned", 15 §9). It ignores quiet hours like
  /// every loud start (15 §2), and `occurrenceId` is the day's first block,
  /// so the alarm says what the day starts with and re-posts when that
  /// changes.
  ///
  /// ```dart
  /// DayReminders.wakeUp(settings: s, location: berlin, occurrences: rows,
  ///     fromUtc: now, toUtc: now.add(week), used: {}); // one per planned day
  /// ```
  static List<PlannedNotification> wakeUp({
    required Settings settings,
    required tz.Location location,
    required Iterable<Occurrence> occurrences,
    required DateTime fromUtc,
    required DateTime toUtc,
    required Set<int> used,
  }) => [
    for (final (date, shape) in _days(settings, location, fromUtc, toUtc))
      if (shape.wakeUtc.isAfter(fromUtc) && !shape.wakeUtc.isAfter(toUtc))
        if (_blocksOn(occurrences, location, date).firstOrNull
            case final first?)
          PlannedNotification(
            id: uniqueNotificationId(
              used,
              'wakeup:${_key(date)}',
              PlannedNotification.wakeUpIndex,
            ),
            occurrenceId: first.id,
            alertIndex: PlannedNotification.wakeUpIndex,
            fireAtUtc: shape.wakeUtc,
            kind: AlertKind.atStart,
            sound: wakeUpSound(settings, date).id,
            loud: true,
            purpose: NotificationPurpose.wakeUp,
          ),
  ];

  /// "Your day: 6 blocks, first at 08:00" at Wake Up on each weekday in
  /// `settings.daySummaryDays`, for days in `(fromUtc, toUtc]` that have
  /// a block (an empty day needs no summary). [PlannedNotification.blocks]
  /// carries the count and `occurrenceId` the first block, so a change to
  /// either re-posts it. All-day items don't count: they aren't blocks on
  /// the thread.
  static List<PlannedNotification> daySummaries({
    required Settings settings,
    required tz.Location location,
    required Iterable<Occurrence> occurrences,
    required DateTime fromUtc,
    required DateTime toUtc,
    required Set<int> used,
  }) {
    if (settings.daySummaryDays.isEmpty) return const [];
    final out = <PlannedNotification>[];
    for (final (date, shape) in _days(settings, location, fromUtc, toUtc)) {
      final at = shape.wakeUtc;
      final weekday = Weekday.values[date.weekday - 1];
      if (!settings.daySummaryDays.contains(weekday)) continue;
      if (!at.isAfter(fromUtc) || at.isAfter(toUtc)) continue;
      final blocks = _blocksOn(occurrences, location, date);
      if (blocks.isEmpty) continue;
      out.add(
        PlannedNotification(
          id: uniqueNotificationId(
            used,
            'summary:${_key(date)}',
            PlannedNotification.daySummaryIndex,
          ),
          occurrenceId: blocks.first.id,
          alertIndex: PlannedNotification.daySummaryIndex,
          fireAtUtc: at,
          kind: AlertKind.atStart,
          silent: inQuietHours(location, at, settings.quietHours),
          purpose: NotificationPurpose.daySummary,
          blocks: blocks.length,
        ),
      );
    }
    return out;
  }

  /// (local date, its Wake Up → Wind Down) for every day from [fromUtc]'s
  /// local date until a day's Wake Up is past [toUtc].
  static Iterable<(DateTime, DayShape)> _days(
    Settings settings,
    tz.Location location,
    DateTime fromUtc,
    DateTime toUtc,
  ) sync* {
    final first = utcToWallClock(location, fromUtc);
    for (var d = 0; ; d++) {
      final date = DateTime(first.year, first.month, first.day + d);
      final shape = DayShape.on(
        location,
        date,
        settings.boundaryFor(Weekday.values[date.weekday - 1]),
      );
      if (shape.wakeUtc.isAfter(toUtc)) return;
      yield (date, shape);
    }
  }

  /// The timed blocks starting on local [date], earliest first.
  static List<Occurrence> _blocksOn(
    Iterable<Occurrence> occurrences,
    tz.Location location,
    DateTime date,
  ) {
    final out = [
      for (final o in occurrences)
        if (o.startUtc case final start?
            when o.durationMin < maxDurationMin &&
                _sameDay(utcToWallClock(location, start), date))
          o,
    ];
    return out..sort((a, b) {
      final byStart = a.startUtc!.compareTo(b.startUtc!);
      return byStart != 0 ? byStart : a.id.compareTo(b.id);
    });
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _next(DateTime date) =>
      DateTime(date.year, date.month, date.day + 1);

  static String _key(DateTime date) => '${date.year}-${date.month}-${date.day}';
}

/// [notificationIdFor], probing upward on the rare 31-bit collision so two
/// alerts never share (and overwrite) one OS slot.
int uniqueNotificationId(Set<int> used, String occurrenceId, int index) {
  var id = notificationIdFor(occurrenceId, index);
  while (!used.add(id)) {
    id = (id + 1) & 0x7FFFFFFF;
  }
  return id;
}

/// Whether [fireAtUtc] falls in [quiet] (wall clock in [location]; the end
/// is exclusive and the window may wrap past midnight). Null = off.
bool inQuietHours(tz.Location location, DateTime fireAtUtc, TimeWindow? quiet) {
  if (quiet == null) return false;
  final wall = utcToWallClock(location, fireAtUtc);
  final minute = wall.hour * 60 + wall.minute;
  final start = _minutes(quiet.start);
  final end = _minutes(quiet.end);
  return start <= end
      ? minute >= start && minute < end
      : minute >= start || minute < end;
}

int _minutes(String hhmm) =>
    int.parse(hhmm.substring(0, 2)) * 60 + int.parse(hhmm.substring(3, 5));
