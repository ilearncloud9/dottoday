import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/calendar.dart';

/// Which device calendars come into the timeline (docs/02 F5 per-calendar
/// toggle). One `calendar_accounts` row per device calendar the person has
/// switched, keyed by its device id in `external_account_id` (docs/05).
/// Local only: device ids mean nothing on another device.
abstract interface class CalendarSourceRepository {
  /// Live device-calendar rows of [userId].
  Stream<List<CalendarAccount>> watchDevice(String userId);

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
