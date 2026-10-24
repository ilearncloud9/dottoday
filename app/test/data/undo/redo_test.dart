import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/undo/in_memory_undo_service.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

T _ok<T>(Result<T, AppFailure> r) =>
    r.when(ok: (v) => v, err: (f) => fail('unexpected ${f.code}'));

AppFailure? _err(Result<Object?, AppFailure> r) =>
    r.when(ok: (_) => null, err: (f) => f);

/// Edit › Redo / ⇧⌘Z on the real undo service (docs/09 M8.6b).
void main() {
  late WriteHarness h;
  late DriftOccurrenceRepository occurrences;
  late InMemoryUndoService undo;

  final task = occurrenceFixture();

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    occurrences = DriftOccurrenceRepository(h.db);
    undo = InMemoryUndoService(
      writes: h.writes,
      occurrences: occurrences,
      subtasks: DriftSubtaskRepository(h.db),
      series: DriftSeriesRepository(h.db),
      settings: DriftSettingsRepository(h.db),
      clock: h.clock,
      ids: FakeIds('undo'),
    );
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [task],
      ),
    );
  });
  tearDown(() => h.dispose());

  Future<DateTime?> startOf(String id) async =>
      (await occurrences.findById(userId, id))!.startUtc;

  Future<void> move() async => _ok(
    await undo.applyUndoable(
      WriteBatch(
        userId: userId,
        occurrences: [task.copyWith(startUtc: t1)],
      ),
    ),
  );

  test('nothing to redo until something is undone', () async {
    expect(undo.redoable, isNull);
    await move();
    expect(undo.redoable, isNull);
  });

  test('undo → redo → undo → redo toggles the change', () async {
    await move();
    _ok(await undo.undo(undo.latest!));
    expect(await startOf(task.id), t0);
    expect(undo.latest, isNull);

    final again = _ok(await undo.redo(undo.redoable!));
    expect(await startOf(task.id), t1);
    expect(undo.redoable, isNull);
    expect(undo.latest, again);

    _ok(await undo.undo(undo.latest!));
    expect(await startOf(task.id), t0);
    _ok(await undo.redo(undo.redoable!));
    expect(await startOf(task.id), t1);
  });

  test('a token redoes once', () async {
    await move();
    _ok(await undo.undo(undo.latest!));
    final token = undo.redoable!;
    _ok(await undo.redo(token));
    expect(_err(await undo.redo(token)), isA<UndoExpiredFailure>());
  });

  test('a new change ends the redo chain', () async {
    await move();
    _ok(await undo.undo(undo.latest!));
    final token = undo.redoable!;
    _ok(
      await undo.applyUndoable(
        WriteBatch(
          userId: userId,
          occurrences: [task.copyWith(title: 'X')],
        ),
      ),
    );
    expect(undo.redoable, isNull);
    expect(_err(await undo.redo(token)), isA<UndoExpiredFailure>());
    expect(await startOf(task.id), t0);
  });

  test('expires 30 s after the undo', () async {
    await move();
    _ok(await undo.undo(undo.latest!));
    final token = undo.redoable!;
    h.clock.advance(UndoService.window);
    expect(undo.redoable, isNull);
    expect(_err(await undo.redo(token)), isA<UndoExpiredFailure>());
    expect(await startOf(task.id), t0);
  });

  test('redoing a create brings it back out of Trash', () async {
    final copy = task.copyWith(id: 'copy');
    final token = _ok(
      await undo.applyUndoable(WriteBatch(userId: userId, occurrences: [copy])),
    );
    _ok(await undo.undo(token));
    expect((await occurrences.findById(userId, 'copy'))!.deletedAt, isNotNull);
    _ok(await undo.redo(undo.redoable!));
    expect((await occurrences.findById(userId, 'copy'))!.deletedAt, isNull);
  });

  test('redoing a new series plans its occurrences again', () async {
    final s = seriesFixture();
    Future<int> live() async => [
      for (final o in await occurrences.findBySeries(userId, s.id))
        if (o.deletedAt == null) o,
    ].length;
    final token = _ok(
      await undo.applyUndoable(WriteBatch(userId: userId, series: [s])),
    );
    final planned = await live();
    expect(planned, isPositive);
    _ok(await undo.undo(token));
    expect(await live(), 0);
    _ok(await undo.redo(undo.redoable!));
    expect(await live(), planned);
    _ok(await undo.undo(undo.latest!));
    expect(await live(), 0);
  });
}
