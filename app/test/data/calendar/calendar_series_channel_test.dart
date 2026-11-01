import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/calendar/calendar_series_channel.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

// `dottoday/calendar_series` (docs/02 F5.7): what Dart sends the native
// bridges and how their answers read.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dottoday/calendar_series');
  final calls = <MethodCall>[];
  Object? Function(MethodCall) answer = (_) => 'written';

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          final a = answer(call);
          if (a is PlatformException) throw a;
          return a;
        });
  });

  CalendarSeriesChannel bridge() => CalendarSeriesChannel(
    Logger(MemoryLogSink(), FakeClock(DateTime.utc(2026))),
  );

  test('update sends the shift, length and title it was given', () async {
    final r = await bridge().update(
      const SeriesUpdate(
        calendarId: 'home',
        eventId: 'R1',
        shift: Duration(minutes: -30),
        title: 'Pray',
      ),
    );
    expect(r, EventWriteResult.written);
    expect(calls.single.method, 'update');
    expect(calls.single.arguments, {
      'calendarId': 'home',
      'eventId': 'R1',
      'shiftMs': -1800000,
      'title': 'Pray',
    });
  });

  test('answers and failures map to write results', () async {
    answer = (_) => 'notWritable';
    expect(await bridge().delete('home', 'R1'), EventWriteResult.notWritable);
    answer = (_) => 'gone';
    expect(await bridge().delete('home', 'R1'), EventWriteResult.gone);
    answer = (_) => PlatformException(code: 'denied');
    expect(await bridge().delete('home', 'R1'), EventWriteResult.failed);
  });
}
