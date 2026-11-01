import 'package:dottoday/domain/wake_up/wake_up_day.dart';

/// This device's mornings (docs/15 §3, M17.3): local only, never synced.
abstract interface class WakeUpDayRepository {
  /// The row for [date] (`yyyy-MM-dd`), null until something happened.
  Stream<WakeUpDay?> watch(String date);

  /// The newest day the alarm rang or was stopped, for Notification
  /// health's "Last wake-up" line.
  Future<WakeUpDay?> lastAlarm();

  /// The newest [limit] days whose alarm "I'm up" stopped, newest first,
  /// for how long after Wake Up the user usually gets up (15 §7b).
  Future<List<WakeUpDay>> recentStops(int limit);

  /// Folds [events] into their days, in order (one transaction).
  Future<void> applyEvents(List<AlarmEvent> events);

  /// The card showed for [date] at [atUtc]: it won't open by itself again.
  Future<void> markCardShown(String date, DateTime atUtc);

  /// "Start the day" with no dot to start.
  Future<void> markStarted(String date, DateTime atUtc);

  /// "Can't right now" skipped [date]'s mission at [atUtc] (15 §8).
  Future<void> markMissionSkipped(String date, DateTime atUtc);

  /// When missions were skipped since [sinceUtc], for the offer to turn
  /// them off (15 §8 rule 4).
  Future<List<DateTime>> missionSkipsSince(DateTime sinceUtc);
}
