import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_policy.dart';
import 'package:dottoday/domain/notifications/day_reminders.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/scheduling/start_nudge.dart';
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

  /// What the planner keeps pending on Apple platforms: headroom under
  /// [iosMaxPending], whose overflow iOS drops silently. The nearest ones
  /// win and every resync refills the window (docs/09 M6.5, M8.4d).
  static const applePendingBudget = 50;

  final Clock _clock;

  /// How far ahead to plan; refreshed on open and in the background.
  final Duration horizon;

  /// Keep only the earliest this many (null = no limit).
  final int? maxPending;

  /// The desired pending set, earliest first. With [daily] settings, one
  /// Bedtime reminder per day (when `bedtimeReminder` is on) and the
  /// day-start summaries are added (see [DayReminders]).
  ///
  /// Only planned, scheduled, live occurrences alert. An occurrence with
  /// `alerts == null` inherits [seriesAlerts] for its series. Alerts in
  /// [quietHours] (wall clock in [tzId]) are kept but [silent], so nothing
  /// is lost. A future `snoozedUntilUtc` replaces every alert before it with
  /// one reminder at that time. An alert without its own sound takes
  /// [defaultSound] (Settings › Reminders › Sound, F6.6).
  ///
  /// The at-start alert of each day's first dot, of [routineStartIds] and
  /// of every [Occurrence.routineStart] is [PlannedNotification.loud] and ignores quiet hours (11 A0). A
  /// future [testAlarmAtUtc] adds the test alarm (M6.5.9). Each occurrence
  /// with a step in [firstSteps] gets one Smallest step reminder at
  /// [noStartAt] (M10.6); a real start, Done or a move re-plans it away.
  List<PlannedNotification> plan({
    required Iterable<Occurrence> occurrences,
    required String tzId,
    Map<String, List<Alert>> seriesAlerts = const {},
    TimeWindow? quietHours,
    Settings? daily,
    String? defaultSound,
    Set<String> routineStartIds = const {},
    DateTime? testAlarmAtUtc,
    Set<String> withSteps = const {},
  }) {
    final now = _clock.nowUtc();
    final end = now.add(horizon);
    final location = tz.getLocation(tzId);
    final usedIds = <int>{};
    final planned = <PlannedNotification>[];
    // Sorted by id so collision probing (below) is deterministic.
    final live = occurrences.where(_alerts).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final loud = loudStartIds(
      occurrences,
      location,
      // A dropped routine marks its first step (11 C2, M11.4).
      routineStartIds: {
        ...routineStartIds,
        for (final o in occurrences)
          if (o.routineStart) o.id,
      },
    );
    for (final o in live) {
      for (final (index, alert, fireAt) in _fireTimes(o, seriesAlerts)) {
        if (!fireAt.isAfter(now) || fireAt.isAfter(end)) continue;
        final isLoud =
            alert.kind == AlertKind.atStart &&
            index != PlannedNotification.snoozeIndex &&
            loud.contains(o.id);
        planned.add(
          PlannedNotification(
            id: uniqueNotificationId(usedIds, o.id, index),
            occurrenceId: o.id,
            alertIndex: index,
            fireAtUtc: fireAt,
            kind: alert.kind,
            sound: alert.sound ?? defaultSound,
            silent: !isLoud && inQuietHours(location, fireAt, quietHours),
            loud: isLoud,
          ),
        );
      }
    }
    planned.addAll(
      _smallestSteps(live, withSteps, now, end, location, quietHours, usedIds),
    );
    if (daily case final settings?) {
      if (settings.bedtimeReminder) {
        planned.addAll(
          DayReminders.bedtime(
            settings: settings,
            location: location,
            occurrences: live,
            fromUtc: now,
            toUtc: end,
            used: usedIds,
          ),
        );
      }
      planned.addAll(
        DayReminders.daySummaries(
          settings: settings,
          location: location,
          occurrences: live,
          fromUtc: now,
          toUtc: end,
          used: usedIds,
        ),
      );
    }
    if (testAlarmAtUtc case final at? when at.isAfter(now)) {
      planned.add(testAlarm(at, usedIds));
    }
    planned.sort((a, b) {
      final byTime = a.fireAtUtc.compareTo(b.fireAtUtc);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    final limit = maxPending;
    return limit == null ? planned : planned.take(limit).toList();
  }

  /// One Smallest step reminder per occurrence in [withSteps] (11 B2),
  /// at [noStartAt]: the shared "not started yet" trigger.
  static Iterable<PlannedNotification> _smallestSteps(
    List<Occurrence> live,
    Set<String> withSteps,
    DateTime now,
    DateTime end,
    tz.Location location,
    TimeWindow? quietHours,
    Set<int> used,
  ) sync* {
    for (final o in live) {
      if (!withSteps.contains(o.id)) continue;
      final at = noStartAt(o);
      if (at == null || !at.isAfter(now) || at.isAfter(end)) continue;
      const index = PlannedNotification.smallestStepIndex;
      yield PlannedNotification(
        id: uniqueNotificationId(used, o.id, index),
        occurrenceId: o.id,
        alertIndex: index,
        fireAtUtc: at,
        kind: AlertKind.atStart,
        silent: inQuietHours(location, at, quietHours),
        purpose: NotificationPurpose.smallestStep,
      );
    }
  }

  /// The one test alarm at [atUtc] (M6.5.9): loud, never silent, in its
  /// own slot so it can't collide with a task's alert.
  static PlannedNotification testAlarm(DateTime atUtc, Set<int> used) =>
      PlannedNotification(
        id: uniqueNotificationId(
          used,
          'test-alarm',
          PlannedNotification.testAlarmIndex,
        ),
        occurrenceId: '',
        alertIndex: PlannedNotification.testAlarmIndex,
        fireAtUtc: atUtc,
        kind: AlertKind.atStart,
        loud: true,
        purpose: NotificationPurpose.testAlarm,
      );

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
    final all = [for (final (i, a) in alerts.indexed) (i, a, _fireAt(o, a))];
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
}
