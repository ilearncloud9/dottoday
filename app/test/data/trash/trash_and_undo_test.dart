import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/trash/drift_trash_service.dart';
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

void main() {
  late WriteHarness h;
  late DriftOccurrenceRepository occurrences;
  late DriftSubtaskRepository subtasks;
  late InMemoryUndoService undo;
  late DriftTrashService trash;

  final task = occurrenceFixture();
  final sub = subtaskFixture();

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    occurrences = DriftOccurrenceRepository(h.db);
    subtasks = DriftSubtaskRepository(h.db);
    undo = InMemoryUndoService(
      writes: h.writes,
      occurrences: occurrences,
      subtasks: subtasks,
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

    test('series edits are not undoable here (M4.4)', () {
      expect(
        () => undo.applyUndoable(
          WriteBatch(userId: userId, series: [seriesFixture()]),
        ),
        throwsArgumentError,
      );
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
}
