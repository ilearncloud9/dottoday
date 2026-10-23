import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';

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
  }) : _clock = clock,
       _planner = planner,
       _gateway = gateway,
       _occurrences = occurrences,
       _series = series,
       _settings = settings,
       _testAlarmAt = testAlarmAt;

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
      bedtimeFrom: profile.settings,
      testAlarmAtUtc: await _testAlarmAt?.call(),
    );
    final diff = NotificationPlanner.diff(desired, await _gateway.pending());
    if (diff.cancel.isEmpty && diff.schedule.isEmpty) return;
    await _gateway.apply(diff);
  }
}
