import 'dart:async';
import 'dart:convert';

import 'package:dottoday/data/live_activity/live_activity_content.dart';
import 'package:dottoday/data/live_activity/live_activity_sink.dart';
import 'package:dottoday/domain/live_activity/live_dot_plan.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/timeline_fakes.dart';

// 08:22 UTC = 10:22 in Berlin (the render's moment): Deep work 9:00–11:00
// is live, Reply to email 11:00–11:30 next.
final _now = DateTime.utc(2026, 10, 21, 8, 22);
final _deepStart = DateTime.utc(2026, 10, 21, 7);

DaySnapshot _snapshot({bool done = false}) => DaySnapshot(
  generatedAtUtc: _now,
  wakeUtc: DateTime.utc(2026, 10, 21, 5),
  bedUtc: DateTime.utc(2026, 10, 21, 20),
  inboxCount: 0,
  dayDone: 1,
  dayTotal: 3,
  dots: [
    SnapshotDot(
      id: '01928c3e-0000-7000-8000-0000000000b1',
      title: 'Deep work: roadmap',
      startUtc: _deepStart,
      durationMin: 120,
      colorKey: 'indigo',
      iconKey: 'code',
      done: done,
    ),
    SnapshotDot(
      id: '01928c3e-0000-7000-8000-0000000000b2',
      title: 'Reply to email',
      startUtc: _deepStart.add(const Duration(hours: 2)),
      durationMin: 30,
      colorKey: 'coral',
      iconKey: 'mail',
      done: false,
    ),
  ],
);

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  group('content', () {
    test('every word and time is ready to lay out', () {
      final c = liveActivityContent(
        liveDotPlan(_snapshot(), _now)!,
        profile: testProfile(),
        use24h: true,
      );
      expect(c['title'], 'Deep work: roadmap');
      expect(c['live'], isTrue);
      expect(c['range'], '09:00 – 11:00');
      expect((c['left_before'], c['left_after']), ('', ' left'));
      expect(c['count'], '1 of 3');
      expect(c['count_label'], '1 of 3 done today');
      expect(c['done_label'], 'Done');
      expect(c['plus_label'], '+15 min');
      expect(c['color'], '#3B6CF6');
      expect(c['icon'], 'code');
      expect(
        c['ends_ms'],
        DateTime.utc(2026, 10, 21, 9, 30).millisecondsSinceEpoch,
      );
      expect(c['next'], [
        {
          'id': '01928c3e-0000-7000-8000-0000000000b2',
          'title': 'Reply to email',
          'color': '#E5674F',
          'time': '11:00',
        },
      ]);
      expect(jsonEncode(c).length, lessThan(4096), reason: 'ActivityKit cap');
    });

    test('no count when today counts no dots', () {
      final s = _snapshot();
      final empty = DaySnapshot(
        generatedAtUtc: s.generatedAtUtc,
        wakeUtc: s.wakeUtc,
        bedUtc: s.bedUtc,
        dots: s.dots,
        inboxCount: 0,
      );
      final c = liveActivityContent(
        liveDotPlan(empty, _now)!,
        profile: testProfile(),
        use24h: true,
      );
      expect((c['count'], c['count_label']), ('', ''));
    });

    test('German puts the countdown after its word', () {
      final c = liveActivityContent(
        liveDotPlan(_snapshot(), _now)!,
        profile: testProfile().copyWith(locale: 'de'),
        use24h: true,
      );
      expect((c['left_before'], c['left_after']), ('noch ', ''));
      expect(c['count'], '1 von 3');
      expect(c['done_label'], 'Erledigt');
    });
  });

  group('sink', () {
    late List<MethodCall> calls;
    late FakeClock clock;
    late List<(Duration, void Function())> timers;
    late LiveActivitySink sink;
    const channel = MethodChannel('test/live_activity');

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      calls = [];
      timers = [];
      clock = FakeClock(_now);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return null;
          });
      sink = LiveActivitySink(
        clock: clock,
        profile: () async => testProfile(),
        channel: channel,
        timer: (wait, fire) {
          timers.add((wait, fire));
          return Timer(Duration.zero, () {})..cancel();
        },
      );
    });

    Map<String, Object?>? last() => calls.last.arguments == null
        ? null
        : jsonDecode(calls.last.arguments as String) as Map<String, Object?>;

    test('starts with the live dot and re-plans when Reply starts', () async {
      await sink.write(_snapshot());
      expect(calls.last.method, 'sync');
      expect(last()?['title'], 'Deep work: roadmap');
      // Next change: Reply starts at 11:00 Berlin = 09:00Z, 38 min on.
      expect(timers.single.$1, const Duration(minutes: 38));
      clock.advance(const Duration(minutes: 38));
      timers.single.$2();
      await pumpEventQueue();
      expect(last()?['title'], 'Reply to email');
    });

    test('Done ends it: sync with null', () async {
      await sink.write(_snapshot(done: true));
      // Reply starts in 38 min: within the hour, so it shows as next.
      expect(last()?['live'], isFalse);
      expect(last()?['title'], 'Reply to email');
      clock.advance(const Duration(hours: 3));
      await sink.write(_snapshot(done: true));
      expect(calls.last.arguments, isNull);
    });
  });
}
