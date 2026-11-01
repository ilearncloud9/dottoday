import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/edge_functions.dart';
import 'package:dottoday/data/calendar/function_cloud_calendars.dart';
import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/cloud_calendar.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

// Google/Microsoft through the Edge Functions (docs/09 M7.4): answers are
// checked before they become calendars or events (06 §7), and failures map
// to typed ones without content in logs.

const _acc = '0192f000-0000-7000-8000-000000000001';

/// Answers each call with [answer] (or throws it), recording the bodies.
final class _Functions implements EdgeFunctions {
  _Functions(this.answer);

  Object? Function(String name, Map<String, Object?> body) answer;
  final calls = <(String, Map<String, Object?>)>[];

  @override
  Future<Object?> call(String name, Map<String, Object?> body) async {
    calls.add((name, body));
    return answer(name, body);
  }
}

void main() {
  late _Functions functions;
  late MemoryLogSink logs;
  var signedIn = true;

  FunctionCloudCalendars gateway() => FunctionCloudCalendars(
    functions,
    signedIn: () => signedIn,
    logger: Logger(logs, FakeClock(DateTime.utc(2026, 10, 24))),
  );

  setUp(() {
    signedIn = true;
    logs = MemoryLogSink();
    functions = _Functions((_, _) => null);
  });

  Map<String, Object?> account({String status = 'ok'}) => {
    'id': _acc,
    'provider': 'google',
    'label': 'kody@example.com',
    'status': status,
    'calendars': [
      {
        'id': '$_acc/primary',
        'name': 'Kody',
        'colorArgb': 0xFF0B8043,
        'readOnly': false,
      },
      {'id': 7, 'name': 'broken'},
    ],
  };

  test('signed out or no client: nothing is available or read', () async {
    signedIn = false;
    expect(await gateway().status(), PermissionState.notAsked);
    expect(await gateway().accounts(), isA<Err<Object?, AppFailure>>());
    expect(functions.calls, isEmpty);
    final none = FunctionCloudCalendars(
      null,
      signedIn: () => true,
      logger: Logger(logs, FakeClock(DateTime.utc(2026))),
    );
    expect(none.available, isFalse);
  });

  test(
    'accounts: calendars carry provider and account; junk skipped',
    () async {
      functions.answer = (_, _) => {
        'accounts': [account(), 'junk'],
      };
      final [
        a,
      ] = (await gateway().accounts() as Ok<List<CloudAccount>, AppFailure>)
          .value;
      expect(a.provider, CalendarProvider.google);
      expect(a.status, CloudAccountStatus.ok);
      final [cal] = a.calendars;
      expect(cal.id, '$_acc/primary');
      expect(cal.provider, CalendarProvider.google);
      expect(cal.accountName, 'kody@example.com');
      expect(functions.calls.single.$2, {'action': 'calendars'});
    },
  );

  test('one unreadable account fails the calendar list (R-08)', () async {
    functions.answer = (_, _) => {
      'accounts': [account(), account(status: 'reconnect')],
    };
    expect(await gateway().calendars(), isA<Err<Object?, AppFailure>>());
  });

  test('events: timed instants, all-day dates, malformed skipped', () async {
    functions.answer = (_, body) => {
      'events': [
        {
          'id': 'e1',
          'title': 'Review',
          'start': DateTime.utc(2026, 10, 24, 9).millisecondsSinceEpoch,
          'end': DateTime.utc(2026, 10, 24, 10).millisecondsSinceEpoch,
          'allDay': false,
          'writable': false,
          'etag': '"1"',
          'seriesId': 'r1',
        },
        {
          'id': 'h1',
          'title': 'Trip',
          'start': 0,
          'end': 0,
          'allDay': true,
          'startDate': '2026-10-24',
          'endDate': '2026-10-26',
        },
        {'id': 'bad', 'start': 'x'},
        {'id': 'bad-date', 'start': 1, 'end': 2, 'allDay': true},
      ],
    };
    final from = DateTime.utc(2026, 10, 23);
    final to = DateTime.utc(2027, 1, 22);
    final result = await gateway().events('$_acc/primary', from, to);
    final list = (result as Ok<List<ExternalEvent>, AppFailure>).value;
    expect(list, hasLength(2));
    expect(list[0].editable, isFalse);
    expect(list[0].seriesId, 'r1');
    expect(list[1].seriesId, isNull);
    expect(list[0].startUtc, DateTime.utc(2026, 10, 24, 9));
    expect(list[1].allDay, isTrue);
    expect(list[1].startUtc, DateTime.utc(2026, 10, 24));
    expect(list[1].endUtc, DateTime.utc(2026, 10, 26));
    expect(functions.calls.single.$2['from'], from.millisecondsSinceEpoch);
  });

  test('read: the etag is the version; write sends it back', () async {
    functions.answer = (_, body) => body['action'] == 'event'
        ? {
            'event': {
              'id': 'e1',
              'title': 'Review',
              'start': 1000,
              'end': 61000,
              'allDay': false,
              'writable': true,
              'etag': '"7"',
            },
          }
        : {'result': 'changed'};
    const at = EventAddress(calendarId: '$_acc/primary', eventId: 'e1');
    final remote =
        (await gateway().read(at) as Ok<RemoteEvent?, AppFailure>).value!;
    expect(remote.version, '"7"');
    expect(remote.writable, isTrue);
    final outcome = await gateway().write(
      at,
      EventPatch(
        startUtc: DateTime.utc(2026, 10, 24, 9),
        endUtc: DateTime.utc(2026, 10, 24, 10),
      ),
      expectedVersion: remote.version,
    );
    expect(outcome, WriteBackOutcome.changed);
    final sent = functions.calls.last.$2;
    expect(sent['etag'], '"7"');
    expect(sent.containsKey('title'), isFalse, reason: 'not renamed here');
  });

  test('series: update_series and delete_series with the series id', () async {
    functions.answer = (_, body) => {
      'result': body['action'] == 'delete_series' ? 'gone' : 'not_writable',
    };
    const at = EventAddress(calendarId: '$_acc/primary', eventId: 'r1');
    final edit = await gateway().writeSeries(
      at,
      const SeriesPatch(
        shift: Duration(minutes: -30),
        duration: Duration(minutes: 45),
      ),
    );
    expect(edit, WriteBackOutcome.notWritable);
    expect(functions.calls.last.$2, {
      'action': 'update_series',
      'calendarId': '$_acc/primary',
      'seriesId': 'r1',
      'shiftMs': -1800000,
      'durationMs': 2700000,
    });
    expect(await gateway().deleteSeries(at), WriteBackOutcome.gone);
    expect(functions.calls.last.$2['action'], 'delete_series');
  });

  test('gone events read as null', () async {
    functions.answer = (_, _) => {'event': null};
    const at = EventAddress(calendarId: '$_acc/primary', eventId: 'e1');
    expect((await gateway().read(at) as Ok).value, isNull);
  });

  test('failures are typed; writes that fail are kept for a retry', () async {
    functions.answer = (_, _) =>
        throw const EdgeFunctionError(409, 'reconnect');
    expect((await gateway().accounts() as Err).failure, isA<AuthFailure>());
    functions.answer = (_, _) => throw const SocketException('offline');
    expect(
      (await gateway().accounts() as Err).failure,
      isA<NetworkFailure>().having(
        (f) => f.kind,
        'kind',
        NetworkFailureKind.offline,
      ),
    );
    functions.answer = (_, _) => throw const EdgeFunctionError(502, 'provider');
    final outcome = await gateway().write(
      const EventAddress(calendarId: 'c', eventId: 'e'),
      EventPatch(
        startUtc: DateTime.utc(2026),
        endUtc: DateTime.utc(2026, 1, 2),
      ),
      expectedVersion: '"1"',
    );
    expect(outcome, WriteBackOutcome.failed);
    expect(logs.records.map((r) => r.event), contains('calendar.cloud_failed'));
  });

  test('connect: only an https sign-in page is opened', () async {
    functions.answer = (_, _) => {'url': 'https://accounts.google.com/o?x=1'};
    final url = await gateway().connectUrl(
      CalendarProvider.microsoft,
      'dottoday://settings/calendars',
    );
    expect((url as Ok<Uri, AppFailure>).value.host, 'accounts.google.com');
    expect(functions.calls.single.$1, 'calendar-oauth');
    expect(functions.calls.single.$2['provider'], 'microsoft');
    functions.answer = (_, _) => {'url': 'javascript:alert(1)'};
    expect(
      await gateway().connectUrl(CalendarProvider.google, 'x'),
      isA<Err<Uri, AppFailure>>(),
    );
  });
}
