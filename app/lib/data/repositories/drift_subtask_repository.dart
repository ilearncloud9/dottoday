import 'package:dottoday/data/daos/subtasks_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';

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
      .map((rows) => rows.map(subtaskFromRow).toList());

  @override
  Future<Subtask?> findById(String userId, String id) async {
    final row = await _dao.findById(userId, id);
    return row == null ? null : subtaskFromRow(row);
  }

  @override
  Future<void> upsertAll(Iterable<Subtask> subtasks) => _dao.upsertAll(
    subtasks.map((s) => subtaskCodec.encode<SubtaskRow>(s.toJson())),
  );
}
