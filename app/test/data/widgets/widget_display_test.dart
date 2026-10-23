import 'dart:convert';

import 'package:dottoday/data/widgets/home_widget_sink.dart';
import 'package:dottoday/data/widgets/widget_display.dart';
import 'package:dottoday/domain/widgets/widget_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  // 07:22 UTC = 09:22 in Berlin: Deep work (9:00–11:00) is live.
  final now = DateTime.utc(2026, 10, 21, 7, 22);
  WidgetSnapshot snapshot({int inbox = 3}) => WidgetSnapshot.build(
    nowUtc: now,
    occurrences: demoDayRows(DateTime(2026, 10, 21)),
    inboxCount: inbox,
  );

  test('strings are formatted on the profile clock, colours resolved', () {
    final json = widgetDisplayJson(
      snapshot(),
      profile: testProfile(),
      use24h: false,
    );
    final blocks = (json['blocks']! as List).cast<Map<String, Object?>>();
    final deep = blocks.firstWhere((b) => b['title'] == 'Deep work: roadmap');
    expect(deep['time'], '9:00 AM');
    expect(deep['until'], 'until 11:00 AM');
    expect(deep['color'], '#3B6CF6');
    expect(deep['end_ms'], (deep['start_ms']! as int) + 120 * 60 * 1000);
    expect(json['labels'], containsPair('inbox', '3 in Inbox'));
    expect(json['labels'], containsPair('next_up', 'Next up'));
  });

  test('24-hour clock and an empty Inbox', () {
    final json = widgetDisplayJson(
      snapshot(inbox: 0),
      profile: testProfile(),
      use24h: true,
    );
    final first = (json['blocks']! as List).first as Map<String, Object?>;
    expect(first['time'], matches(RegExp(r'^\d\d:\d\d$')));
    expect(json['labels'], containsPair('inbox', 'Inbox is clear'));
  });

  test('round-trips through JSON (what the native widgets parse)', () {
    final json = widgetDisplayJson(
      snapshot(),
      profile: testProfile(),
      use24h: false,
    );
    expect(jsonDecode(jsonEncode(json)), json);
    expect(json['v'], 1);
  });

  test('Android redraws at every start and end still ahead', () {
    final times = HomeWidgetSnapshotSink.redrawTimes(snapshot());
    expect(times, isNotEmpty);
    expect(times.every((t) => t.isAfter(now)), isTrue);
    expect(times, orderedEquals([...times]..sort()));
    expect(times.toSet(), hasLength(times.length));
    // Deep work (live) ends at 11:00 Berlin = 09:00 UTC.
    expect(times, contains(DateTime.utc(2026, 10, 21, 9)));
  });
}
