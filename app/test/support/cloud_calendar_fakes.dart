import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/cloud_calendar.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

/// Google/Microsoft without the backend (docs/09 M7.4): [list] are the
/// connections; connecting returns a sign-in URL, disconnecting records.
final class FakeCloudCalendars implements CloudCalendars {
  FakeCloudCalendars({this.list = const []});

  List<CloudAccount> list;
  final connected = <CalendarProvider>[];
  final disconnected = <String>[];

  @override
  bool get available => true;

  @override
  Future<PermissionState> status() async => PermissionState.granted;

  @override
  Future<Result<List<CloudAccount>, AppFailure>> accounts() async => Ok(list);

  @override
  Future<Result<List<DeviceCalendar>, AppFailure>> calendars() async =>
      Ok([for (final a in list) ...a.calendars]);

  @override
  Future<Result<List<ExternalEvent>, AppFailure>> events(
    String calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  ) async => const Ok([]);

  @override
  Future<Result<RemoteEvent?, AppFailure>> read(EventAddress at) async =>
      const Ok(null);

  @override
  Future<WriteBackOutcome> write(
    EventAddress at,
    EventPatch patch, {
    required String expectedVersion,
  }) async => WriteBackOutcome.written;

  /// Whole-series edits and deletes sent (docs/02 F5.7), in order.
  final seriesPatches = <(EventAddress, SeriesPatch)>[];
  final seriesDeletes = <EventAddress>[];

  @override
  Future<WriteBackOutcome> writeSeries(
    EventAddress at,
    SeriesPatch patch,
  ) async {
    seriesPatches.add((at, patch));
    return WriteBackOutcome.written;
  }

  @override
  Future<WriteBackOutcome> deleteSeries(EventAddress at) async {
    seriesDeletes.add(at);
    return WriteBackOutcome.written;
  }

  @override
  Future<Result<Uri, AppFailure>> connectUrl(
    CalendarProvider provider,
    String returnTo,
  ) async {
    connected.add(provider);
    return Ok(Uri.parse('https://accounts.example.com/${provider.wire}'));
  }

  @override
  Future<Result<void, AppFailure>> disconnect(String accountId) async {
    disconnected.add(accountId);
    list = [
      for (final a in list)
        if (a.id != accountId) a,
    ];
    return const Ok(null);
  }
}

/// Kody's Google account: a writable "Kody" and a read-only "Holidays in
/// Germany".
const sampleCloudAccount = CloudAccount(
  id: '0192f000-0000-7000-8000-000000000001',
  provider: CalendarProvider.google,
  label: 'kody@gmail.com',
  status: CloudAccountStatus.ok,
  calendars: [
    DeviceCalendar(
      id: '0192f000-0000-7000-8000-000000000001/primary',
      name: 'Kody',
      accountName: 'kody@gmail.com',
      colorArgb: 0xFF0B8043,
      provider: CalendarProvider.google,
    ),
    DeviceCalendar(
      id: '0192f000-0000-7000-8000-000000000001/holidays',
      name: 'Holidays in Germany',
      accountName: 'kody@gmail.com',
      colorArgb: 0xFF8E8E93,
      readOnly: true,
      provider: CalendarProvider.google,
    ),
  ],
);
