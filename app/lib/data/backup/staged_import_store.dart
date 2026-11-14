/// The staging area of the staged import (CR-160 Stage B2,
/// docs/cr-160-multipart-export.md §5–§6, ADR-0019 D4): rows of one import
/// held in the encrypted main database until the commit (B3) applies them
/// in one transaction. Nothing calls this outside tests until the pipeline
/// goes live (B3–B5); it is the only code that touches `import_sessions`
/// and `import_staging` (policy-tested), and it runs in the app's main
/// isolate only (cross_runtime_fence_test.dart).
///
/// Every write is fenced like a sync pull (`checkPull`): the import's owner
/// must still be shown, in the same owner session it began in, not sealed
/// for deletion and not being removed. Reads are always filtered by import
/// id and owner, so one owner never sees another's staging. Account
/// removal deletes the owner's staging; [cleanUpStaleImports] deletes what
/// an earlier run or a day-old import left behind.
library;

import 'dart:convert';

import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:drift/drift.dart';

/// How long an import may stay staged (decision 3, provisional).
const stagedImportLifetime = Duration(hours: 24);

/// Largest import staging accepts in total (decision 1, provisional until
/// the spec §7 measurements): the 60 MB reference account with headroom.
const maxStagedImportBytes = 64 * 1024 * 1024;

/// Why staging refused. Never content, so it can be logged.
enum StagingRefusal {
  /// The owner changed, is sealed for deletion or is being removed.
  ownerChanged,

  /// Another import of this owner is still staged.
  busy,

  /// Over [maxStagedImportBytes], or more than the import declared.
  tooLarge,

  /// No such import for this owner (finished, discarded or cleaned up).
  unknownImport,

  /// A row without a usable id, or an id staged twice.
  badRow,
}

final class StagingRefusedException implements Exception {
  const StagingRefusedException(this.reason);
  final StagingRefusal reason;

  @override
  String toString() => 'StagingRefusedException($reason)';
}

/// One import being staged: its id and the owner session it began in.
typedef StagedImport = ({String importId, PullOwner owner});

/// Begins an import of [declaredBytes] for [userId], the owner shown, as
/// [importId] (a fresh UUID) in app run [runId]. Refuses another import of
/// the same owner unless it is stale; refuses an oversized one.
Future<StagedImport> beginStagedImport(
  AppDatabase db,
  String userId, {
  required String importId,
  required int declaredBytes,
  required String runId,
  required DateTime nowUtc,
}) => db.transaction(() async {
  final owner = await _session(db, userId);
  if (declaredBytes < 0 || declaredBytes > maxStagedImportBytes) {
    throw const StagingRefusedException(StagingRefusal.tooLarge);
  }
  await cleanUpStaleImports(db, runId: runId, nowUtc: nowUtc);
  final busy = await (db.select(
    db.importSessions,
  )..where((s) => s.owner.equals(userId))).getSingleOrNull();
  if (busy != null) throw const StagingRefusedException(StagingRefusal.busy);
  await db
      .into(db.importSessions)
      .insert(
        ImportSessionsCompanion.insert(
          importId: importId,
          owner: userId,
          ownerGeneration: owner.generation,
          runId: runId,
          startedAt: nowUtc.millisecondsSinceEpoch,
          declaredBytes: declaredBytes,
        ),
      );
  return (importId: importId, owner: owner);
});

/// Stages one part's [rows] (per table, v1 storage form) and, for part 1,
/// its [profile]. All or nothing: a refusal stages none of them.
Future<void> stagePart(
  AppDatabase db,
  StagedImport import, {
  required int partIndex,
  required Map<String, List<Map<String, Object?>>> rows,
  Map<String, Object?>? profile,
}) => db.transaction(() async {
  await checkStagedImport(db, import);
  final staged = [
    if (profile != null) ('profile', profile),
    for (final MapEntry(key: table, value: list) in rows.entries)
      for (final row in list) (table, row),
  ];
  var bytes = 0;
  for (final (entity, row) in staged) {
    final id = entity == 'profile' ? 'profile' : row['id'];
    if (id is! String || id.isEmpty || id.length > 64) {
      throw const StagingRefusedException(StagingRefusal.badRow);
    }
    final json = jsonEncode(row);
    bytes += utf8.encode(json).length;
    await _insert(db, import, entity, id, partIndex, json);
  }
  final grew = await db.customUpdate(
    'UPDATE import_sessions SET staged_bytes = staged_bytes + ? '
    'WHERE import_id = ? AND owner = ? '
    'AND staged_bytes + ? <= declared_bytes',
    variables: [
      Variable.withInt(bytes),
      Variable.withString(import.importId),
      Variable.withString(import.owner.userId),
      Variable.withInt(bytes),
    ],
    updates: {db.importSessions},
  );
  if (grew != 1) throw const StagingRefusedException(StagingRefusal.tooLarge);
});

Future<void> _insert(
  AppDatabase db,
  StagedImport import,
  String entity,
  String id,
  int partIndex,
  String json,
) async {
  try {
    await db
        .into(db.importStaging)
        .insert(
          ImportStagingCompanion.insert(
            importId: import.importId,
            owner: import.owner.userId,
            entity: entity,
            rowId: id,
            partIndex: partIndex,
            json: json,
          ),
        );
  } on Exception {
    // A duplicate id, or a row the table's CHECKs refuse.
    throw const StagingRefusedException(StagingRefusal.badRow);
  }
}

/// Up to [limit] staged rows of [entity], after [afterRowId], in id order
/// (keyset pages). Only [import]'s, only its owner's.
Future<List<Map<String, Object?>>> stagedRows(
  AppDatabase db,
  StagedImport import,
  String entity, {
  String afterRowId = '',
  int limit = 500,
}) async => [
  for (final (_, row) in await stagedRowsWithIds(
    db,
    import,
    entity,
    afterRowId: afterRowId,
    limit: limit,
  ))
    row,
];

/// [stagedRows] with each row's staging key (for the next page).
Future<List<(String, Map<String, Object?>)>> stagedRowsWithIds(
  AppDatabase db,
  StagedImport import,
  String entity, {
  String afterRowId = '',
  int limit = 500,
}) async {
  final rows = await db
      .customSelect(
        'SELECT row_id, json FROM import_staging WHERE import_id = ? AND '
        'owner = ? AND entity = ? AND row_id > ? ORDER BY row_id LIMIT ?',
        variables: [
          Variable.withString(import.importId),
          Variable.withString(import.owner.userId),
          Variable.withString(entity),
          Variable.withString(afterRowId),
          Variable.withInt(limit),
        ],
        readsFrom: {db.importStaging},
      )
      .get();
  return [
    for (final r in rows)
      (
        r.read<String>('row_id'),
        jsonDecode(r.read<String>('json')) as Map<String, Object?>,
      ),
  ];
}

/// Deletes [import] and its staged rows (after commit or on any failure).
Future<void> discardStagedImport(AppDatabase db, StagedImport import) =>
    (db.delete(db.importSessions)..where(
          (s) =>
              s.importId.equals(import.importId) &
              s.owner.equals(import.owner.userId),
        ))
        .go();

/// This app run's id: imports it begins are its own, and
/// [cleanUpStaleImports] removes those of any other run. One per isolate,
/// and only the main isolate imports (CR-160 B5).
final importRunId = const UuidV7Generator().newId();

/// Deletes every import begun by another app run, or begun more than
/// [stagedImportLifetime] before [nowUtc] (or "in the future": a clock set
/// back). Main isolate only: the background isolate never cleans up, so it
/// can't remove an import the app is staging. Returns how many went.
Future<int> cleanUpStaleImports(
  AppDatabase db, {
  required String runId,
  required DateTime nowUtc,
}) {
  final now = nowUtc.millisecondsSinceEpoch;
  return db.customUpdate(
    'DELETE FROM import_sessions WHERE run_id <> ? OR started_at > ? '
    'OR started_at <= ?',
    variables: [
      Variable.withString(runId),
      Variable.withInt(now),
      Variable.withInt(now - stagedImportLifetime.inMilliseconds),
    ],
    updates: {db.importSessions, db.importStaging},
    updateKind: UpdateKind.delete,
  );
}

/// Inside the caller's transaction: [import] still exists and its owner
/// is still shown in the session it began in, live. Throws
/// [StagingRefusedException] otherwise (the commit runs it too).
Future<void> checkStagedImport(AppDatabase db, StagedImport import) async {
  try {
    await checkPull(db, import.owner);
  } on PullRefusedException {
    throw const StagingRefusedException(StagingRefusal.ownerChanged);
  }
  final held =
      await (db.select(db.importSessions)..where(
            (s) =>
                s.importId.equals(import.importId) &
                s.owner.equals(import.owner.userId) &
                s.ownerGeneration.equals(import.owner.generation),
          ))
          .getSingleOrNull();
  if (held == null) {
    throw const StagingRefusedException(StagingRefusal.unknownImport);
  }
}

Future<PullOwner> _session(AppDatabase db, String userId) async {
  try {
    final owner = (userId: userId, generation: await ownerGeneration(db));
    await checkPull(db, owner);
    return owner;
  } on PullRefusedException {
    throw const StagingRefusedException(StagingRefusal.ownerChanged);
  }
}
