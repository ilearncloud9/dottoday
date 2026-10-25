import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/snapshot/day_snapshot_writer.dart';

/// Post-commit side effects of a write: notification resync and widget
/// snapshot. Runs one at a time in commit order, so two quick writes can't
/// diff against the same stale OS pending set and double-schedule (R-10).
/// A failure is logged and never rolls back the committed write; the next
/// write or app start re-runs both (the DB is the source of truth).
final class AfterWriteEffects {
  AfterWriteEffects({
    required NotificationSync notifications,
    required DaySnapshotWriter snapshot,
    required Logger logger,
  }) : _notifications = notifications,
       _snapshot = snapshot,
       _logger = logger;

  final NotificationSync _notifications;
  final DaySnapshotWriter _snapshot;
  final Logger _logger;
  Future<void> _tail = Future.value();

  /// Completes when every scheduled run has finished.
  Future<void> get idle => _tail;

  /// Queues a run for [userId] after any run already queued.
  void schedule(String userId) {
    _tail = _tail.then((_) => _run(userId));
  }

  // Each effect is isolated: one failing must not skip the other or break
  // the queue. Logged by type only (no task content, CLAUDE.md §4).
  Future<void> _run(String userId) async {
    try {
      await _notifications.resync(userId);
    } on Object catch (e, st) {
      _logger.error('notifications.resync_failed', error: e, stackTrace: st);
    }
    try {
      await _snapshot.write(userId);
    } on Object catch (e, st) {
      _logger.error('day_snapshot.write_failed', error: e, stackTrace: st);
    }
  }
}
