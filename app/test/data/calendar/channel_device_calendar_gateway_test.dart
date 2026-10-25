import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/channel_device_calendar_gateway.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

// The macOS EventKit bridge (docs/09 M7.1b): the same cases as the
// device_calendar gateway (M7.1), over `dottoday/calendars`.

const _channel = ChannelDeviceCalendarGateway.calendarChannel;

Matcher _failure(String code) =>
    isA<Err<Object?, AppFailure>>().having((e) => e.failure.code, 'code', code);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChannelDeviceCalendarGateway gateway;
  late String permission;
  late String answer;
  late List<MethodCall> calls;
  late List<Uri> opened;
  Object? Function(MethodCall call)? reply;

  setUp(() {
    opened = [];
    gateway = ChannelDeviceCalendarGateway(
      Logger(MemoryLogSink(), FakeClock(DateTime.utc(2026, 10, 21))),
      open: (uri) async {
        opened.add(uri);
        return true;
      },
    );
    permission = 'notAsked';
    answer = 'granted';
    calls = [];
    reply = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'status' => permission,
            'request' => permission = answer,
            _ => reply?.call(call),
          };
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('never asked → not asked; asked and refused → denied', () async {
    expect(gateway.available, isTrue);
    expect(await gateway.status(), PermissionState.notAsked);
    answer = 'denied';
    expect(await gateway.request(), PermissionState.denied);
    expect(await gateway.status(), PermissionState.denied);
  });

  test('allowed → granted', () async {
    expect(await gateway.request(), PermissionState.granted);
    expect(await gateway.status(), PermissionState.granted);
  });

  test('a broken bridge reads as denied, never as granted', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    expect(await gateway.status(), PermissionState.denied);
  });

  test('Open settings goes to Privacy › Calendars', () async {
    expect(await gateway.openSettings(), isTrue);
    expect(opened, [
      Uri.parse(
        'x-apple.systempreferences:'
        'com.apple.preference.security?Privacy_Calendars',
      ),
    ]);
  });

  test('without the permission nothing is read', () async {
    expect(await gateway.calendars(), _failure('permission.calendar'));
    expect(
      await gateway.events('work', DateTime.utc(2026), DateTime.utc(2027)),
      _failure('permission.calendar'),
    );
    expect(calls.map((c) => c.method), everyElement('status'));
  });

  test('calendars: id, name, account, colour, read-only', () async {
    permission = 'granted';
    reply = (_) => [
      {
        'id': 'home',
        'name': 'Home',
        'accountName': 'iCloud',
        'colorArgb': 0xFFFF3B30,
        'readOnly': false,
      },
      {'id': 'holidays', 'name': 'Holidays', 'readOnly': true},
      {'name': 'no id: skipped'},
    ];
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

  test('a bridge error is a typed failure', () async {
    permission = 'granted';
    reply = (_) => throw PlatformException(code: 'no_calendar');
    expect(await gateway.calendars(), _failure('unexpected'));
  });

  test(
    'events: the range goes over; all-day events keep their dates',
    () async {
      permission = 'granted';
      reply = (_) => [
        // Fri 23 – Sun 25 Oct; EventKit gives Sunday as the last day.
        {
          'id': 'conf',
          'title': 'Conference',
          'allDay': true,
          'startDay': '2026-10-23',
          'endDay': '2026-10-25',
        },
        {
          'id': 'call',
          'title': 'Call',
          'allDay': false,
          'startMs': DateTime.utc(2026, 10, 23, 7).millisecondsSinceEpoch,
          'endMs': DateTime.utc(2026, 10, 23, 8).millisecondsSinceEpoch,
          'location': 'Room 4',
          'notes': 'Agenda',
          'url': 'https://example.com/call',
        },
        {
          'id': 'odd',
          'title': 'Odd link',
          'startMs': DateTime.utc(2026, 10, 23, 9).millisecondsSinceEpoch,
          'endMs': DateTime.utc(2026, 10, 23, 10).millisecondsSinceEpoch,
          'url': 'javascript:alert(1)',
        },
        {'id': 'broken', 'allDay': true, 'startDay': '23 Oct'},
      ];
      final from = DateTime.utc(2026, 10, 19);
      final to = DateTime.utc(2026, 10, 26);
      final result = await gateway.events('work', from, to);
      expect(calls.last.arguments, {
        'calendarId': 'work',
        'fromMs': from.millisecondsSinceEpoch,
        'toMs': to.millisecondsSinceEpoch,
      });
      final [conf, call, odd] =
          (result as Ok<List<ExternalEvent>, AppFailure>).value;
      expect(conf.allDay, isTrue);
      expect(conf.startUtc, DateTime.utc(2026, 10, 23));
      expect(conf.endUtc, DateTime.utc(2026, 10, 26));
      expect(call.startUtc, DateTime.utc(2026, 10, 23, 7));
      expect(call.endUtc, DateTime.utc(2026, 10, 23, 8));
      expect(call.calendarId, 'work');
      expect(call.location, 'Room 4');
      expect(call.description, 'Agenda');
      expect(call.url, Uri.parse('https://example.com/call'));
      // Only web links are kept (06 §7).
      expect(odd.url, isNull);
    },
  );

  test('macOS uses the EventKit bridge', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(deviceCalendarGatewayProvider),
      isA<ChannelDeviceCalendarGateway>(),
    );
  });
}
