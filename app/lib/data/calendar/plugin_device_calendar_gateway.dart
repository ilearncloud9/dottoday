import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

/// Device calendars through `device_calendar` (docs/04 §7): EventKit on
/// iOS, CalendarContract on Android (macOS has its own EventKit bridge, M7.1b).
///
/// The plugin only says yes or no, so whether Dottoday has asked on this
/// device is kept in `local_meta`, as for notifications (M5.1): no + asked
/// = denied (explain + a way to Settings, docs/03 §3.8).
final class PluginDeviceCalendarGateway implements DeviceCalendarGateway {
  PluginDeviceCalendarGateway(
    this._db,
    this._logger, {
    required Future<String> Function() deviceZone,
    dc.DeviceCalendarPlugin? plugin,
  }) : _deviceZone = deviceZone,
       // The app initialises time zones itself (bootstrap); the plugin's
       // own init would only repeat it.
       _plugin = plugin ?? dc.DeviceCalendarPlugin(shouldInitTimezone: false);

  final AppDatabase _db;
  final Logger _logger;

  /// The device's IANA zone: where an iOS all-day event's dates are read.
  final Future<String> Function() _deviceZone;
  final dc.DeviceCalendarPlugin _plugin;

  static const _askedKey = 'calendar_permission_asked';

  @override
  bool get available => true;

  @override
  Future<PermissionState> status() async {
    if (await _granted()) return PermissionState.granted;
    return await _asked() ? PermissionState.denied : PermissionState.notAsked;
  }

  @override
  Future<PermissionState> request() async {
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: _askedKey, value: 'true'),
        );
    try {
      await _plugin.requestPermissions();
    } on PlatformException catch (e, s) {
      _logger.warn('calendar.permission_failed', error: e, stackTrace: s);
    }
    return status();
  }

  @override
  Future<bool> openSettings() async {
    // Android has no public URL for an app's settings page; the UI then
    // says where to go.
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    return launchUrl(Uri.parse('app-settings:'));
  }

  @override
  Future<Result<List<DeviceCalendar>, AppFailure>> calendars() async {
    if (!await _granted()) {
      return const Err(PermissionFailure(AppPermission.calendar));
    }
    final result = await _plugin.retrieveCalendars();
    final data = result.data;
    if (result.hasErrors || data == null) {
      return _failed(_Read.calendars, result);
    }
    return Ok([
      for (final c in data)
        if (c.id case final id?)
          DeviceCalendar(
            id: id,
            name: c.name ?? '',
            accountName: c.accountName,
            colorArgb: c.color,
            readOnly: c.isReadOnly ?? false,
          ),
    ]);
  }

  @override
  Future<Result<List<ExternalEvent>, AppFailure>> events(
    String calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    if (!await _granted()) {
      return const Err(PermissionFailure(AppPermission.calendar));
    }
    final result = await _plugin.retrieveEvents(
      calendarId,
      dc.RetrieveEventsParams(startDate: fromUtc, endDate: toUtc),
    );
    final data = result.data;
    if (result.hasErrors || data == null) return _failed(_Read.events, result);
    final zone = await _allDayZone();
    return Ok([for (final e in data) ?_event(calendarId, e, zone)]);
  }

  @override
  Future<Result<ExternalEvent?, AppFailure>> event(
    String calendarId,
    String eventId,
  ) async {
    if (!await _granted()) {
      return const Err(PermissionFailure(AppPermission.calendar));
    }
    final found = await _raw(calendarId, eventId);
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value == null) return const Ok(null);
        return Ok(_event(calendarId, value, await _allDayZone()));
    }
  }

  /// Read, change and save the whole event: the plugin writes every field
  /// it is given, so the rest (notes, alarms, attendees) goes back as it
  /// was read. Only timed, non-repeating events (docs/09 M7.3).
  @override
  Future<EventWriteResult> updateEvent(EventUpdate update) async {
    if (!await _granted()) return EventWriteResult.failed;
    final dc.Event? e;
    switch (await _raw(update.calendarId, update.eventId)) {
      case Err():
        return EventWriteResult.failed;
      case Ok(:final value):
        e = value;
    }
    if (e == null) return EventWriteResult.gone;
    final (start, end) = (e.start, e.end);
    if (e.recurrenceRule != null ||
        (e.allDay ?? false) ||
        start == null ||
        end == null) {
      return EventWriteResult.notWritable;
    }
    e
      ..start = tz.TZDateTime.from(update.startUtc, start.location)
      ..end = tz.TZDateTime.from(update.endUtc, end.location)
      ..title = update.title ?? e.title;
    final saved = await _plugin.createOrUpdateEvent(e);
    if (saved != null && saved.isSuccess) return EventWriteResult.written;
    final errors = saved?.errors ?? const <dc.ResultError>[];
    _logger.warn(
      'calendar.write_failed',
      fields: {'code': errors.isEmpty ? 0 : errors.first.errorCode},
    );
    return EventWriteResult.failed;
  }

  /// The plugin's event [eventId], or null when the calendar no longer
  /// has it.
  Future<Result<dc.Event?, AppFailure>> _raw(
    String calendarId,
    String eventId,
  ) async {
    // The Android plugin puts ids into its query unquoted: only the
    // numeric ids CalendarContract hands out may reach it (06 §7).
    if (defaultTargetPlatform == TargetPlatform.android &&
        !_numeric.hasMatch(eventId)) {
      return const Ok(null);
    }
    final result = await _plugin.retrieveEvents(
      calendarId,
      dc.RetrieveEventsParams(eventIds: [eventId]),
    );
    final data = result.data;
    if (result.hasErrors || data == null) return _failed(_Read.event, result);
    return Ok(data.where((e) => e.eventId == eventId).firstOrNull);
  }

  static final _numeric = RegExp(r'^\d+$');

  /// Where an all-day event's dates are read. EventKit stores them as the
  /// device's local midnights with no zone (the plugin then reads them as
  /// UTC); the plugin hands Android's back as UTC midnights.
  Future<tz.Location> _allDayZone() async =>
      defaultTargetPlatform == TargetPlatform.iOS
      ? tz.getLocation(await _deviceZone())
      : tz.UTC;

  /// An all-day event keeps its dates, not its instants (see
  /// [ExternalEvent]). Both platforms give the last day as the end, so the
  /// exclusive end is the day after.
  static ExternalEvent? _event(
    String calendarId,
    dc.Event e,
    tz.Location zone,
  ) {
    final (id, start, end) = (e.eventId, e.start, e.end);
    if (id == null || start == null || end == null) return null;
    final allDay = e.allDay ?? false;
    return ExternalEvent(
      id: id,
      calendarId: calendarId,
      title: e.title ?? '',
      startUtc: allDay ? _dateIn(start, zone, 0) : start.toUtc(),
      endUtc: allDay ? _dateIn(end, zone, 1) : end.toUtc(),
      allDay: allDay,
      location: e.location,
      description: e.description,
      url: _link(e.url),
      repeating: e.recurrenceRule != null,
      // The plugin gives every instance of a series the same event id.
      seriesId: e.recurrenceRule != null ? id : null,
    );
  }

  /// The event's web link, or null. The plugin wraps it in a `data:` URI;
  /// only http(s) links are kept, so a tap can only open a browser (06 §7).
  static Uri? _link(Uri? wrapped) {
    if (wrapped == null) return null;
    final raw = wrapped.scheme == 'data'
        ? wrapped.data?.contentAsString()
        : wrapped.toString();
    final link = Uri.tryParse(raw ?? '');
    final web =
        link != null && (link.isScheme('https') || link.isScheme('http'));
    return web ? link : null;
  }

  /// The calendar date of [t] in [zone], plus [days], as a UTC midnight.
  static DateTime _dateIn(DateTime t, tz.Location zone, int days) {
    final local = tz.TZDateTime.from(t, zone);
    return DateTime.utc(local.year, local.month, local.day + days);
  }

  Err<T, AppFailure> _failed<T>(_Read what, dc.Result<Object?> result) {
    _logger.warn(
      'calendar.read_failed',
      fields: {
        'what': what,
        'code': result.errors.isEmpty ? 0 : result.errors.first.errorCode,
      },
    );
    return const Err(UnexpectedFailure());
  }

  Future<bool> _granted() async {
    try {
      return (await _plugin.hasPermissions()).data ?? false;
    } on PlatformException catch (e, s) {
      _logger.warn('calendar.permission_failed', error: e, stackTrace: s);
      return false;
    }
  }

  Future<bool> _asked() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_askedKey))).getSingleOrNull();
    return row != null;
  }
}

/// What failed to read, as a loggable enum (no raw strings in logs).
enum _Read { calendars, events, event }
