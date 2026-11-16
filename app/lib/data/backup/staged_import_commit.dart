/// The staged import's commit (CR-160 Stage B3,
/// docs/cr-160-multipart-export.md §5 step 5): one transaction on the app
/// database that turns the owner's data into the staged set, as the
/// in-memory restore (removed in B5) did for a whole bundle. Inside it:
///
/// - the staging fence (owner shown, same owner session, not sealed, not
///   being removed);
/// - staged rows re-owned to the importing account and written in chunks
///   through the write path's `applyWithoutEffects` (outbox, HLC,
///   validation, the seal and the Finding X foreign-row check on every
///   row); each chunk is a savepoint. After-write effects are never run
///   inside this transaction: the caller schedules them once it commits;
/// - first, the owner's live rows the set doesn't hold moved to Trash
///   (imported calendar events and their steps excepted, as today);
/// - calendar templates stashed as pending (atomic with the rest now);
/// - the staging deleted.
///
/// Any refusal throws [CommitFailed] and the whole transaction rolls back:
/// nothing live changes, and the import's staging stays for the caller to
/// discard.
library;

import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/backup/staged_import_trash.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/writes/drift_write_use_case.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/export/import_rows.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart';

/// The commit was refused; the transaction rolled back.
final class CommitFailed implements Exception {
  const CommitFailed(this.failure);
  final AppFailure failure;
}

/// Rows written per chunk.
const _chunk = 500;

/// Commits [import] for its owner. [afterChunk] runs inside the
/// transaction after each chunk (tests: crash snapshots, injected faults).
Future<void> commitStagedImport(
  AppDatabase db,
  DriftWriteUseCase writes,
  StagedImport import, {
  required DateTime nowUtc,
  required IdGenerator ids,
  Future<void> Function()? afterChunk,
}) => db.transaction(() async {
  await checkStagedImport(db, import);
  final owner = import.owner.userId;
  Future<void> apply(WriteBatch batch) async {
    if (await writes.applyWithoutEffects(batch) case Err(:final failure)) {
      throw CommitFailed(failure);
    }
    await afterChunk?.call();
  }

  T row<T>(String entity, Map<String, Object?> json) =>
      switch (importRow(entity, json)) {
        Ok(:final value) => value as T,
        Err(:final failure) => throw CommitFailed(failure),
      };

  final current = await (db.select(
    db.profiles,
  )..where((p) => p.id.equals(owner))).getSingleOrNull();
  if (current == null) throw const CommitFailed(StorageFailure());
  final staged = (await stagedRows(db, import, 'profile')).single;
  await apply(
    WriteBatch(
      userId: owner,
      profile: row<Profile>(
        'profile',
        staged,
      ).copyWith(id: owner, createdAt: profileFromRow(current).createdAt),
    ),
  );
  // Trash first, from the owner's rows as they are before this import (as
  // the in-memory restore took them): instances materialised below for the
  // imported series are never the import's to trash.
  await trashAbsent(db, import, nowUtc, apply);
  // A series with its staged instances, so materialising it sees them.
  await _pages(db, import, 'series', (page) async {
    final series = [
      for (final s in page) row<Series>('series', s).copyWith(userId: owner),
    ];
    final instances = await _instancesOf(db, import, [
      for (final s in series) s.id,
    ]);
    await apply(
      WriteBatch(
        userId: owner,
        series: series,
        occurrences: [
          for (final o in instances)
            row<Occurrence>('occurrences', o).copyWith(userId: owner),
        ],
      ),
    );
  });
  await _pages(db, import, 'occurrences', where: _oneOff, (page) async {
    await apply(
      WriteBatch(
        userId: owner,
        occurrences: [
          for (final o in page)
            row<Occurrence>('occurrences', o).copyWith(userId: owner),
        ],
      ),
    );
  });
  await _pages(db, import, 'subtasks', (page) async {
    await apply(
      WriteBatch(
        userId: owner,
        subtasks: [
          for (final s in page)
            row<Subtask>('subtasks', s).copyWith(userId: owner),
        ],
      ),
    );
  });
  await _pages(db, import, 'routines', (page) async {
    await apply(
      WriteBatch(
        userId: owner,
        routines: [
          for (final r in page)
            row<Routine>('routines', r).copyWith(userId: owner),
        ],
      ),
    );
  });
  final templates = [
    for (final t in await stagedRows(db, import, 'calendarSeries', limit: -1))
      row<CalendarSeriesTemplate>('calendarSeries', t),
  ];
  if (await stashCalendarSeriesTemplates(db, owner, templates, ids) case Err(
    :final failure,
  )) {
    throw CommitFailed(failure);
  }
  await discardStagedImport(db, import);
});

const _oneOff = r"AND json_extract(json, '$.series_id') IS NULL";

/// Runs [write] on [entity]'s staged rows, [_chunk] at a time.
Future<void> _pages(
  AppDatabase db,
  StagedImport import,
  String entity,
  Future<void> Function(List<Map<String, Object?>> page) write, {
  String where = '',
}) async {
  var after = '';
  while (true) {
    final rows = await db
        .customSelect(
          'SELECT row_id, json FROM import_staging WHERE import_id = ? AND '
          'owner = ? AND entity = ? AND row_id > ? $where '
          'ORDER BY row_id LIMIT $_chunk',
          variables: [
            Variable.withString(import.importId),
            Variable.withString(import.owner.userId),
            Variable.withString(entity),
            Variable.withString(after),
          ],
          readsFrom: {db.importStaging},
        )
        .get();
    if (rows.isEmpty) return;
    await write([for (final r in rows) _decoded(r.read<String>('json'))]);
    after = rows.last.read<String>('row_id');
  }
}

Future<List<Map<String, Object?>>> _instancesOf(
  AppDatabase db,
  StagedImport import,
  List<String> seriesIds,
) async {
  if (seriesIds.isEmpty) return const [];
  final rows = await db
      .customSelect(
        'SELECT json FROM import_staging WHERE import_id = ? AND owner = ? '
        "AND entity = 'occurrences' AND json_extract(json, '\$.series_id') "
        'IN (${List.filled(seriesIds.length, '?').join(', ')}) ORDER BY row_id',
        variables: [
          Variable.withString(import.importId),
          Variable.withString(import.owner.userId),
          for (final id in seriesIds) Variable.withString(id),
        ],
        readsFrom: {db.importStaging},
      )
      .get();
  return [for (final r in rows) _decoded(r.read<String>('json'))];
}

Map<String, Object?> _decoded(String json) =>
    jsonDecode(json) as Map<String, Object?>;
