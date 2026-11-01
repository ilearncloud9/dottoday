import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/notifications/notification_content.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:timezone/timezone.dart' as tz;

/// Hands the week's Wake Up alarms to [AlarmGateway] (docs/15 W1b,
/// ADR-0017) and returns the instants it armed, which the notification
/// path then leaves out, so a Wake Up rings exactly once (R-10).
///
/// The armed instants are kept per device in `local_meta`: a background
/// engine can't reach the gateway (Android registers its channel on the
/// activity), and it still leaves out what the last reachable sync armed,
/// while ringing the rest on the notification path (W1a) rather than not
/// at all.
final class WakeUpArming {
  const WakeUpArming(
    this._gateway,
    this._db, {
    bool Function()? minimal,
    MissionSensors? sensors,
  }) : _minimal = minimal,
       _sensors = sensors;

  static const _key = 'armed_wake_ups';

  final AlarmGateway _gateway;
  final AppDatabase _db;

  /// Whether the ringing screen is minimal mode's (the provider asks
  /// `LayoutPolicy`; this code never reads the layout, ADR-0016).
  final bool Function()? _minimal;

  /// What missions this device can run (15 §8); none without it.
  final MissionSensors? _sensors;

  /// Arms [wakeUps] (`NotificationPlanner.wakeUps`) for [profile]; with the
  /// switch off, disarms every alarm once. [tasks] finds each day's first
  /// block by id and [steps] its Smallest step, for the Wake Up Check;
  /// [startedDays] call off the check of a day that began (15 W3).
  Future<Set<DateTime>> arm(
    List<PlannedNotification> wakeUps, {
    required Profile profile,
    required Map<String, Occurrence> tasks,
    Map<String, Subtask> steps = const {},
    Set<String> startedDays = const {},
  }) async {
    final known = await _read();
    if (!profile.settings.wakeUpAlarm) {
      if (known == null) return const {};
      await _gateway.disarmAll();
      await _write(null);
      return const {};
    }
    final alarms = [
      for (final w in wakeUps)
        composeWakeUpAlarm(
          w,
          task: tasks[w.occurrenceId],
          profile: profile,
          minimal: _minimal?.call() ?? false,
          step: steps[w.occurrenceId],
        ),
    ];
    final armed = await _gateway.sync(
      await _withMissions(alarms, profile, tasks.values),
      startedDays: startedDays,
    );
    if (armed == null) return known ?? const {};
    await _write(armed);
    return armed;
  }

  /// [alarms] with each morning's mission (15 §8): the mode, the alarm
  /// tier, what this device can run and how many dots the day has.
  Future<List<WakeUpAlarm>> _withMissions(
    List<WakeUpAlarm> alarms,
    Profile profile,
    Iterable<Occurrence> blocks,
  ) async {
    final settings = profile.settings;
    final sensors = _sensors;
    if (settings.missionMode == MissionMode.off || sensors == null) {
      return alarms;
    }
    final tier = (await _gateway.capabilities()).tier;
    final ready = {
      for (final k in MissionKind.values)
        if (await sensors.support(k) == MissionSupport.ready) k,
    };
    final zone = tz.getLocation(profile.tzId);
    final dots = <String, int>{};
    // Each day's first dot, whose "Make sure I'm up" flags its morning.
    final first = <String, Occurrence>{};
    for (final b in blocks) {
      if (b.startUtc case final start?) {
        final key = formatRouteDate(tz.TZDateTime.from(start, zone));
        dots.update(key, (n) => n + 1, ifAbsent: () => 1);
        if (b.status == OccurrenceStatus.skipped) continue;
        if (first[key] case final f? when !f.startUtc!.isAfter(start)) {
          continue;
        }
        first[key] = b;
      }
    }
    MissionPlan? plan(WakeUpAlarm a) {
      final local = tz.TZDateTime.from(a.fireAtUtc, zone);
      final key = formatRouteDate(local);
      return missionFor(
        settings,
        weekday: Weekday.values[local.weekday - 1],
        tier: tier,
        dots: dots[key] ?? 0,
        can: ready.contains,
        flagged: morningFlagged(settings, key, firstDotId: first[key]?.id),
      );
    }

    return [
      for (final a in alarms)
        a.id == WakeUpAlarm.testId ? a : a.withMission(plan(a)),
    ];
  }

  /// Null until the gateway armed something on this device, and after the
  /// switch went off.
  Future<Set<DateTime>?> _read() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    if (row == null) return null;
    return {
      for (final ms in row.value.split(',').map(int.tryParse).nonNulls)
        DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
    };
  }

  Future<void> _write(Set<DateTime>? armed) async {
    if (armed == null) {
      await (_db.delete(_db.localMeta)..where((m) => m.key.equals(_key))).go();
      return;
    }
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(
            key: _key,
            value: [
              for (final at in armed) at.millisecondsSinceEpoch,
            ].join(','),
          ),
        );
  }
}
