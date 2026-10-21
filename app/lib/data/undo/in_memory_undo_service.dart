import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';

/// [UndoService] keeping each token's "before" rows in memory.
final class InMemoryUndoService implements UndoService {
  InMemoryUndoService({
    required WriteUseCase writes,
    required OccurrenceRepository occurrences,
    required SubtaskRepository subtasks,
    required Clock clock,
    required IdGenerator ids,
  }) : _writes = writes,
       _occurrences = occurrences,
       _subtasks = subtasks,
       _clock = clock,
       _ids = ids;

  final WriteUseCase _writes;
  final OccurrenceRepository _occurrences;
  final SubtaskRepository _subtasks;
  final Clock _clock;
  final IdGenerator _ids;
  final _pending = <String, _Before>{};

  @override
  Future<Result<UndoToken, AppFailure>> applyUndoable(WriteBatch batch) async {
    if (batch.profile != null || batch.series.isNotEmpty) {
      throw ArgumentError.value(batch, 'batch', 'only occurrences/subtasks');
    }
    final u = batch.userId;
    final before = _Before(
      u,
      {
        for (final o in batch.occurrences)
          o.id: await _occurrences.findById(u, o.id),
      },
      {for (final s in batch.subtasks) s.id: await _subtasks.findById(u, s.id)},
    );
    final written = await _writes.apply(batch);
    if (written case Err(:final failure)) return Err(failure);
    _dropExpired();
    final token = UndoToken(
      id: _ids.newId(),
      expiresAtUtc: _clock.nowUtc().add(UndoService.window),
    );
    _pending[token.id] = before..expiresAtUtc = token.expiresAtUtc;
    return Ok(token);
  }

  @override
  Future<Result<void, AppFailure>> undo(UndoToken token) async {
    final before = _pending.remove(token.id);
    final now = _clock.nowUtc();
    if (before == null || !now.isBefore(before.expiresAtUtc)) {
      return const Err(UndoExpiredFailure());
    }
    final u = before.userId;
    return _writes.apply(
      WriteBatch(
        userId: u,
        occurrences: [
          for (final MapEntry(:key, :value) in before.occurrences.entries)
            ?(value ??
                (await _occurrences.findById(
                  u,
                  key,
                ))?.copyWith(deletedAt: now)),
        ],
        subtasks: [
          for (final MapEntry(:key, :value) in before.subtasks.entries)
            ?(value ??
                (await _subtasks.findById(u, key))?.copyWith(deletedAt: now)),
        ],
      ),
    );
  }

  void _dropExpired() {
    final now = _clock.nowUtc();
    _pending.removeWhere((_, b) => !now.isBefore(b.expiresAtUtc));
  }
}

/// Rows as they were before an undoable write; null = created by it.
final class _Before {
  _Before(this.userId, this.occurrences, this.subtasks);

  final String userId;
  final Map<String, Occurrence?> occurrences;
  final Map<String, Subtask?> subtasks;
  late DateTime expiresAtUtc;
}
