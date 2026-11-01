import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_calendar_series_repository.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_routine_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/undo/in_memory_undo_service.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// What the person sets for a repeating calendar event (docs/02 F5.7):
// written through the write path, validated, device-only, undoable.

void main() {
  late WriteHarness h;
  late DriftCalendarSeriesRepository repo;
  late InMemoryUndoService undo;
  final now = DateTime.utc(2026, 10, 21, 6);

  CalendarSeries series({String? notes = 'Psalm'}) => CalendarSeries(
    id: 's1',
    userId: userId,
    accountId: 'acc',
    seriesKey: 'R1',
    notes: notes,
    alerts: const [Alert(kind: AlertKind.atStart)],
    subtaskTemplate: const [
      SubtaskTemplateItem(id: 't1', title: ' Read ', sortOrder: 1),
    ],
    createdAt: now,
    updatedAt: now,
  );

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(now);
    repo = DriftCalendarSeriesRepository(h.db);
    undo = InMemoryUndoService(
      writes: h.writes,
      occurrences: DriftOccurrenceRepository(h.db),
      subtasks: DriftSubtaskRepository(h.db),
      series: DriftSeriesRepository(h.db),
      routines: DriftRoutineRepository(h.db),
      calendarSeries: repo,
      settings: DriftSettingsRepository(h.db),
      clock: h.clock,
      ids: FakeIds('undo'),
    );
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    await h.db.customStatement(
      'INSERT INTO calendar_accounts (id, user_id, provider, label, '
      "created_at, updated_at) VALUES ('acc', '$userId', 'apple_device', "
      "'Work', 0, 0)",
    );
    await h.db.delete(h.db.changeLog).go();
  });
  tearDown(() => h.dispose());

  test('round-trips, trimmed, and never reaches the outbox', () async {
    final result = await h.writes.apply(
      WriteBatch(userId: userId, calendarSeries: [series()]),
    );
    expect(result, isA<Ok<void, AppFailure>>());
    final back = await repo.findByKey(userId, 'acc', 'R1');
    expect(back!.notes, 'Psalm');
    expect(back.alerts, const [Alert(kind: AlertKind.atStart)]);
    expect(back.subtaskTemplate!.single.title, 'Read');
    expect(await h.changeLog(), isEmpty, reason: 'device-only');
  });

  test('an invalid override is refused', () async {
    final result = await h.writes.apply(
      WriteBatch(
        userId: userId,
        calendarSeries: [series().copyWith(startMinute: 1440)],
      ),
    );
    expect(result, isA<Err<void, AppFailure>>());
    expect(await repo.findAll(userId), isEmpty);
  });

  test('Undo puts a changed row back and clears a created one', () async {
    final created = await undo.applyUndoable(
      WriteBatch(userId: userId, calendarSeries: [series()]),
    );
    final changed = await undo.applyUndoable(
      WriteBatch(
        userId: userId,
        calendarSeries: [series(notes: 'Proverbs').copyWith(hidden: true)],
      ),
    );
    await undo.undo((changed as Ok<UndoToken, AppFailure>).value);
    final back = await repo.findById(userId, 's1');
    expect((back!.notes, back.hidden), ('Psalm', false));
    await undo.undo((created as Ok<UndoToken, AppFailure>).value);
    final cleared = await repo.findById(userId, 's1');
    expect(cleared, series(notes: null).cleared().copyWith(updatedAt: now));
  });
}
