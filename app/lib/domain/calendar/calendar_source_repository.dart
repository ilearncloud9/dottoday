import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/calendar.dart';

/// Which calendars come into the timeline (docs/02 F5 per-calendar
/// toggle). One `calendar_accounts` row per calendar the person has
/// switched, keyed by its id in `external_account_id` (docs/05), with
/// the calendar's provider (this device's store unless it says Google or
/// Microsoft, M7.4). Local only: the switches are this device's.
abstract interface class CalendarSourceRepository {
  /// Live device-calendar rows of [userId].
  Stream<List<CalendarAccount>> watchDevice(String userId);

  /// Live rows of [userId]'s Google/Microsoft calendars (M7.4): switched
  /// per device too, keyed by the account-qualified calendar id.
  Stream<List<CalendarAccount>> watchCloud(String userId);

  /// Switches [calendar] on or off for [userId], creating its row the
  /// first time.
  Future<void> setEnabled(
    String userId,
    DeviceCalendar calendar, {
    required bool enabled,
  });

  /// Turns write-back for [calendar] on or off for [userId] (M7.3),
  /// creating its row (on) the first time.
  Future<void> setWriteBack(
    String userId,
    DeviceCalendar calendar, {
    required bool writeBack,
  });

  /// The row of [calendar] for [userId], created (on) when it has none:
  /// an imported event's `calendar_links.account_id` needs one
  /// (docs/09 M7.2).
  Future<CalendarAccount> ensure(String userId, DeviceCalendar calendar);
}
