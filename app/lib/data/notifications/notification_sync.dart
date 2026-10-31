import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/data/notifications/wake_up_arming.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';
import 'package:dottoday/domain/repositories/wake_up_day_repository.dart';
import 'package:dottoday/domain/scheduling/start_nudge.dart';

/// Reconciles the OS pending notifications with the database: plan the
/// desired set, diff against what is pending, apply only the delta, so each
/// alert is scheduled exactly once (docs/04 §6, R-10). Runs after every
/// write and on start/resume.
final class NotificationSync {
  NotificationSync({
    required Clock clock,
    required NotificationPlanner planner,
    required NotificationGateway gateway,
    required OccurrenceRepository occurrences,
    required SeriesRepository series,
    required SettingsRepository settings,
    Future<DateTime?> Function()? testAlarmAt,
    SubtaskRepository? subtasks,
    WakeUpArming? arming,
    WakeUpDayRepository? days,
    this.ringsWakeUp = false,
  }) : _clock = clock,
       _planner = planner,
       _gateway = gateway,
       _occurrences = occurrences,
       _series = series,
       _settings = settings,
       _testAlarmAt = testAlarmAt,
       _subtasks = subtasks,
       _arming = arming,
       _days = days;

  // Alert offsets are <= 1 day (maxAlertOffsetMin) and blocks <= 1 day long,
  // so every fire time in the horizon belongs to a block in this margin.
  static const _margin = Duration(days: 2);

  final Clock _clock;
  final NotificationPlanner _planner;
  final NotificationGateway _gateway;
  final OccurrenceRepository _occurrences;
  final SeriesRepository _series;
  final SettingsRepository _settings;

  /// The requested test alarm (M6.5.9), planned like any reminder.
  final Future<DateTime?> Function()? _testAlarmAt;

  /// Which tasks have a step left, for Smallest step (M10.6).
  final SubtaskRepository? _subtasks;

  /// Arms the Wake Up alarms through `AlarmGateway` (docs/15 W1b); null
  /// rings them all on the notification path.
  final WakeUpArming? _arming;

  /// This device's mornings: a card "Start the day" calls the check off.
  final WakeUpDayRepository? _days;

  /// Whether this device rings the Wake Up alarm: phones only (docs/15 W1).
  final bool ringsWakeUp;

  /// Re-plans [userId]'s notifications and applies the delta to the OS.
  Future<void> resync(String userId) async {
    final profile = await _settings.watchProfile(userId).first;
    if (profile == null) return;
    final now = _clock.nowUtc();
    final blocks = await _occurrences
        .watchRange(
          userId,
          now.subtract(_margin),
          now.add(_planner.horizon + _margin),
        )
        .first;
    final series = await _series.watchActive(userId).first;
    final armed = await _armWakeUps(profile, blocks);
    final desired = _planner.plan(
      occurrences: blocks,
      tzId: profile.tzId,
      seriesAlerts: <String, List<Alert>>{
        for (final s in series) s.id: s.alerts,
      },
      quietHours: profile.settings.quietHours,
      daily: profile.settings,
      defaultSound: profile.settings.reminderSound,
      seriesSounds: <String, String?>{for (final s in series) s.id: s.soundId},
      startSound: profile.settings.startSoundId,
      testAlarmAtUtc: await _testAlarmAt?.call(),
      withSteps: await _withSteps(userId, blocks),
      ringsWakeUp: ringsWakeUp,
      armedWakeUps: armed,
    );
    final diff = NotificationPlanner.diff(desired, await _gateway.pending());
    if (diff.cancel.isEmpty && diff.schedule.isEmpty) return;
    await _gateway.apply(diff);
  }

  /// The Wake Up instants `AlarmGateway` rings (docs/15 W1b), each with
  /// its Wake Up Check: the first dot's Smallest step, and called off for
  /// a day that already began (15 W3).
  Future<Set<DateTime>> _armWakeUps(
    Profile profile,
    List<Occurrence> blocks,
  ) async {
    final arming = _arming;
    if (arming == null || !ringsWakeUp) return const {};
    final wakeUps = _planner.wakeUps(
      occurrences: blocks,
      tzId: profile.tzId,
      daily: profile.settings,
      ringsWakeUp: ringsWakeUp,
    );
    return arming.arm(
      wakeUps,
      profile: profile,
      tasks: {for (final o in blocks) o.id: o},
      steps: await _firstSteps(profile.id, {
        for (final w in wakeUps) w.occurrenceId,
      }),
      startedDays: await _startedDays(profile, blocks),
    );
  }

  /// The Smallest step of each of [ids] whose steps aren't started.
  Future<Map<String, Subtask>> _firstSteps(
    String userId,
    Set<String> ids,
  ) async {
    final subtasks = _subtasks;
    if (subtasks == null || ids.isEmpty) return const {};
    final byTask = <String, List<Subtask>>{};
    for (final s in await subtasks.watchForOccurrences(userId, ids).first) {
      (byTask[s.occurrenceId] ??= []).add(s);
    }
    return {
      for (final MapEntry(:key, :value) in byTask.entries)
        if (stepsNotStarted(value)) key: ?smallestStep(value),
    };
  }

  /// Days something really started (B1) or the Wake Up card's Start the
  /// day was tapped: their Wake Up Check is called off (15 W3).
  Future<Set<String>> _startedDays(
    Profile profile,
    List<Occurrence> blocks,
  ) async {
    final today = wakeUpDateKey(_clock.nowUtc(), profile.tzId);
    final row = await _days?.watch(today).first;
    return {
      for (final o in blocks)
        if (o.actualStartUtc case final at?) wakeUpDateKey(at, profile.tzId),
      if (row?.startedAtUtc != null) today,
    };
  }

  /// Occurrences among [blocks] with steps to do and none ticked yet.
  Future<Set<String>> _withSteps(String userId, List<Occurrence> blocks) async {
    final subtasks = _subtasks;
    final ids = {
      for (final o in blocks)
        if (o.actualStartUtc == null) o.id,
    };
    if (subtasks == null || ids.isEmpty) return const {};
    final steps = await subtasks.watchForOccurrences(userId, ids).first;
    final byTask = <String, List<Subtask>>{};
    for (final s in steps) {
      (byTask[s.occurrenceId] ??= []).add(s);
    }
    return {
      for (final MapEntry(:key, :value) in byTask.entries)
        if (stepsNotStarted(value)) key,
    };
  }
}
