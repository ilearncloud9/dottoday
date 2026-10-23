import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/widgets/widget_snapshot_writer.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';

/// The daily refresh (docs/07, docs/09 M5.2): rolls every repeating task's
/// 90-day window forward, then re-plans notifications for the next 7 days
/// and redraws the home-screen widgets.
///
/// Series are only materialised when saved, so without this a repeat would
/// run out 90 days after its last edit. Runs on start/resume, on a timer
/// while the app stays open, and from the OS background scheduler on iOS
/// and Android. Idempotent: a second run the same day writes nothing.
final class DailyRefresh {
  DailyRefresh({
    required Clock clock,
    required SeriesRepository series,
    required WriteUseCase writes,
    required NotificationSync notifications,
    required WidgetSnapshotWriter widgets,
    required Logger logger,
  }) : _clock = clock,
       _series = series,
       _writes = writes,
       _notifications = notifications,
       _widgets = widgets,
       _logger = logger;

  /// Re-materialise once a series' window ends within this much of the
  /// full horizon, so a day's refresh moves it on by about a day.
  static const slack = Duration(days: 1);

  final Clock _clock;
  final SeriesRepository _series;
  final WriteUseCase _writes;
  final NotificationSync _notifications;
  final WidgetSnapshotWriter _widgets;
  final Logger _logger;

  /// Refreshes [userId]'s data; true when everything succeeded.
  Future<bool> run(String userId) async {
    final due = await _series.findNeedingMaterialisation(
      userId,
      _clock.nowUtc().add(Materialiser.horizon - slack),
    );
    var ok = true;
    if (due.isNotEmpty) {
      // Saving a series through the write path materialises it (M2.3) and
      // re-plans notifications after the commit.
      final result = await _writes.apply(
        WriteBatch(userId: userId, series: due),
      );
      if (result case Err(:final failure)) {
        _logger.warn('refresh.materialise_failed', error: failure);
        ok = false;
      }
    } else {
      // No write, so no after-write effects: re-plan and redraw here (the
      // widgets' 24 h window moves on even when nothing changes, M5.4).
      await _notifications.resync(userId);
      await _widgets.write(userId);
    }
    _logger.info('refresh.done', fields: {'series': due.length});
    return ok;
  }
}
