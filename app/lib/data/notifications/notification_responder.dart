import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';

/// Carries out what the user chose on a notification (docs/02 F6): Done
/// ticks this occurrence, Snooze reminds again in 10 minutes, +15 (the
/// web's, M9.7) gives it 15 more minutes, Open (or a plain tap) shows the
/// task, Start (Smallest step, M10.6) opens Focus on it. Writes go through
/// the write path, which then re-plans the notifications, so a ticked
/// task's later alerts disappear.
///
/// Snooze only re-reminds: a notification can't ask "shift the rest?", so
/// moving later tasks stays with the in-app Running late (docs/02 F6).
final class NotificationResponder {
  NotificationResponder({
    required Clock clock,
    required WriteUseCase writes,
    required OccurrenceRepository occurrences,
    required Future<Profile> Function() profile,
    required void Function(String location) open,
    required Logger logger,
  }) : _clock = clock,
       _writes = writes,
       _occurrences = occurrences,
       _profile = profile,
       _open = open,
       _logger = logger;

  final Clock _clock;
  final WriteUseCase _writes;
  final OccurrenceRepository _occurrences;
  final Future<Profile> Function() _profile;
  final void Function(String location) _open;
  final Logger _logger;

  /// Handles [tap]; the payload's occurrence ID is the only input trusted,
  /// and only for the current profile (06 §7).
  Future<void> handle(NotificationTap tap) async {
    final planned = decodeNotificationPayload(tap.id ?? 0, tap.payload);
    final action = NotificationAction.fromId(tap.actionId);
    _logger.info('notification.tapped', fields: {'action': action});
    // The Wind Down reminder opens the review, a free tomorrow included
    // (owner, 2026-10-31).
    if (planned?.purpose == NotificationPurpose.windDown) {
      return _open(AppRoutes.review);
    }
    // The day-start summary is about the day, not its first task.
    if (planned == null ||
        planned.occurrenceId.isEmpty ||
        planned.purpose == NotificationPurpose.daySummary) {
      return _open(AppRoutes.today);
    }
    // The Wake Up alarm on the notification path (older iPhones, exact
    // alarms off): its tap opens the Wake Up card (docs/15 §5).
    if (planned.purpose == NotificationPurpose.wakeUp) {
      return _open(AppRoutes.wakeUp);
    }
    if (action == NotificationAction.open) {
      return _open(AppRoutes.task(planned.occurrenceId));
    }
    final profile = await _profile();
    final task = await _occurrences.findById(profile.id, planned.occurrenceId);
    if (task == null || task.deletedAt != null) {
      return _open(AppRoutes.today);
    }
    final now = _clock.nowUtc();
    if (action == NotificationAction.start) {
      // Smallest step's Start (M10.6): Focus records the real start (B1).
      return _open(AppRoutes.focus(task.id));
    }
    final changed = switch (action) {
      NotificationAction.done => progress.markDone(task, now),
      // The web's +15 (M9.7): 15 more minutes, as the live row's +15.
      NotificationAction.plus15 => task.copyWith(
        durationMin: task.durationMin + AddFifteen.minutes,
      ),
      _ => task.copyWith(
        snoozedUntilUtc: now.add(
          const Duration(minutes: NotificationAction.snoozeMinutes),
        ),
      ),
    };
    final result = await _writes.apply(
      WriteBatch(userId: profile.id, occurrences: [changed]),
    );
    if (result case Err(:final failure)) {
      _logger.warn('notification.action_failed', error: failure);
      _open(AppRoutes.task(task.id));
    }
  }
}
