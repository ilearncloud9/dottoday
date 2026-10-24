import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

/// No device calendars here: the web (Google/Microsoft through the
/// backend, M7.4) and, until its EventKit bridge (M7.1b), macOS. Settings
/// says import arrives later; nothing is ever asked.
final class NoDeviceCalendarGateway implements DeviceCalendarGateway {
  const NoDeviceCalendarGateway();

  @override
  bool get available => false;

  @override
  Future<PermissionState> status() async => PermissionState.notAsked;

  @override
  Future<PermissionState> request() async => PermissionState.notAsked;

  @override
  Future<bool> openSettings() async => false;

  @override
  Future<Result<List<DeviceCalendar>, AppFailure>> calendars() async =>
      const Ok([]);

  @override
  Future<Result<List<ExternalEvent>, AppFailure>> events(
    String calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  ) async => const Ok([]);
}
