import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/writes/row_writer.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';

// Table names are the `sync_push` entities (supabase/migrations/0002).

EntityWriter<Profile> profileWriter(DriftSettingsRepository repo) =>
    EntityWriter(
      table: 'profiles',
      toJson: (p) => p.toJson(),
      idOf: (p) => p.id,
      stamp: (p, now) => p.copyWith(updatedAt: now),
      find: (id) => repo.watchProfile(id).first,
      upsertAll: (rows) async {
        for (final p in rows) {
          await repo.upsert(p);
        }
      },
    );

EntityWriter<Series> seriesWriter(String userId, DriftSeriesRepository repo) =>
    EntityWriter(
      table: 'series',
      toJson: (s) => s.toJson(),
      idOf: (s) => s.id,
      stamp: (s, now) => s.copyWith(updatedAt: now),
      find: (id) => repo.findById(userId, id),
      upsertAll: repo.upsertAll,
    );

EntityWriter<Occurrence> occurrenceWriter(
  String userId,
  DriftOccurrenceRepository repo,
) => EntityWriter(
  table: 'occurrences',
  toJson: (o) => o.toJson(),
  idOf: (o) => o.id,
  stamp: (o, now) => o.copyWith(updatedAt: now),
  find: (id) => repo.findById(userId, id),
  upsertAll: repo.upsertAll,
);

EntityWriter<Subtask> subtaskWriter(
  String userId,
  DriftSubtaskRepository repo,
) => EntityWriter(
  table: 'subtasks',
  toJson: (s) => s.toJson(),
  idOf: (s) => s.id,
  stamp: (s, now) => s.copyWith(updatedAt: now),
  find: (id) => repo.findById(userId, id),
  upsertAll: repo.upsertAll,
);
