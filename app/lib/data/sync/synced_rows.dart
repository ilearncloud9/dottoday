import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:drift/drift.dart';

/// The synced tables as local JSON rows, for the sync engine (docs/09
/// M6.2): read one, write one as pulled. Raw persistence on purpose: a
/// pulled row is not a local edit, so it adds nothing to the outbox.
final class SyncedRows {
  SyncedRows(this._db)
    : _profiles = DriftSettingsRepository(_db),
      _series = DriftSeriesRepository(_db),
      _occurrences = DriftOccurrenceRepository(_db),
      _subtasks = DriftSubtaskRepository(_db);

  final AppDatabase _db;
  final DriftSettingsRepository _profiles;
  final DriftSeriesRepository _series;
  final DriftOccurrenceRepository _occurrences;
  final DriftSubtaskRepository _subtasks;

  /// Row [id] of [entity] owned by [userId], or null.
  Future<Map<String, Object?>?> find(
    String entity,
    String userId,
    String id,
  ) async => switch (entity) {
    'profiles' => (await _profiles.watchProfile(id).first)?.toJson(),
    'series' => (await _series.findById(userId, id))?.toJson(),
    'occurrences' => (await _occurrences.findById(userId, id))?.toJson(),
    'subtasks' => (await _subtasks.findById(userId, id))?.toJson(),
    _ => throw ArgumentError.value(entity, 'entity'),
  };

  /// Writes [row] (local JSON form) as it is.
  Future<void> put(String entity, Map<String, Object?> row) async {
    switch (entity) {
      case 'profiles':
        await _profiles.upsert(Profile.fromJson(row));
      case 'series':
        await _series.upsertAll([Series.fromJson(row)]);
      case 'occurrences':
        await _occurrences.upsertAll([Occurrence.fromJson(row)]);
      case 'subtasks':
        await _subtasks.upsertAll([Subtask.fromJson(row)]);
      default:
        throw ArgumentError.value(entity, 'entity');
    }
  }

  /// Sets row [id]'s dirty flag: whether it still has writes to push.
  Future<void> markDirty(String entity, String id, {required bool dirty}) {
    final db = _db;
    return db.customUpdate(
      'UPDATE $entity SET dirty = ? WHERE id = ?',
      variables: [Variable<bool>(dirty), Variable<String>(id)],
      updates: {db.allTables.firstWhere((t) => t.actualTableName == entity)},
    );
  }
}
