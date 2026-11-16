/// The staged import's Trash rule (CR-160 Stage B3), inside the commit's
/// transaction: as the in-memory restore (removed in B5) did, the owner's
/// live rows the staged set doesn't hold get `deleted_at = now` through
/// the write path (synced, restorable for 30 days), never a hard delete.
library;

import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart';

/// Rows trashed per chunk.
const _chunk = 500;

/// The owner's live rows the staged set doesn't hold go to Trash, as the
/// in-memory restore did: imported calendar events and their steps are
/// never part of a backup, so they are never trashed by one.
Future<void> trashAbsent(
  AppDatabase db,
  StagedImport import,
  DateTime nowUtc,
  Future<void> Function(WriteBatch) apply,
) async {
  final owner = import.owner.userId;
  for (final (table, entity, extra) in _trashable) {
    while (true) {
      final ids = [
        for (final r
            in await db
                .customSelect(
                  'SELECT id FROM $table WHERE user_id = ? AND deleted_at IS NULL '
                  '$extra AND id NOT IN (SELECT row_id FROM import_staging WHERE '
                  'import_id = ? AND owner = ? AND entity = ?) ORDER BY id '
                  'LIMIT $_chunk',
                  variables: [
                    Variable.withString(owner),
                    Variable.withString(import.importId),
                    Variable.withString(owner),
                    Variable.withString(entity),
                  ],
                  readsFrom: {db.importStaging},
                )
                .get())
          r.read<String>('id'),
      ];
      if (ids.isEmpty) break;
      await apply(await _trashBatch(db, owner, entity, ids, nowUtc));
    }
  }
}

const _trashable = [
  ('series', 'series', ''),
  ('occurrences', 'occurrences', "AND source <> 'calendar'"),
  (
    'subtasks',
    'subtasks',
    'AND occurrence_id NOT IN (SELECT id FROM occurrences WHERE '
        "source = 'calendar')",
  ),
  ('routines', 'routines', ''),
];

Future<WriteBatch> _trashBatch(
  AppDatabase db,
  String owner,
  String entity,
  List<String> ids,
  DateTime now,
) async => switch (entity) {
  'series' => WriteBatch(
    userId: owner,
    series: [
      for (final r in await (db.select(
        db.seriesTable,
      )..where((t) => t.id.isIn(ids))).get())
        seriesFromRow(r).copyWith(deletedAt: now),
    ],
  ),
  'occurrences' => WriteBatch(
    userId: owner,
    occurrences: [
      for (final r in await (db.select(
        db.occurrences,
      )..where((t) => t.id.isIn(ids))).get())
        occurrenceFromRow(r).copyWith(deletedAt: now),
    ],
  ),
  'subtasks' => WriteBatch(
    userId: owner,
    subtasks: [
      for (final r in await (db.select(
        db.subtasks,
      )..where((t) => t.id.isIn(ids))).get())
        subtaskFromRow(r).copyWith(deletedAt: now),
    ],
  ),
  _ => WriteBatch(
    userId: owner,
    routines: [
      for (final r in await (db.select(
        db.routinesTable,
      )..where((t) => t.id.isIn(ids))).get())
        routineFromRow(r).copyWith(deletedAt: now),
    ],
  ),
};
