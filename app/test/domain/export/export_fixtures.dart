import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/export/export_bundle.dart';

import '../fixtures.dart';

/// Text that breaks naive CSV/ICS/JSON writers.
const hostileTitle = '=HYPERLINK("x"), "quoted"; semi\\colon 🧘‍♀️ Ünïcødé';
const hostileNotes = 'line 1\nline 2\r\n+SUM(A1)\t@cmd, end';

/// A bundle with every kind of row and awkward content (data-export skill:
/// round-trip on a hostile fixture).
ExportBundle hostileBundle() {
  final series = seriesFixture().copyWith(
    title: hostileTitle,
    notes: hostileNotes,
    rrule: 'FREQ=WEEKLY;BYDAY=MO,WE',
    dtstartLocal: '2026-10-19T07:00',
    count: 10,
    energy: Energy.low,
    alerts: const [
      Alert(kind: AlertKind.overdue, offsetMin: 15, sound: 'bell'),
    ],
  );
  final instance = occurrenceFixture().copyWith(
    id: '01928c3e-0000-7000-8000-0000000000b2',
    seriesId: series.id,
    originalStartUtc: DateTime.utc(2026, 10, 21, 5),
    startUtc: DateTime.utc(2026, 10, 21, 6),
    title: hostileTitle,
    durationMin: 30,
  );
  final oneOff = occurrenceFixture().copyWith(
    notes: hostileNotes,
    status: OccurrenceStatus.done,
    completedAtUtc: t1,
    alerts: const [],
  );
  final inbox = occurrenceFixture().copyWith(
    id: '01928c3e-0000-7000-8000-0000000000b3',
    title: '-5 minus first',
    startUtc: null,
    sortOrder: 2.5,
  );
  return ExportBundle(
    exportedAt: DateTime.utc(2026, 10, 21, 12),
    profile: profileFixture().copyWith(
      settings: const Settings(
        quietHours: Settings.suggestedQuietHours,
        dayBoundaries: {Weekday.sun: TimeWindow(start: '09:00', end: '20:00')},
      ),
    ),
    series: [series],
    occurrences: [oneOff, instance, inbox],
    subtasks: [
      subtaskFixture().copyWith(title: hostileTitle, done: true),
      subtaskFixture().copyWith(
        id: '01928c3e-0000-7000-8000-0000000000c2',
        occurrenceId: instance.id,
      ),
    ],
  );
}
