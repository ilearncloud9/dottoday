import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/daos/occurrences_dao.dart';
import 'package:dottoday/data/daos/subtasks_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/trash/trash_purge.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/trash/trash_service.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';

/// [TrashService] over the local database; deletes and restores go through
/// the write path so they sync (docs/04 §4 tombstones).
final class DriftTrashService implements TrashService {
  DriftTrashService({
    required AppDatabase db,
    required WriteUseCase writes,
    required UndoService undo,
    required Clock clock,
    required Logger logger,
  }) : _db = db,
       _occurrences = OccurrencesDao(db),
       _subtasks = SubtasksDao(db),
       _writes = writes,
       _undo = undo,
       _clock = clock,
       _logger = logger;

  final AppDatabase _db;
  final OccurrencesDao _occurrences;
  final SubtasksDao _subtasks;
  final WriteUseCase _writes;
  final UndoService _undo;
  final Clock _clock;
  final Logger _logger;

  DateTime get _cutoff => _clock.nowUtc().subtract(TrashService.retention);

  @override
  Stream<List<Occurrence>> watchTrash(String userId) => _occurrences
      .watchTrash(userId, _cutoff.millisecondsSinceEpoch)
      .map((rows) => rows.map(occurrenceFromRow).toList());

  @override
  Future<Result<UndoToken, AppFailure>> trashOccurrences(
    String userId,
    Set<String> ids,
  ) async {
    final live = (await _find(userId, ids)).where((o) => o.deletedAt == null);
    if (live.isEmpty) {
      return const Err(NotFoundFailure(EntityKind.occurrence));
    }
    final now = _clock.nowUtc();
    final liveIds = {for (final o in live) o.id};
    final subtasks = await _subtasks.findForOccurrences(userId, liveIds);
    return _undo.applyUndoable(
      WriteBatch(
        userId: userId,
        occurrences: [for (final o in live) o.copyWith(deletedAt: now)],
        subtasks: [
          for (final s in subtasks.map(subtaskFromRow))
            if (s.deletedAt == null) s.copyWith(deletedAt: now),
        ],
      ),
    );
  }

  @override
  Future<Result<void, AppFailure>> restoreOccurrences(
    String userId,
    Set<String> ids,
  ) async {
    final cutoff = _cutoff;
    final trashed = [
      for (final o in await _find(userId, ids))
        if (o.deletedAt != null && !o.deletedAt!.isBefore(cutoff)) o,
    ];
    if (trashed.isEmpty) return const Ok(null);
    final deletedAt = {for (final o in trashed) o.id: o.deletedAt};
    final subtasks = await _subtasks.findForOccurrences(
      userId,
      deletedAt.keys.toSet(),
    );
    return _writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [for (final o in trashed) o.copyWith(deletedAt: null)],
        // Only subtasks trashed together with their task come back; ones
        // deleted on their own earlier stay deleted.
        subtasks: [
          for (final s in subtasks.map(subtaskFromRow))
            if (s.deletedAt != null && s.deletedAt == deletedAt[s.occurrenceId])
              s.copyWith(deletedAt: null),
        ],
      ),
    );
  }

  @override
  Future<Result<int, AppFailure>> purgeExpired(String userId) async {
    try {
      final removed = await purgeTombstones(
        _db,
        userId,
        cutoff: _cutoff,
        materialisationStart: _clock.nowUtc().subtract(const Duration(days: 1)),
      );
      return Ok(removed);
    } on Exception catch (e, st) {
      _logger.error('trash.purge_failed', error: e, stackTrace: st);
      return const Err(StorageFailure());
    }
  }

  Future<List<Occurrence>> _find(String userId, Set<String> ids) async => [
    for (final id in ids)
      if (await _occurrences.findById(userId, id) case final row?)
        occurrenceFromRow(row),
  ];
}
