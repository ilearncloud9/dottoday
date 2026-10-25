import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_routine_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/trash/drift_trash_service.dart';
import 'package:dottoday/data/undo/in_memory_undo_service.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart';
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

void main() {
  late WriteHarness h;
  late DriftOccurrenceRepository occurrences;
  late DriftSubtaskRepository subtasks;
  late DriftSeriesRepository series;
  late InMemoryUndoService undo;
  late DriftTrashService trash;

  final task = occurrenceFixture();
  final sub = subtaskFixture();

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    occurrences = DriftOccurrenceRepository(h.db);
    subtasks = DriftSubtaskRepository(h.db);
    series = DriftSeriesRepository(h.db);
    undo = InMemoryUndoService(
      writes: h.writes,
      occurrences: occurrences,
      subtasks: subtasks,
      series: series,
      routines: DriftRoutineRepository(h.db),
      settings: DriftSettingsRepository(h.db),
      clock: h.clock,
      ids: FakeIds('undo'),
    );
    trash = DriftTrashService(
      db: h.db,
      writes: h.writes,
      undo: undo,
      clock: h.clock,
      logger: h.logger,
    );
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [task],
        subtasks: [sub],
      ),
    );
  });
  tearDown(() => h.dispose());

  Future<DateTime?> deletedAt(String id) async =>
      (await occurrences.findById(userId, id))!.deletedAt;

  group('undo', () {
    test('reverts a move within 30 s, once', () async {
      final token = _ok(
        await undo.applyUndoable(
          WriteBatch(
            userId: userId,
            occurrences: [task.copyWith(startUtc: t1)],
          ),
        ),
      );
      expect(token.expiresAtUtc, h.clock.nowUtc().add(UndoService.window));
      h.clock.advance(const Duration(seconds: 29));
      _ok(await undo.undo(token));
      expect((await occurrences.findById(userId, task.id))!.startUtc, t0);
      expect(_err(await undo.undo(token)), isA<UndoExpiredFailure>());
    });

    // The travel banner moves the profile's zone with the tasks (M5.9).
    test('puts a batch\'s profile back', () async {
      final settings = DriftSettingsRepository(h.db);
      final before = (await settings.findLocalProfile())!;
      final token = _ok(
        await undo.applyUndoable(
          WriteBatch(
            userId: userId,
            profile: before.copyWith(tzId: 'America/New_York'),
            occurrences: [task.copyWith(startUtc: t1)],
          ),
        ),
      );
      expect((await settings.findLocalProfile())!.tzId, 'America/New_York');
      _ok(await undo.undo(token));
      expect((await settings.findLocalProfile())!.tzId, before.tzId);
      expect((await occurrences.findById(userId, task.id))!.startUtc, t0);
    });

    test('expires after 30 s', () async {
      final token = _ok(
        await undo.applyUndoable(
          WriteBatch(
            userId: userId,
            occurrences: [task.copyWith(title: 'X')],
          ),
        ),
      );
      h.clock.advance(UndoService.window);
      expect(_err(await undo.undo(token)), isA<UndoExpiredFailure>());
      expect((await occurrences.findById(userId, task.id))!.title, 'X');
    });

    test('undoing a create (e.g. duplicate) moves it to Trash', () async {
      final copy = task.copyWith(id: 'copy');
      final token = _ok(
        await undo.applyUndoable(
          WriteBatch(userId: userId, occurrences: [copy]),
        ),
      );
      _ok(await undo.undo(token));
      expect(await deletedAt('copy'), isNotNull);
    });
  });

  group('trash', () {
    test('trash → listed with subtasks → restore brings both back', () async {
      _ok(await trash.trashOccurrences(userId, {task.id}));
      expect(await deletedAt(task.id), isNotNull);
      expect((await subtasks.findById(userId, sub.id))!.deletedAt, isNotNull);
      expect((await trash.watchTrash(userId).first).map((o) => o.id), [
        task.id,
      ]);

      h.clock.advance(const Duration(days: 29));
      _ok(await trash.restoreOccurrences(userId, {task.id}));
      expect(await deletedAt(task.id), isNull);
      expect((await subtasks.findById(userId, sub.id))!.deletedAt, isNull);
      expect(await trash.watchTrash(userId).first, isEmpty);
    });

    test('a subtask deleted earlier stays deleted on restore', () async {
      await h.writes.apply(
        WriteBatch(
          userId: userId,
          subtasks: [sub.copyWith(deletedAt: h.clock.nowUtc())],
        ),
      );
      h.clock.advance(const Duration(minutes: 1));
      _ok(await trash.trashOccurrences(userId, {task.id}));
      _ok(await trash.restoreOccurrences(userId, {task.id}));
      expect((await subtasks.findById(userId, sub.id))!.deletedAt, isNotNull);
    });

    test('trashing is undoable', () async {
      final token = _ok(await trash.trashOccurrences(userId, {task.id}));
      _ok(await undo.undo(token));
      expect(await deletedAt(task.id), isNull);
      expect((await subtasks.findById(userId, sub.id))!.deletedAt, isNull);
    });

    test('unknown or already-trashed ids', () async {
      expect(
        _err(await trash.trashOccurrences(userId, {'nope'})),
        isA<NotFoundFailure>(),
      );
      expect(_err(await trash.restoreOccurrences(userId, {'nope'})), isNull);
    });

    test('older than 30 days: gone from Trash, not restorable', () async {
      _ok(await trash.trashOccurrences(userId, {task.id}));
      h.clock.advance(const Duration(days: 31));
      expect(await trash.watchTrash(userId).first, isEmpty);
      _ok(await trash.restoreOccurrences(userId, {task.id}));
      expect(await deletedAt(task.id), isNotNull);
    });
  });

  // Repeat edits through the real undo service (M3f.1; found by the M4.9
  // device journey: it used to refuse series).
  group('series', () {
    Future<List<String>> liveOf(String id) async => [
      for (final o in await occurrences.findBySeries(userId, id))
        if (o.deletedAt == null) o.id,
    ];

    test('a new series and what it planned go on Undo', () async {
      final s = seriesFixture();
      final token = _ok(
        await undo.applyUndoable(WriteBatch(userId: userId, series: [s])),
      );
      expect(await liveOf(s.id), isNotEmpty);
      _ok(await undo.undo(token));
      expect((await series.findById(userId, s.id))!.deletedAt, isNotNull);
      expect(await liveOf(s.id), isEmpty);
    });

    test('an edited series comes back as it was', () async {
      final s = seriesFixture();
      await h.writes.apply(WriteBatch(userId: userId, series: [s]));
      final planned = await liveOf(s.id);
      final token = _ok(
        await undo.applyUndoable(
          WriteBatch(
            userId: userId,
            series: [s.copyWith(title: 'Long run', rrule: 'FREQ=WEEKLY')],
          ),
        ),
      );
      _ok(await undo.undo(token));
      final back = (await series.findById(userId, s.id))!;
      expect((back.title, back.rrule), (s.title, s.rrule));
      expect(await liveOf(s.id), unorderedEquals(planned));
    });
  });

  test('undoing Done clears the actual end again (M6.5.2, 11 B1)', () async {
    final token = _ok(
      await undo.applyUndoable(
        WriteBatch(
          userId: userId,
          occurrences: [markDone(task, DateTime.utc(2026, 10, 21, 7))],
        ),
      ),
    );
    expect(
      (await occurrences.findById(userId, task.id))!.actualEndUtc,
      isNotNull,
    );
    _ok(await undo.undo(token));
    final back = (await occurrences.findById(userId, task.id))!;
    expect(back.actualEndUtc, isNull);
    expect(back.status, task.status);
  });
}
