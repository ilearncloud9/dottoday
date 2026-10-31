import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';
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
    this.ringsWakeUp = false,
  }) : _clock = clock,
       _planner = planner,
       _gateway = gateway,
       _occurrences = occurrences,
       _series = series,
       _settings = settings,
       _testAlarmAt = testAlarmAt,
       _subtasks = subtasks;

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
    );
    final diff = NotificationPlanner.diff(desired, await _gateway.pending());
    if (diff.cancel.isEmpty && diff.schedule.isEmpty) return;
    await _gateway.apply(diff);
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
