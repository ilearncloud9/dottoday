import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_policy.dart';
import 'package:dottoday/domain/notifications/day_reminders.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
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
  /// one reminder at that time. A task reminder's sound follows docs/12 §3:
  /// the alert's, the occurrence's, [seriesSounds] for its series, then
  /// [defaultSound] (Settings › Reminders › Sound); see [soundKeyFor].
  /// A loud one always plays [startSound] (D2).
  ///
  /// The at-start alert of each day's first dot, of [routineStartIds] and
  /// of every [Occurrence.routineStart] is [PlannedNotification.loud] and ignores quiet hours (11 A0). A
  /// future [testAlarmAtUtc] adds the test alarm (M6.5.9). Each occurrence
  /// with a step in [firstSteps] gets one Smallest step reminder at
  /// [noStartAt] (M10.6); a real start, Done or a move re-plans it away.
  /// While [daily]'s low-energy mode lasts, only loud ones stay (M12.2).
  List<PlannedNotification> plan({
    required Iterable<Occurrence> occurrences,
    required String tzId,
    Map<String, List<Alert>> seriesAlerts = const {},
    TimeWindow? quietHours,
    Settings? daily,
    String? defaultSound,
    Map<String, String?> seriesSounds = const {},
    String? startSound,
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
            sound: isLoud
                ? resolveStartSound(startSound).id
                : soundKeyFor(
                    alert: alert.sound,
                    occurrence: o.soundId,
                    series: seriesSounds[o.seriesId],
                    settings: defaultSound,
                  ),
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
      planned.add(testAlarm(at, usedIds, startSound: startSound));
    }
    // Low-energy mode (11 D2, M12.2): every nudge before it ends is off;
    // alarm-loud starts (the day's first dot, routine starts, the test
    // alarm) still ring (A0).
    if (daily?.lowEnergyUntil case final until? when until.isAfter(now)) {
      planned.removeWhere((n) => !n.loud && n.fireAtUtc.isBefore(until));
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
  /// own slot so it can't collide with a task's alert. It rings with
  /// [startSound], so the test sounds like the real first dot (docs/12).
  static PlannedNotification testAlarm(
    DateTime atUtc,
    Set<int> used, {
    String? startSound,
  }) => PlannedNotification(
    id: uniqueNotificationId(
      used,
      'test-alarm',
      PlannedNotification.testAlarmIndex,
    ),
    occurrenceId: '',
    alertIndex: PlannedNotification.testAlarmIndex,
    fireAtUtc: atUtc,
    kind: AlertKind.atStart,
    sound: resolveStartSound(startSound).id,
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

/// The stored sound key of a normal-tier task reminder
/// ([PlannedNotification.sound]): a catalogue id, [soundNoneKey] for
/// silent, or null for the OS sound. Null keeps the key every reminder had
/// before docs/12 for a user on the OS sound, so their pending reminders
/// aren't all posted again on upgrade.
///
/// ```dart
/// soundKeyFor(series: 'clear.lift', settings: 'system'); // 'clear.lift'
/// soundKeyFor(settings: 'system');                       // null
/// soundKeyFor(occurrence: 'none', settings: 'bell');     // 'none'
/// ```
String? soundKeyFor({
  String? alert,
  String? occurrence,
  String? series,
  String? settings,
}) => switch (resolveReminderSound(
  alert: alert,
  occurrence: occurrence,
  series: series,
  settings: settings,
)) {
  SilentSound() => soundNoneKey,
  SystemSound() => null,
  BundledSound(:final sound) => sound.id,
};
