import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/plugin_device_calendar_gateway.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

// The device_calendar bridge (docs/09 M7.1): permission states, the list,
// and events, over the plugin's method channel.

const _channel = MethodChannel('plugins.builttoroam.com/device_calendar');

/// Berlin local midnight of [day] (October: UTC+2).
int _berlinMidnight(int day) =>
    DateTime.utc(2026, 10, day - 1, 22).millisecondsSinceEpoch;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  late AppDatabase db;
  late PluginDeviceCalendarGateway gateway;
  late bool granted;
  late bool answer;
  late List<MethodCall> calls;
  Object? Function(MethodCall call)? reply;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    gateway = PluginDeviceCalendarGateway(
      db,
      Logger(MemoryLogSink(), FakeClock(DateTime.utc(2026, 10, 21))),
      deviceZone: () async => 'Europe/Berlin',
    );
    granted = false;
    answer = true;
    calls = [];
    reply = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'hasPermissions' => granted,
            'requestPermissions' => granted = answer,
            _ => reply?.call(call),
          };
        });
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    await db.close();
  });

  test('never asked → not asked; asked and refused → denied', () async {
    expect(await gateway.status(), PermissionState.notAsked);
    answer = false;
    expect(await gateway.request(), PermissionState.denied);
    expect(await gateway.status(), PermissionState.denied);
  });

  test('allowed → granted', () async {
    expect(await gateway.request(), PermissionState.granted);
    expect(await gateway.status(), PermissionState.granted);
  });

  test('without the permission nothing is read', () async {
    final result = await gateway.calendars();
    expect(
      result,
      isA<Err<List<DeviceCalendar>, AppFailure>>().having(
        (e) => e.failure.code,
        'code',
        'permission.calendar',
      ),
    );
    expect(calls.map((c) => c.method), isNot(contains('retrieveCalendars')));
  });

  test('calendars: id, name, account, colour, read-only', () async {
    granted = true;
    reply = (_) => jsonEncode([
      {
        'id': 'home',
        'name': 'Home',
        'accountName': 'iCloud',
        'color': 0xFFFF3B30,
        'isReadOnly': false,
      },
      {'id': 'holidays', 'name': 'Holidays', 'isReadOnly': true},
      {'name': 'no id: skipped'},
    ]);
    final result = await gateway.calendars();
    expect((result as Ok<List<DeviceCalendar>, AppFailure>).value, const [
      DeviceCalendar(
        id: 'home',
        name: 'Home',
        accountName: 'iCloud',
        colorArgb: 0xFFFF3B30,
      ),
      DeviceCalendar(id: 'holidays', name: 'Holidays', readOnly: true),
    ]);
  });

  test('a plugin error is a typed failure', () async {
    granted = true;
    reply = (_) => throw PlatformException(code: '500', message: 'boom');
    final result = await gateway.calendars();
    expect(
      result,
      isA<Err<List<DeviceCalendar>, AppFailure>>().having(
        (e) => e.failure.code,
        'code',
        'unexpected',
      ),
    );
  });

  test('iOS all-day events keep their dates in the device zone', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    granted = true;
    reply = (_) => jsonEncode([
      {
        'eventId': 'conf',
        'eventTitle': 'Conference',
        // Fri 23 – Sun 25 Oct, Berlin; EventKit ends at 23:59:59 on Sun.
        'eventStartDate': _berlinMidnight(23),
        'eventEndDate': _berlinMidnight(26) - 1000,
        'eventAllDay': true,
      },
      {
        'eventId': 'call',
        'eventTitle': 'Call',
        'eventStartDate': DateTime.utc(2026, 10, 23, 7).millisecondsSinceEpoch,
        'eventEndDate': DateTime.utc(2026, 10, 23, 8).millisecondsSinceEpoch,
        'eventStartTimeZone': 'Europe/Berlin',
        'eventAllDay': false,
        'eventLocation': 'Room 4',
        'eventURL': 'https://example.com/call',
      },
      {
        'eventId': 'odd',
        'eventTitle': 'Odd link',
        'eventStartDate': DateTime.utc(2026, 10, 23, 9).millisecondsSinceEpoch,
        'eventEndDate': DateTime.utc(2026, 10, 23, 10).millisecondsSinceEpoch,
        'eventURL': 'javascript:alert(1)',
      },
    ]);
    final result = await gateway.events(
      'work',
      DateTime.utc(2026, 10, 19),
      DateTime.utc(2026, 10, 26),
    );
    final [conf, call, odd] =
        (result as Ok<List<ExternalEvent>, AppFailure>).value;
    expect(conf.allDay, isTrue);
    expect(conf.startUtc, DateTime.utc(2026, 10, 23));
    expect(conf.endUtc, DateTime.utc(2026, 10, 26));
    expect(call.startUtc, DateTime.utc(2026, 10, 23, 7));
    expect(call.endUtc, DateTime.utc(2026, 10, 23, 8));
    expect(call.calendarId, 'work');
    expect(call.location, 'Room 4');
    expect(call.url, Uri.parse('https://example.com/call'));
    // Only web links are kept (06 §7).
    expect(odd.url, isNull);
  });

  group('write-back (M7.3)', () {
    final seven = DateTime.utc(2026, 10, 23, 7);
    Map<String, Object?> call({Map<String, Object?>? recurrence}) => {
      'calendarId': 'work',
      'eventId': '42',
      'eventTitle': 'Call',
      'eventDescription': 'Agenda',
      'eventStartDate': seven.millisecondsSinceEpoch,
      'eventEndDate': seven
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch,
      'eventStartTimeZone': 'Europe/Berlin',
      'eventEndTimeZone': 'Europe/Berlin',
      'eventAllDay': false,
      'reminders': [
        {'minutes': 10},
      ],
      'recurrenceRule': ?recurrence,
    };

    test('reads one event and says whether it repeats', () async {
      granted = true;
      reply = (c) => jsonEncode([
        call(recurrence: {'recurrenceFrequency': 1}),
      ]);
      final result = await gateway.event('work', '42');
      expect(calls.last.arguments, containsPair('eventIds', ['42']));
      final event = (result as Ok<ExternalEvent?, AppFailure>).value!;
      expect(event.repeating, isTrue);
      expect(event.startUtc, seven);
    });

    test('changes start, end and title; the rest goes back as read', () async {
      granted = true;
      Map<Object?, Object?>? saved;
      reply = (c) {
        if (c.method != 'createOrUpdateEvent') return jsonEncode([call()]);
        saved = c.arguments as Map<Object?, Object?>;
        return '42';
      };
      final later = seven.add(const Duration(hours: 2));
      final result = await gateway.updateEvent(
        EventUpdate(
          calendarId: 'work',
          eventId: '42',
          startUtc: later,
          endUtc: later.add(const Duration(minutes: 30)),
          title: 'Call + demo',
        ),
      );
      expect(result, EventWriteResult.written);
      expect(saved!['eventId'], '42');
      expect(saved!['eventStartDate'], later.millisecondsSinceEpoch);
      expect(
        saved!['eventEndDate'],
        later.add(const Duration(minutes: 30)).millisecondsSinceEpoch,
      );
      expect(saved!['eventTitle'], 'Call + demo');
      expect(saved!['eventDescription'], 'Agenda');
      expect(saved!['eventStartTimeZone'], 'Europe/Berlin');
      expect(saved!['reminders'], hasLength(1));
    });

    test('a repeating event is refused; nothing is saved', () async {
      granted = true;
      reply = (_) => jsonEncode([
        call(recurrence: {'recurrenceFrequency': 1}),
      ]);
      final result = await gateway.updateEvent(
        EventUpdate(
          calendarId: 'work',
          eventId: '42',
          startUtc: seven,
          endUtc: seven.add(const Duration(hours: 1)),
        ),
      );
      expect(result, EventWriteResult.notWritable);
      expect(
        calls.map((c) => c.method),
        isNot(contains('createOrUpdateEvent')),
      );
    });

    test('Android: a non-numeric id never reaches the plugin query', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      granted = true;
      final result = await gateway.event('work', '1) OR (1=1');
      expect((result as Ok<ExternalEvent?, AppFailure>).value, isNull);
      expect(calls.map((c) => c.method), isNot(contains('retrieveEvents')));
    });

    test('gone, or no permission', () async {
      granted = true;
      reply = (_) => jsonEncode(<Object>[]);
      final update = EventUpdate(
        calendarId: 'work',
        eventId: '42',
        startUtc: seven,
        endUtc: seven.add(const Duration(hours: 1)),
      );
      expect(await gateway.updateEvent(update), EventWriteResult.gone);
      granted = false;
      expect(await gateway.updateEvent(update), EventWriteResult.failed);
    });
  });
}
