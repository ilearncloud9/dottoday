/// The staged import's checks over the whole staged set (CR-160 Stage B3,
/// docs/cr-160-multipart-export.md §5 step 3), in the JSON v1 import's
/// order: every row decodes; imported calendar events and their steps are
/// dropped (never validated, as `ExportBundle.withoutImported` runs before
/// validation); every other row passes the v1 validators; then, in SQL,
/// exactly one profile, one owner, references that resolve inside the set
/// and one calendar template per calendar and series. Ids are unique per
/// table by the staging key. Any failure refuses the import before the
/// safety backup and before any live change.
library;

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/staged_import_sources.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/export/import_rows.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:drift/drift.dart';

/// Checks [import]'s staged rows; [totals] (a multipart manifest's) must
/// match the rows staged before anything is dropped. Throws
/// [SourceRefused] when the set is not one the v1 import would accept.
Future<void> verifyStagedRows(
  AppDatabase db,
  StagedImport import, {
  TableCounts? totals,
}) async {
  if (totals != null) await _matchTotals(db, import, totals);
  final dropped = await _importedEventIds(db, import);
  for (final entity in importEntities) {
    await _eachRow(db, import, entity, (row) {
      final skip =
          (entity == 'occurrences' && dropped.contains(row['id'])) ||
          (entity == 'subtasks' && dropped.contains(row['occurrence_id']));
      final ok = skip
          ? decodeImportRow(entity, row) is Ok
          : importRow(entity, row) is Ok;
      if (!ok) throw badImportFile;
    });
  }
  await _dropImportedEvents(db, import);
  for (final sql in _mustBeZero) {
    final n = await _count(db, import, sql);
    if (n != 0) throw badImportFile;
  }
  if (await _count(db, import, _profiles) != 1) throw badImportFile;
}

Future<void> _matchTotals(
  AppDatabase db,
  StagedImport import,
  TableCounts totals,
) async {
  for (final t in partTables) {
    final n = await _count(db, import, "AND entity = '$t'", select: '*');
    if (n != totals[t]) throw badImportFile;
  }
}

Future<Set<String>> _importedEventIds(
  AppDatabase db,
  StagedImport import,
) async => {
  for (final r
      in await db
          .customSelect(
            'SELECT row_id FROM import_staging WHERE import_id = ? AND owner = ? '
            "AND entity = 'occurrences' "
            r"AND json_extract(json, '$.source') = 'calendar'",
            variables: _keys(import),
            readsFrom: {db.importStaging},
          )
          .get())
    r.read<String>('row_id'),
};

/// Removes imported calendar events and their steps from staging, as the
/// v1 import leaves them out of what it applies.
Future<void> _dropImportedEvents(AppDatabase db, StagedImport import) async {
  const events =
      'SELECT row_id FROM import_staging WHERE import_id = ?1 AND owner = ?2 '
      "AND entity = 'occurrences' "
      r"AND json_extract(json, '$.source') = 'calendar'";
  await db.customStatement(
    'DELETE FROM import_staging WHERE import_id = ?1 AND owner = ?2 AND '
    r"entity = 'subtasks' AND json_extract(json, '$.occurrence_id') IN "
    '($events)',
    [import.importId, import.owner.userId],
  );
  await db.customStatement(
    'DELETE FROM import_staging WHERE import_id = ?1 AND owner = ?2 AND '
    'row_id IN ($events) AND entity = \'occurrences\'',
    [import.importId, import.owner.userId],
  );
}

const _profiles = "AND entity = 'profile'";

/// Conditions no staged row may meet (each counted over this import).
const _mustBeZero = [
  // One owner: every row names the profile's id.
  r"AND entity <> 'profile' AND json_extract(json, '$.user_id') IS NOT "
      r"(SELECT json_extract(p.json, '$.id') FROM import_staging p WHERE "
      "p.import_id = ?1 AND p.owner = ?2 AND p.entity = 'profile')",
  // An instance's series is in the set.
  r"AND entity = 'occurrences' AND json_extract(json, '$.series_id') IS NOT "
      r"NULL AND json_extract(json, '$.series_id') NOT IN (SELECT s.row_id "
      'FROM import_staging s WHERE s.import_id = ?1 AND s.owner = ?2 AND '
      "s.entity = 'series')",
  // A step's task is in the set.
  r"AND entity = 'subtasks' AND (json_extract(json, '$.occurrence_id') IS "
      r"NULL OR json_extract(json, '$.occurrence_id') NOT IN (SELECT o.row_id "
      'FROM import_staging o WHERE o.import_id = ?1 AND o.owner = ?2 AND '
      "o.entity = 'occurrences'))",
  // One template per calendar and series.
  "AND entity = 'calendarSeries' AND EXISTS (SELECT 1 FROM import_staging "
      'c WHERE c.import_id = ?1 AND c.owner = ?2 AND c.entity = '
      "'calendarSeries' AND c.row_id <> import_staging.row_id AND "
      r"json_extract(c.json, '$.provider') IS json_extract(import_staging.json, "
      r"'$.provider') AND json_extract(c.json, '$.external_calendar_id') IS "
      r"json_extract(import_staging.json, '$.external_calendar_id') AND "
      r"json_extract(c.json, '$.series_key') IS json_extract("
      r"import_staging.json, '$.series_key'))",
];

Future<int> _count(
  AppDatabase db,
  StagedImport import,
  String where, {
  String select = '*',
}) async =>
    (await db
            .customSelect(
              'SELECT COUNT($select) AS n FROM import_staging WHERE import_id = ?1 '
              'AND owner = ?2 $where',
              variables: _keys(import),
              readsFrom: {db.importStaging},
            )
            .getSingle())
        .read<int>('n');

List<Variable<Object>> _keys(StagedImport import) => [
  Variable.withString(import.importId),
  Variable.withString(import.owner.userId),
];

/// Runs [check] on every staged row of [entity], a page at a time.
Future<void> _eachRow(
  AppDatabase db,
  StagedImport import,
  String entity,
  void Function(Map<String, Object?> row) check,
) async {
  var after = '';
  while (true) {
    final page = await stagedRowsWithIds(db, import, entity, afterRowId: after);
    if (page.isEmpty) return;
    for (final (_, row) in page) {
      check(row);
    }
    after = page.last.$1;
  }
}
