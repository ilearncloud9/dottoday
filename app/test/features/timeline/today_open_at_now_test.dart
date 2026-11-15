import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// Today opens at now (ED-336, ED-103): on a 360×640 Android the live task
// sat under the floating Day / Add controls. Other days open at their
// first task.

/// The floating controls' strip, as the shell's bottom padding.
const _controls = 120.0;

/// Eight 15-minute tasks from 7:00 Berlin, then "Live one" 9:00–10:00,
/// live at the harness's 9:22, on [day] Oct 2026.
List<Occurrence> _rows(int day) {
  final base = demoDayRows(todayTestDate).firstWhere((o) => o.startUtc != null);
  Occurrence at(String id, String title, int minute, int length) =>
      base.copyWith(
        id: '$id-$day',
        title: title,
        seriesId: null,
        status: OccurrenceStatus.planned,
        startUtc: DateTime.utc(2026, 10, day, 5).add(Duration(minutes: minute)),
        durationMin: length,
      );
  return [
    for (var i = 0; i < 8; i++) at('early$i', 'Early $i', i * 15, 15),
    at('live', 'Live one', 120, 60),
  ];
}

Future<void> _pump(WidgetTester tester, {DateTime? date}) => pumpToday(
  tester,
  size: const Size(360, 640),
  date: date,
  rows: [..._rows(21), ..._rows(22)],
  wrap: (today) => Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: const EdgeInsets.only(bottom: _controls)),
      child: today,
    ),
  ),
);

ScrollPosition _thread(WidgetTester tester) => tester
    .state<ScrollableState>(
      find
          .descendant(
            of: find.byType(DayCard),
            matching: find.byType(Scrollable),
          )
          .first,
    )
    .position;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('today opens with the live task above the controls', (
    tester,
  ) async {
    await _pump(tester);
    expect(_thread(tester).pixels, greaterThan(0));
    final top = tester.getTopLeft(find.text('Live one')).dy;
    expect(top, greaterThan(0));
    expect(top, lessThan(640 - _controls));
  });

  testWidgets('another day opens at its first task', (tester) async {
    await _pump(tester, date: DateTime(2026, 10, 22));
    expect(_thread(tester).pixels, 0);
    expect(find.text('Early 0'), findsOneWidget);
  });
}
