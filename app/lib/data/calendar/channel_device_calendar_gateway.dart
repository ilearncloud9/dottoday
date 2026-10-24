import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mac device calendars over `dottoday/calendars`, the EventKit bridge in
/// `macos/Runner/CalendarBridge.swift` (docs/09 M7.1b, R-02, R-13):
/// `device_calendar` has no macOS implementation.
///
/// Unlike the plugin, EventKit reports "not asked" itself, so nothing is
/// kept in `local_meta` here. All-day events arrive as calendar dates
/// (`yyyy-MM-dd`, read natively in the device's calendar), so no zone
/// guessing happens on this side. Write-back (M7.3) changes one event's
/// start, end and title in place.
final class ChannelDeviceCalendarGateway implements DeviceCalendarGateway {
  ChannelDeviceCalendarGateway(
    this._logger, {
    MethodChannel channel = calendarChannel,
    Future<bool> Function(Uri) open = launchUrl,
  }) : _channel = channel,
       _open = open;

  static const calendarChannel = MethodChannel('dottoday/calendars');

  /// System Settings › Privacy & Security › Calendars.
  static final settingsUrl = Uri.parse(
    'x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars',
  );

  static final _date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final Logger _logger;
  final MethodChannel _channel;
  final Future<bool> Function(Uri) _open;

  @override
  bool get available => true;

  @override
  Future<PermissionState> status() => _permission('status');

  @override
  Future<PermissionState> request() => _permission('request');

  @override
  Future<bool> openSettings() => _open(settingsUrl);

  @override
  Future<Result<List<DeviceCalendar>, AppFailure>> calendars() async {
    if (await status() != PermissionState.granted) {
      return const Err(PermissionFailure(AppPermission.calendar));
    }
    final rows = await _list(_Read.calendars, 'calendars');
    if (rows == null) return const Err(UnexpectedFailure());
    return Ok([for (final r in rows) ?_calendar(r)]);
  }

  @override
  Future<Result<List<ExternalEvent>, AppFailure>> events(
    String calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    if (await status() != PermissionState.granted) {
      return const Err(PermissionFailure(AppPermission.calendar));
    }
    final rows = await _list(_Read.events, 'events', {
      'calendarId': calendarId,
      'fromMs': fromUtc.millisecondsSinceEpoch,
      'toMs': toUtc.millisecondsSinceEpoch,
    });
    if (rows == null) return const Err(UnexpectedFailure());
    return Ok([for (final r in rows) ?_event(calendarId, r)]);
  }

  @override
  Future<Result<ExternalEvent?, AppFailure>> event(
    String calendarId,
    String eventId,
  ) async {
    if (await status() != PermissionState.granted) {
      return const Err(PermissionFailure(AppPermission.calendar));
    }
    try {
      final row = await _channel.invokeMapMethod<Object?, Object?>('event', {
        'calendarId': calendarId,
        'eventId': eventId,
      });
      return Ok(row == null ? null : _event(calendarId, row));
    } on PlatformException catch (e, s) {
      _logger.warn(
        'calendar.read_failed',
        fields: {'what': _Read.event},
        error: e,
        stackTrace: s,
      );
      return const Err(UnexpectedFailure());
    }
  }

  /// The bridge answers with an [EventWriteResult] name; it changes only
  /// start, end and title, on that one event (docs/09 M7.3).
  @override
  Future<EventWriteResult> updateEvent(EventUpdate update) async {
    try {
      final raw = await _channel.invokeMethod<String>('update', {
        'calendarId': update.calendarId,
        'eventId': update.eventId,
        'startMs': update.startUtc.millisecondsSinceEpoch,
        'endMs': update.endUtc.millisecondsSinceEpoch,
        'title': ?update.title,
      });
      return EventWriteResult.values.asNameMap()[raw] ??
          EventWriteResult.failed;
    } on PlatformException catch (e, s) {
      _logger.warn('calendar.write_failed', error: e, stackTrace: s);
      return EventWriteResult.failed;
    } on MissingPluginException catch (e, s) {
      _logger.warn('calendar.write_failed', error: e, stackTrace: s);
      return EventWriteResult.failed;
    }
  }

  Future<PermissionState> _permission(String method) async {
    try {
      final raw = await _channel.invokeMethod<String>(method);
      return PermissionState.values.asNameMap()[raw] ??
          PermissionState.notAsked;
    } on PlatformException catch (e, s) {
      _logger.warn('calendar.permission_failed', error: e, stackTrace: s);
      return PermissionState.denied;
    } on MissingPluginException catch (e, s) {
      _logger.warn('calendar.permission_failed', error: e, stackTrace: s);
      return PermissionState.denied;
    }
  }

  /// The rows [method] returns, or null (logged by kind, never content).
  Future<List<Map<Object?, Object?>>?> _list(
    _Read what,
    String method, [
    Map<String, Object>? args,
  ]) async {
    try {
      final rows = await _channel.invokeListMethod<Object?>(method, args);
      return [...?rows?.whereType<Map<Object?, Object?>>()];
    } on PlatformException catch (e, s) {
      // The error carries only the bridge's code (no event content).
      _logger.warn(
        'calendar.read_failed',
        fields: {'what': what},
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  static DeviceCalendar? _calendar(Map<Object?, Object?> r) {
    if (r['id'] case final String id) {
      return DeviceCalendar(
        id: id,
        name: r['name'] as String? ?? '',
        accountName: r['accountName'] as String?,
        colorArgb: r['colorArgb'] as int?,
        readOnly: r['readOnly'] as bool? ?? false,
      );
    }
    return null;
  }

  /// A timed event keeps its instants; an all-day one its dates (see
  /// [ExternalEvent]): EventKit gives the last day as the end, so the
  /// exclusive end is the day after.
  static ExternalEvent? _event(String calendarId, Map<Object?, Object?> r) {
    final id = r['id'];
    if (id is! String) return null;
    final allDay = r['allDay'] == true;
    final (start, end) = allDay
        ? (_day(r['startDay'], 0), _day(r['endDay'], 1))
        : (_instant(r['startMs']), _instant(r['endMs']));
    if (start == null || end == null) return null;
    return ExternalEvent(
      id: id,
      calendarId: calendarId,
      title: r['title'] as String? ?? '',
      startUtc: start,
      endUtc: end,
      allDay: allDay,
      location: r['location'] as String?,
      description: r['notes'] as String?,
      url: _link(r['url']),
      repeating: r['repeating'] == true,
    );
  }

  static DateTime? _instant(Object? ms) =>
      ms is int ? DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true) : null;

  /// `yyyy-MM-dd` plus [days], as a UTC midnight.
  static DateTime? _day(Object? raw, int days) {
    final match = raw is String ? _date.firstMatch(raw) : null;
    if (match == null) return null;
    final [y, m, d] = [for (var i = 1; i <= 3; i++) int.parse(match[i]!)];
    return DateTime.utc(y, m, d + days);
  }

  /// Only http(s) links are kept, so a tap can only open a browser (06 §7).
  static Uri? _link(Object? raw) {
    final link = raw is String ? Uri.tryParse(raw) : null;
    final web =
        link != null && (link.isScheme('https') || link.isScheme('http'));
    return web ? link : null;
  }
}

/// What failed to read, as a loggable enum (no raw strings in logs).
enum _Read { calendars, events, event }
