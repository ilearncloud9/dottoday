import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/calendar/calendar_source_repository.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

/// Device calendars without the OS: [state] now, [answer] to the prompt.
final class FakeDeviceCalendarGateway implements DeviceCalendarGateway {
  FakeDeviceCalendarGateway({
    this.state = PermissionState.notAsked,
    this.answer = PermissionState.granted,
    this.list = const [],
    this.failure,
    this.settingsOpen = false,
  });

  PermissionState state;
  final PermissionState answer;
  final List<DeviceCalendar> list;

  /// Returned by [calendars] instead of [list] while set.
  AppFailure? failure;
  final bool settingsOpen;
  var asked = 0;
  var openedSettings = 0;

  @override
  bool get available => true;

  @override
  Future<PermissionState> status() async => state;

  @override
  Future<PermissionState> request() async {
    asked++;
    return state = answer;
  }

  @override
  Future<bool> openSettings() async {
    openedSettings++;
    return settingsOpen;
  }

  @override
  Future<Result<List<DeviceCalendar>, AppFailure>> calendars() async =>
      switch (failure) {
        final f? => Err(f),
        null => Ok(list),
      };

  @override
  Future<Result<List<ExternalEvent>, AppFailure>> events(
    String calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  ) async => const Ok([]);
}

/// [CalendarSourceRepository] in memory.
final class FakeCalendarSourceRepository implements CalendarSourceRepository {
  final rows = <CalendarAccount>[];
  final _changes = StreamController<List<CalendarAccount>>.broadcast();

  @override
  Stream<List<CalendarAccount>> watchDevice(String userId) async* {
    yield [...rows];
    yield* _changes.stream;
  }

  @override
  Future<void> setEnabled(
    String userId,
    DeviceCalendar calendar, {
    required bool enabled,
  }) async {
    rows
      ..removeWhere((r) => r.externalAccountId == calendar.id)
      ..add(
        CalendarAccount(
          id: 'acc-${calendar.id}',
          userId: userId,
          provider: CalendarProvider.appleDevice,
          label: calendar.name,
          externalAccountId: calendar.id,
          enabled: enabled,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
    _changes.add([...rows]);
  }
}

/// iCloud Home (red) and Work (blue), a read-only Holidays, and a Gmail
/// calendar (green).
const sampleCalendars = [
  DeviceCalendar(
    id: 'home',
    name: 'Home',
    accountName: 'iCloud',
    colorArgb: 0xFFFF3B30,
  ),
  DeviceCalendar(
    id: 'work',
    name: 'Work',
    accountName: 'iCloud',
    colorArgb: 0xFF007AFF,
  ),
  DeviceCalendar(
    id: 'holidays',
    name: 'Holidays',
    accountName: 'Subscribed',
    colorArgb: 0xFF8E8E93,
    readOnly: true,
  ),
  DeviceCalendar(
    id: 'gym',
    name: 'Gym',
    accountName: 'kody@example.com',
    colorArgb: 0xFF34C759,
  ),
];
