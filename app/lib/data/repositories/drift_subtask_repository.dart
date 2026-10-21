import 'package:dottoday/data/daos/subtasks_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';

const _codec = RowCodec();

Subtask _toEntity(SubtaskRow row) => Subtask.fromJson(_codec.decode(row));

/// [SubtaskRepository] over the local Drift database.
final class DriftSubtaskRepository implements SubtaskRepository {
  DriftSubtaskRepository(AppDatabase db) : _dao = SubtasksDao(db);

  final SubtasksDao _dao;

  @override
  Stream<List<Subtask>> watchForOccurrences(
    String userId,
    Set<String> occurrenceIds,
  ) => _dao
      .watchForOccurrences(userId, occurrenceIds)
      .map((rows) => rows.map(_toEntity).toList());

  @override
  Future<Subtask?> findById(String userId, String id) async {
    final row = await _dao.findById(userId, id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<void> upsertAll(Iterable<Subtask> subtasks) => _dao.upsertAll(
    subtasks.map((s) => _codec.encode<SubtaskRow>(s.toJson())),
  );
}
