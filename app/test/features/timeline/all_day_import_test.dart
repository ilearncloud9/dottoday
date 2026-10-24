import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// The all-day strip with imported events (docs/02 F5, docs/09 M7.1,
// R-02): an all-day calendar event lands in the strip on each of its
// days, in its calendar's inherited colour, and opens to edit.

/// A Tue–Wed all-day event from a red calendar.
const _event = (title: 'Offsite', calendarArgb: 0xFFFF3B30);

List<Occurrence> _imported(tz.Location berlin) {
  final event = ExternalEvent(
    id: 'ev-1',
    calendarId: 'work',
    title: _event.title,
    startUtc: DateTime.utc(2026, 10, 20),
    endUtc: DateTime.utc(2026, 10, 22),
    allDay: true,
  );
  final palette = {for (final c in TaskColor.values) c.key: c.color.toARGB32()};
  return [
    for (final (i, date) in allDayDates(event).indexed)
      Occurrence(
        id: 'imported-$i',
        userId: testUserId,
        title: event.title,
        colorKey: inheritColorKey(_event.calendarArgb, palette),
        startUtc: allDayStartUtc(date, berlin),
        tzId: berlin.name,
        durationMin: maxDurationMin,
        source: OccurrenceSource.calendar,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
  ];
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('each day of the event is an all-day item on that day', () {
    final berlin = tz.getLocation('Europe/Berlin');
    final [tue, wed] = _imported(berlin);
    expect(
      TimelineDay.of(DateTime(2026, 10, 20), berlin).isAllDay(tue),
      isTrue,
    );
    expect(
      TimelineDay.of(DateTime(2026, 10, 21), berlin).isAllDay(wed),
      isTrue,
    );
    expect(tue.colorKey, 'coral');
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (width, size) in [
      ('compact', const Size(390, 844)),
      ('expanded', const Size(1280, 900)),
    ]) {
      testWidgets('the strip meets a11y guidelines: ${mode.name} $width', (
        tester,
      ) async {
        await pumpToday(
          tester,
          mode: mode,
          size: size,
          rows: [
            ...demoDayRows(todayTestDate),
            ..._imported(tz.getLocation('Europe/Berlin')),
          ],
        );
        await expectA11yGuidelines(tester);
      });
    }
  }

  testWidgets('the strip shows it; a tap opens it to edit', (tester) async {
    final berlin = tz.getLocation('Europe/Berlin');
    await pumpToday(
      tester,
      rows: [...demoDayRows(todayTestDate), ..._imported(berlin)],
    );
    expect(find.text(_event.title), findsOneWidget);
    await tester.tap(find.text(_event.title));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
  });
}
