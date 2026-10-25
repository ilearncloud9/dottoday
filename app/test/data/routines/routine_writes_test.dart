import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_routine_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/sync/requeue.dart';
import 'package:dottoday/data/undo/in_memory_undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// Routines through the write path (docs/09 M11.4): validated, recorded in
// the outbox for sync, undoable, and requeued on an account switch.

void main() {
  late WriteHarness h;
  late DriftRoutineRepository routines;
  late InMemoryUndoService undo;

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    routines = DriftRoutineRepository(h.db);
    undo = InMemoryUndoService(
      writes: h.writes,
      occurrences: DriftOccurrenceRepository(h.db),
      subtasks: DriftSubtaskRepository(h.db),
      series: DriftSeriesRepository(h.db),
      routines: routines,
      settings: DriftSettingsRepository(h.db),
      clock: h.clock,
      ids: FakeIds('undo'),
    );
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    await h.db.delete(h.db.changeLog).go();
  });
  tearDown(() => h.dispose());

  test('a saved routine round-trips and reaches the outbox', () async {
    final r = routineFixture().copyWith(title: '  Morning  ');
    final result = await h.writes.apply(
      WriteBatch(userId: userId, routines: [r]),
    );
    expect(result, isA<Ok<void, AppFailure>>());
    final back = await routines.findById(userId, r.id);
    expect(back!.title, 'Morning', reason: 'trimmed');
    expect(back.items, routineFixture().items);
    final log = await h.changeLog();
    final fields = {
      for (final c in log)
        if (c.entity == 'routines') c.field,
    };
    expect(fields, containsAll(['title', 'anchor', 'items', 'created_at']));
  });

  test('an invalid routine is refused, nothing written', () async {
    final result = await h.writes.apply(
      WriteBatch(
        userId: userId,
        routines: [routineFixture().copyWith(items: const [])],
      ),
    );
    expect(result, isA<Err<void, AppFailure>>());
    expect(await routines.findById(userId, routineFixture().id), isNull);
  });

  test('deleting a routine can be undone', () async {
    await h.writes.apply(
      WriteBatch(userId: userId, routines: [routineFixture()]),
    );
    final token = (await undo.applyUndoable(
      WriteBatch(
        userId: userId,
        routines: [routineFixture().copyWith(deletedAt: t1)],
      ),
    )).when(ok: (t) => t, err: (f) => fail(f.code));
    expect(await routines.watchActive(userId).first, isEmpty);
    await undo.undo(token);
    expect(await routines.watchActive(userId).first, hasLength(1));
  });

  test('requeue on an account switch includes routines', () async {
    await h.writes.apply(
      WriteBatch(userId: userId, routines: [routineFixture()]),
    );
    await h.db.delete(h.db.changeLog).go();
    await h.db.transaction(() => requeueAll(h.db, h.hlc));
    final log = await h.changeLog();
    expect(log.where((c) => c.entity == 'routines'), isNotEmpty);
  });
}
