import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/edge_functions.dart';
import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/cloud_calendar.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

/// [CloudCalendars] over the `calendar-oauth` and `calendar-sync` Edge
/// Functions (docs/09 M7.4, ADR-0011). Every answer is checked before it
/// becomes a calendar or an event (06 §7); a malformed event is skipped.
/// Logs carry failure codes only, never titles.
final class FunctionCloudCalendars implements CloudCalendars {
  FunctionCloudCalendars(
    this._functions, {
    required bool Function() signedIn,
    required Logger logger,
  }) : _signedIn = signedIn,
       _logger = logger;

  /// Null without a Supabase client: nothing is available.
  final EdgeFunctions? _functions;
  final bool Function() _signedIn;
  final Logger _logger;

  static const _sync = 'calendar-sync';
  static const _oauth = 'calendar-oauth';

  @override
  bool get available => _functions != null;

  /// Connected accounts belong to the Dottoday account: readable once
  /// signed in, nothing to ask the OS.
  @override
  Future<PermissionState> status() async => available && _signedIn()
      ? PermissionState.granted
      : PermissionState.notAsked;

  @override
  Future<Result<List<CloudAccount>, AppFailure>> accounts() =>
      _call(_sync, {'action': 'calendars'}, (json) {
        final list = _map(json)['accounts'];
        return [
          if (list is List)
            for (final a in list) ?cloudAccountFromJson(a),
        ];
      });

  /// Every calendar of every account; an account that can't be read
  /// fails the whole list, so the import leaves everything as it is
  /// instead of removing that account's events (R-08).
  @override
  Future<Result<List<DeviceCalendar>, AppFailure>> calendars() async {
    switch (await accounts()) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value.any((a) => a.status != CloudAccountStatus.ok)) {
          return const Err(NetworkFailure(NetworkFailureKind.server));
        }
        return Ok([for (final a in value) ...a.calendars]);
    }
  }

  @override
  Future<Result<List<ExternalEvent>, AppFailure>> events(
    String calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  ) => _call(
    _sync,
    {
      'action': 'events',
      'calendarId': calendarId,
      'from': fromUtc.millisecondsSinceEpoch,
      'to': toUtc.millisecondsSinceEpoch,
    },
    (json) {
      final list = _map(json)['events'];
      return [
        if (list is List)
          for (final e in list) ?cloudEventFromJson(e, calendarId)?.$1,
      ];
    },
  );

  @override
  Future<Result<RemoteEvent?, AppFailure>> read(EventAddress at) => _call(
    _sync,
    {'action': 'event', 'calendarId': at.calendarId, 'eventId': at.eventId},
    (json) {
      final found = cloudEventFromJson(_map(json)['event'], at.calendarId);
      if (found == null) return null;
      final (e, etag) = found;
      return RemoteEvent(
        startUtc: e.startUtc,
        endUtc: e.endUtc,
        title: e.title,
        version: etag,
        writable: !e.allDay && e.editable,
      );
    },
  );

  /// Conditional on the etag read (If-Match at the provider): a change
  /// made there since is `changed`, never overwritten.
  @override
  Future<WriteBackOutcome> write(
    EventAddress at,
    EventPatch patch, {
    required String expectedVersion,
  }) async {
    final result = await _call(_sync, {
      'action': 'update',
      'calendarId': at.calendarId,
      'eventId': at.eventId,
      'start': patch.startUtc.millisecondsSinceEpoch,
      'end': patch.endUtc.millisecondsSinceEpoch,
      'title': ?patch.title,
      'etag': expectedVersion,
    }, (json) => _map(json)['result']);
    return switch (result) {
      Ok(value: 'written') => WriteBackOutcome.written,
      Ok(value: 'changed') => WriteBackOutcome.changed,
      Ok(value: 'gone') => WriteBackOutcome.gone,
      Ok(value: 'not_writable') => WriteBackOutcome.notWritable,
      _ => WriteBackOutcome.failed,
    };
  }

  @override
  Future<Result<Uri, AppFailure>> connectUrl(
    CalendarProvider provider,
    String returnTo,
  ) => _call(_oauth, {'provider': provider.wire, 'returnTo': returnTo}, (json) {
    final url = Uri.tryParse('${_map(json)['url']}');
    // Only ever the provider's own https sign-in page.
    if (url == null || url.scheme != 'https') throw const FormatException();
    return url;
  });

  @override
  Future<Result<void, AppFailure>> disconnect(String accountId) =>
      _call(_sync, {'action': 'disconnect', 'accountId': accountId}, (_) {});

  Future<Result<T, AppFailure>> _call<T>(
    String name,
    Map<String, Object?> body,
    T Function(Object? json) parse,
  ) async {
    final functions = _functions;
    if (functions == null || !_signedIn()) return const Err(AuthFailure());
    try {
      return Ok(parse(await functions.call(name, body)));
    } on Exception catch (e) {
      final failure = _failureOf(e);
      _logger.warn('calendar.cloud_failed', error: failure);
      return Err(failure);
    }
  }

  static AppFailure _failureOf(Exception e) => switch (e) {
    EdgeFunctionError(status: 401 || 409) => const AuthFailure(),
    EdgeFunctionError() ||
    FormatException() => const NetworkFailure(NetworkFailureKind.server),
    _ => const NetworkFailure(NetworkFailureKind.offline),
  };

  static Map<String, Object?> _map(Object? json) =>
      json is Map<String, Object?> ? json : throw const FormatException();
}

/// One account of the `calendars` answer, or null when malformed.
CloudAccount? cloudAccountFromJson(Object? json) {
  if (json is! Map<String, Object?>) return null;
  final id = json['id'];
  final label = json['label'];
  final provider = switch (json['provider']) {
    'google' => CalendarProvider.google,
    'microsoft' => CalendarProvider.microsoft,
    _ => null,
  };
  if (id is! String || label is! String || provider == null) return null;
  final status = switch (json['status']) {
    'ok' => CloudAccountStatus.ok,
    'reconnect' => CloudAccountStatus.reconnect,
    _ => CloudAccountStatus.failed,
  };
  final calendars = json['calendars'];
  return CloudAccount(
    id: id,
    provider: provider,
    label: label,
    status: status,
    calendars: [
      if (calendars is List)
        for (final c in calendars) ?_calendar(c, provider, label),
    ],
  );
}

DeviceCalendar? _calendar(
  Object? json,
  CalendarProvider provider,
  String label,
) {
  if (json is! Map<String, Object?>) return null;
  final id = json['id'];
  final name = json['name'];
  final color = json['colorArgb'];
  if (id is! String || id.isEmpty || name is! String) return null;
  return DeviceCalendar(
    id: id,
    name: name,
    accountName: label,
    colorArgb: color is int ? color : null,
    readOnly: json['readOnly'] != false,
    provider: provider,
  );
}

/// One event of a `calendar-sync` answer with its etag, or null when
/// malformed. All-day events cross as dates (`yyyy-MM-dd`, end
/// exclusive), placed on those dates in any zone like the device ones.
(ExternalEvent, String)? cloudEventFromJson(Object? json, String calendarId) {
  if (json is! Map<String, Object?>) return null;
  final id = json['id'];
  final start = json['start'];
  final end = json['end'];
  final allDay = json['allDay'] == true;
  if (id is! String || id.isEmpty || start is! int || end is! int) return null;
  final startUtc = allDay
      ? _date(json['startDate'])
      : DateTime.fromMillisecondsSinceEpoch(start, isUtc: true);
  final endUtc = allDay
      ? _date(json['endDate'])
      : DateTime.fromMillisecondsSinceEpoch(end, isUtc: true);
  if (startUtc == null || endUtc == null || endUtc.isBefore(startUtc)) {
    return null;
  }
  final title = json['title'];
  final location = json['location'];
  final description = json['description'];
  final etag = json['etag'];
  return (
    ExternalEvent(
      id: id,
      calendarId: calendarId,
      title: title is String ? title : '',
      startUtc: startUtc,
      endUtc: endUtc,
      allDay: allDay,
      location: location is String ? location : null,
      description: description is String ? description : null,
      editable: json['writable'] == true,
    ),
    etag is String ? etag : '',
  );
}

final _isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

DateTime? _date(Object? value) {
  final m = value is String ? _isoDate.firstMatch(value) : null;
  if (m == null) return null;
  return DateTime.utc(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}
