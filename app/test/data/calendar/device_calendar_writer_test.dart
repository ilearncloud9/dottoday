import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/calendar/device_calendar_writer.dart';
import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/calendar_fakes.dart';

// Device calendars have no etags (docs/09 M7.3): the writer compares a
// fingerprint right before writing, so a change made in the calendar
// since the read is never overwritten unseen.

final _nine = DateTime.utc(2026, 10, 21, 7);
const _at = EventAddress(calendarId: 'work', eventId: 'E1');

ExternalEvent _event({String title = 'Standup', bool repeating = false}) =>
    ExternalEvent(
      id: 'E1',
      calendarId: 'work',
      title: title,
      startUtc: _nine,
      endUtc: _nine.add(const Duration(minutes: 15)),
      repeating: repeating,
    );

void main() {
  late FakeDeviceCalendarGateway os;
  late DeviceCalendarWriter writer;

  setUp(() {
    os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      events: {
        'work': [_event()],
      },
    );
    writer = DeviceCalendarWriter(os);
  });

  Future<RemoteEvent> read() async =>
      (await writer.read(_at) as Ok<RemoteEvent?, AppFailure>).value!;

  final patch = EventPatch(
    startUtc: _nine.add(const Duration(hours: 1)),
    endUtc: _nine.add(const Duration(hours: 1, minutes: 15)),
  );

  test('writes when the event is as read', () async {
    final remote = await read();
    expect(remote.version, isNot(contains('Standup')), reason: 'hash only');
    final done = await writer.write(
      _at,
      patch,
      expectedVersion: remote.version,
    );
    expect(done, WriteBackOutcome.written);
    expect(os.updates.single.startUtc, patch.startUtc);
  });

  test('changed since the read: nothing written', () async {
    final remote = await read();
    os.eventsByCalendar['work']![0] = _event(title: 'Sync');
    final done = await writer.write(
      _at,
      patch,
      expectedVersion: remote.version,
    );
    expect(done, WriteBackOutcome.changed);
    expect(os.updates, isEmpty);
  });

  test('gone, repeating, unreadable', () async {
    final remote = await read();
    os.eventsByCalendar['work']![0] = _event(repeating: true);
    final repeating = await read();
    expect(repeating.writable, isFalse);
    expect(
      await writer.write(_at, patch, expectedVersion: repeating.version),
      WriteBackOutcome.notWritable,
    );
    os.eventsByCalendar['work']!.clear();
    expect(
      await writer.write(_at, patch, expectedVersion: remote.version),
      WriteBackOutcome.gone,
    );
    os.readFails = true;
    expect(
      await writer.write(_at, patch, expectedVersion: remote.version),
      WriteBackOutcome.failed,
    );
  });
}
