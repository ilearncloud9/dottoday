import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/domain/calendar/calendar_import.dart';
import 'package:dottoday/domain/calendar/calendar_source_repository.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/calendar/write_back_merge.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:timezone/timezone.dart' as tz;

/// Device calendars without the OS: [state] now, [answer] to the prompt.
final class FakeDeviceCalendarGateway implements DeviceCalendarGateway {
  FakeDeviceCalendarGateway({
    this.state = PermissionState.notAsked,
    this.answer = PermissionState.granted,
    this.list = const [],
    this.failure,
    this.settingsOpen = false,
    Map<String, List<ExternalEvent>>? events,
  }) : eventsByCalendar = events ?? {};

  PermissionState state;
  final PermissionState answer;
  final List<DeviceCalendar> list;

  /// Returned by [calendars] instead of [list] while set.
  AppFailure? failure;
  final bool settingsOpen;

  /// Each calendar's events; a calendar in [failingCalendars] can't be
  /// read.
  final Map<String, List<ExternalEvent>> eventsByCalendar;
  final failingCalendars = <String>{};

  /// Updates sent through [updateEvent], in order.
  final updates = <EventUpdate>[];

  /// What [updateEvent] answers; [EventWriteResult.written] changes the
  /// stored event, as the calendar would.
  EventWriteResult writeResult = EventWriteResult.written;

  /// Whether [event] fails to read.
  var readFails = false;
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
  ) async {
    if (failingCalendars.contains(calendarId)) {
      return const Err(StorageFailure());
    }
    return Ok([
      for (final e in eventsByCalendar[calendarId] ?? const <ExternalEvent>[])
        if (e.startUtc.isBefore(toUtc) && e.endUtc.isAfter(fromUtc)) e,
    ]);
  }

  @override
  Future<Result<ExternalEvent?, AppFailure>> event(
    String calendarId,
    String eventId,
  ) async {
    if (readFails) return const Err(StorageFailure());
    final list = eventsByCalendar[calendarId] ?? const <ExternalEvent>[];
    return Ok(list.where((e) => e.id == eventId).firstOrNull);
  }

  @override
  Future<EventWriteResult> updateEvent(EventUpdate update) async {
    updates.add(update);
    if (writeResult != EventWriteResult.written) return writeResult;
    final list = eventsByCalendar[update.calendarId] ?? [];
    final i = list.indexWhere((e) => e.id == update.eventId);
    if (i < 0) return EventWriteResult.gone;
    final e = list[i];
    list[i] = ExternalEvent(
      id: e.id,
      calendarId: e.calendarId,
      title: update.title ?? e.title,
      startUtc: update.startUtc,
      endUtc: update.endUtc,
      description: e.description,
      url: e.url,
    );
    return EventWriteResult.written;
  }
}

/// [CalendarSourceRepository] in memory.
final class FakeCalendarSourceRepository implements CalendarSourceRepository {
  final rows = <CalendarAccount>[];
  final _changes = StreamController<List<CalendarAccount>>.broadcast();

  @override
  Stream<List<CalendarAccount>> watchDevice(String userId) =>
      _watch((r) => !_cloud.contains(r.provider));

  @override
  Stream<List<CalendarAccount>> watchCloud(String userId) =>
      _watch((r) => _cloud.contains(r.provider));

  static const _cloud = {CalendarProvider.google, CalendarProvider.microsoft};

  Stream<List<CalendarAccount>> _watch(
    bool Function(CalendarAccount) where,
  ) async* {
    yield rows.where(where).toList();
    yield* _changes.stream.map((all) => all.where(where).toList());
  }

  @override
  Future<void> setEnabled(
    String userId,
    DeviceCalendar calendar, {
    required bool enabled,
  }) async {
    final writeBack = rows.any(
      (r) => r.externalAccountId == calendar.id && r.writeBack,
    );
    rows
      ..removeWhere((r) => r.externalAccountId == calendar.id)
      ..add(
        CalendarAccount(
          id: 'acc-${calendar.id}',
          userId: userId,
          provider: calendar.provider ?? CalendarProvider.appleDevice,
          label: calendar.name,
          externalAccountId: calendar.id,
          enabled: enabled,
          writeBack: writeBack,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
    _changes.add([...rows]);
  }

  @override
  Future<void> setWriteBack(
    String userId,
    DeviceCalendar calendar, {
    required bool writeBack,
  }) async {
    final current = await ensure(userId, calendar);
    rows
      ..remove(current)
      ..add(current.copyWith(writeBack: writeBack));
    _changes.add([...rows]);
  }

  @override
  Future<CalendarAccount> ensure(String userId, DeviceCalendar calendar) async {
    final found = rows.where((r) => r.externalAccountId == calendar.id);
    if (found.isNotEmpty) return found.first;
    await setEnabled(userId, calendar, enabled: true);
    return rows.last;
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

/// Records each import instead of writing occurrences.
final class FakeCalendarImport implements CalendarImport {
  final runs = <List<CalendarChoice>>[];

  @override
  Future<Result<void, AppFailure>> run({
    required String userId,
    required List<CalendarChoice> choices,
    required tz.Location location,
    required String untitled,
  }) async {
    runs.add(choices);
    return const Ok(null);
  }
}

/// What the person tapped on the write-back banner.
final class WriteBackTaps {
  var retries = 0;
  var flushes = 0;
  final resolved = <WriteBackPrefer>[];
}

/// Write-back without the database: [initial] for the banner; taps go to
/// [taps].
class IdleWriteBackController extends WriteBackController {
  IdleWriteBackController({
    this.initial = const WriteBackState(),
    WriteBackTaps? taps,
  }) : _taps = taps ?? WriteBackTaps();

  final WriteBackState initial;
  final WriteBackTaps _taps;

  @override
  WriteBackState build() => initial;

  @override
  void start() {}

  @override
  Future<void> flush() async => _taps.flushes++;

  @override
  Future<void> retry() async => _taps.retries++;

  @override
  Future<void> resolve(WriteBackPrefer prefer) async =>
      _taps.resolved.add(prefer);
}
