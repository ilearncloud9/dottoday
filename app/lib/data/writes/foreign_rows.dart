/// No write ever takes a row from another local owner (CR-160 Finding X).
///
/// The write path looks rows up by `(owner, id)`, so a row another owner on
/// this device holds looks new, and an upsert by id would then rewrite its
/// `user_id`: an import or backup restore re-owns every row in the file to
/// the importing owner, so a file holding another account's ids (that
/// account's own export, or an old guest backup of work since moved into
/// an account) took those rows over. These checks read the row's actual
/// owner in the database, never through an owner-filtered lookup.
library;

import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart';

/// Thrown inside a write transaction when a row id of [table] is held by
/// another owner: the transaction rolls back, and nothing is written.
final class ForeignRowException implements Exception {
  const ForeignRowException(this.table);

  /// Which table (a fixed literal, never content).
  final String table;

  @override
  String toString() => 'ForeignRowException($table)';
}

/// Tables whose rows carry `user_id` and may be written by the write path.
const ownerCheckedTables = {
  'series',
  'occurrences',
  'subtasks',
  'routines',
  'reveal_hints',
  'calendar_series',
};

/// Throws [ForeignRowException] when any of [ids] in [table] belongs to an
/// owner other than [owner]. `profiles` is checked by id: a profile row
/// can only be its own owner's.
Future<void> checkNoForeignRows(
  AppDatabase db,
  String table,
  String owner,
  Iterable<String> ids,
) async {
  if (table == 'profiles') {
    if (ids.any((id) => id != owner)) throw ForeignRowException(table);
    return;
  }
  if (!ownerCheckedTables.contains(table)) {
    throw ArgumentError.value(table, 'table', 'not an owned table');
  }
  final list = ids.toList();
  for (var i = 0; i < list.length; i += _chunk) {
    final chunk = list.sublist(i, (i + _chunk).clamp(0, list.length));
    final marks = List.filled(chunk.length, '?').join(', ');
    final held = await db
        .customSelect(
          'SELECT 1 FROM $table WHERE user_id <> ? AND id IN ($marks) LIMIT 1',
          variables: [
            Variable<String>(owner),
            for (final id in chunk) Variable<String>(id),
          ],
        )
        .getSingleOrNull();
    if (held != null) throw ForeignRowException(table);
  }
}

/// The first table in [idsByTable] with an id another owner holds, or
/// null: an import or restore asks this before it takes its safety backup
/// or changes anything.
Future<String?> foreignRowTable(
  AppDatabase db,
  String owner,
  Map<String, Iterable<String>> idsByTable,
) async {
  for (final MapEntry(key: table, value: ids) in idsByTable.entries) {
    try {
      await checkNoForeignRows(db, table, owner, ids);
    } on ForeignRowException {
      return table;
    }
  }
  return null;
}

const _chunk = 500;
