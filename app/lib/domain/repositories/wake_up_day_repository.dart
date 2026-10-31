import 'package:dottoday/domain/wake_up/wake_up_day.dart';

/// This device's mornings (docs/15 §3, M17.3): local only, never synced.
abstract interface class WakeUpDayRepository {
  /// The row for [date] (`yyyy-MM-dd`), null until something happened.
  Stream<WakeUpDay?> watch(String date);

  /// The newest day the alarm rang or was stopped, for Notification
  /// health's "Last wake-up" line.
  Future<WakeUpDay?> lastAlarm();

  /// Folds [events] into their days, in order (one transaction).
  Future<void> applyEvents(List<AlarmEvent> events);

  /// The card showed for [date] at [atUtc]: it won't open by itself again.
  Future<void> markCardShown(String date, DateTime atUtc);

  /// "Start the day" with no dot to start.
  Future<void> markStarted(String date, DateTime atUtc);
}
