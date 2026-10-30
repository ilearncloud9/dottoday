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
    durationFromSteps: true,
    // docs/12 §3: a chosen sound.
    soundId: 'clear.lift',
    subtaskTemplate: const [
      SubtaskTemplateItem(id: 't1', title: 'Stretch', durationMin: 2),
    ],
  );
  final instance = occurrenceFixture().copyWith(
    id: '01928c3e-0000-7000-8000-0000000000b2',
    seriesId: series.id,
    originalStartUtc: DateTime.utc(2026, 10, 21, 5),
    startUtc: DateTime.utc(2026, 10, 21, 6),
    title: hostileTitle,
    durationMin: 30,
    soundId: 'none',
  );
  final oneOff = occurrenceFixture().copyWith(
    notes: hostileNotes,
    status: OccurrenceStatus.done,
    completedAtUtc: t1,
    alerts: const [],
    // B1/B2 (M6.5.1).
    actualStartUtc: DateTime.utc(2026, 10, 21, 7, 42),
    actualEndUtc: DateTime.utc(2026, 10, 21, 8, 16),
    durationFromSteps: true,
    // A newer device's sound: kept as is, resolved on read.
    soundId: 'quiet.from_the_future',
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
        reminderSound: 'system',
        startSoundId: 'start.morning',
        doneSoundId: 'done.checked',
        inAppSoundsEnabled: false,
        dayBoundaries: {Weekday.sun: TimeWindow(start: '09:00', end: '20:00')},
      ),
    ),
    series: [series],
    occurrences: [oneOff, instance, inbox],
    subtasks: [
      subtaskFixture().copyWith(
        title: hostileTitle,
        done: true,
        durationMin: 1,
        doneAt: DateTime.utc(2026, 10, 26, 9, 15),
      ),
      subtaskFixture().copyWith(
        id: '01928c3e-0000-7000-8000-0000000000c2',
        occurrenceId: instance.id,
      ),
    ],
    routines: [
      routineFixture().copyWith(
        title: hostileTitle,
        items: [
          routineFixture().items.first.copyWith(
            title: hostileTitle,
            soundId: 'play.frog',
          ),
          ...routineFixture().items.skip(1),
        ],
      ),
    ],
  );
}
