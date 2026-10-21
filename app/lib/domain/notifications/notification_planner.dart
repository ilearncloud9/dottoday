import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_id.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:timezone/timezone.dart' as tz;

/// Computes the notifications that should be pending right now (docs/04 §6,
/// docs/02 F6, R-10).
///
/// Pure and idempotent: the same tasks and time always give the same set,
/// with stable IDs, so re-planning after any write can only replace or
/// cancel, never duplicate. [diff] turns the result into OS operations.
final class NotificationPlanner {
  const NotificationPlanner({
    required Clock clock,
    this.horizon = const Duration(days: 7),
    this.maxPending,
  }) : _clock = clock;

  /// iOS keeps at most 64 pending notifications (07 iOS).
  static const iosMaxPending = 64;

  final Clock _clock;

  /// How far ahead to plan; refreshed on open and in the background.
  final Duration horizon;

  /// Keep only the earliest this many (null = no limit).
  final int? maxPending;

  /// The desired pending set, earliest first.
  ///
  /// Only planned, scheduled, live occurrences alert. An occurrence with
  /// `alerts == null` inherits [seriesAlerts] for its series. Alerts in
  /// [quietHours] (wall clock in [tzId]) are kept but [silent], so nothing
  /// is lost. A future `snoozedUntilUtc` replaces every alert before it with
  /// one reminder at that time.
  List<PlannedNotification> plan({
    required Iterable<Occurrence> occurrences,
    required String tzId,
    Map<String, List<Alert>> seriesAlerts = const {},
    TimeWindow? quietHours,
  }) {
    final now = _clock.nowUtc();
    final end = now.add(horizon);
    final location = tz.getLocation(tzId);
    final usedIds = <int>{};
    final planned = <PlannedNotification>[];
    // Sorted by id so collision probing (below) is deterministic.
    final live = occurrences.where(_alerts).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    for (final o in live) {
      for (final (index, alert, fireAt) in _fireTimes(o, seriesAlerts)) {
        if (!fireAt.isAfter(now) || fireAt.isAfter(end)) continue;
        planned.add(
          PlannedNotification(
            id: _uniqueId(usedIds, o.id, index),
            occurrenceId: o.id,
            alertIndex: index,
            fireAtUtc: fireAt,
            kind: alert.kind,
            sound: alert.sound,
            silent: _inQuietHours(location, fireAt, quietHours),
          ),
        );
      }
    }
    planned.sort((a, b) {
      final byTime = a.fireAtUtc.compareTo(b.fireAtUtc);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    final limit = maxPending;
    return limit == null ? planned : planned.take(limit).toList();
  }

  /// Operations that turn [pending] (the OS set, by ID) into [desired]:
  /// cancel stale or changed IDs, schedule new or changed ones.
  static NotificationDiff diff(
    List<PlannedNotification> desired,
    Map<int, PlannedNotification> pending,
  ) {
    final wanted = {for (final n in desired) n.id: n};
    return NotificationDiff(
      cancel: [
        for (final MapEntry(:key, :value) in pending.entries)
          if (wanted[key] != value) key,
      ]..sort(),
      schedule: [
        for (final n in desired)
          if (pending[n.id] != n) n,
      ],
    );
  }

  static bool _alerts(Occurrence o) =>
      o.startUtc != null &&
      o.deletedAt == null &&
      o.status == OccurrenceStatus.planned;

  /// (alert index, alert, fire instant) for every alert of [o].
  static List<(int, Alert, DateTime)> _fireTimes(
    Occurrence o,
    Map<String, List<Alert>> seriesAlerts,
  ) {
    final alerts = o.alerts ?? seriesAlerts[o.seriesId] ?? const <Alert>[];
    final all = [
      for (final (i, a) in alerts.indexed) (i, a, _fireAt(o, a)),
    ];
    final snooze = o.snoozedUntilUtc;
    if (snooze == null) return all;
    return [
      for (final t in all)
        if (!t.$3.isBefore(snooze)) t,
      (
        PlannedNotification.snoozeIndex,
        const Alert(kind: AlertKind.atStart),
        snooze,
      ),
    ];
  }

  static DateTime _fireAt(Occurrence o, Alert a) {
    final offset = Duration(minutes: a.offsetMin);
    return switch (a.kind) {
      AlertKind.before => o.startUtc!.subtract(offset),
      AlertKind.atStart => o.startUtc!,
      AlertKind.atEnd => o.endUtc!,
      AlertKind.overdue => o.endUtc!.add(offset),
    };
  }

  /// [notificationIdFor], probing upward on the rare 31-bit collision so two
  /// alerts never share (and overwrite) one OS slot.
  static int _uniqueId(Set<int> used, String occurrenceId, int index) {
    var id = notificationIdFor(occurrenceId, index);
    while (!used.add(id)) {
      id = (id + 1) & 0x7FFFFFFF;
    }
    return id;
  }

  static bool _inQuietHours(
    tz.Location location,
    DateTime fireAtUtc,
    TimeWindow? quiet,
  ) {
    if (quiet == null) return false;
    final wall = utcToWallClock(location, fireAtUtc);
    final minute = wall.hour * 60 + wall.minute;
    final start = _minutes(quiet.start);
    final end = _minutes(quiet.end);
    return start <= end
        ? minute >= start && minute < end
        : minute >= start || minute < end;
  }

  static int _minutes(String hhmm) =>
      int.parse(hhmm.substring(0, 2)) * 60 + int.parse(hhmm.substring(3, 5));
}
