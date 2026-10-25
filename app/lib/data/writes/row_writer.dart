import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/sync/hlc.dart';
import 'package:dottoday/domain/writes/field_changes.dart';
import 'package:drift/drift.dart';

/// How the write path handles one entity type: its synced table name (the
/// `sync_push` entity), JSON form, id, and repository read/upsert.
final class EntityWriter<E> {
  const EntityWriter({
    required this.table,
    required this.toJson,
    required this.idOf,
    required this.stamp,
    required this.find,
    required this.upsertAll,
    this.deviceOnly,
  });

  /// One of the `change_log.entity` values (a fixed literal, never input).
  final String table;
  final Map<String, Object?> Function(E) toJson;
  final String Function(E) idOf;

  /// [E] with `updated_at` set to the write time.
  final E Function(E, DateTime) stamp;
  final Future<E?> Function(String id) find;
  final Future<void> Function(Iterable<E>) upsertAll;

  /// Whether a row stays on this device: written and validated like any
  /// other, but never queued for `sync_push` (docs/05: device-calendar
  /// imports, docs/09 M7.2). Null: every row syncs.
  final Future<bool> Function(E)? deviceOnly;
}

/// Writes rows of one entity type inside the caller's transaction: skips
/// unchanged rows, upserts the rest stamped with [now], marks them dirty and
/// appends one `change_log` row per changed field — except
/// [EntityWriter.deviceOnly] rows, which are only upserted.
Future<void> writeRows<E>(
  AppDatabase db,
  EntityWriter<E> writer,
  Iterable<E> rows, {
  required DateTime now,
  required Hlc Function() nextHlc,
}) async {
  final changed = <E>[];
  final synced = <String>[];
  final log = <ChangeLogCompanion>[];
  for (final row in rows) {
    final previous = await writer.find(writer.idOf(row));
    final json = writer.toJson(row);
    final fields = changedFields(
      previous == null ? null : writer.toJson(previous),
      json,
    );
    if (fields.isEmpty) continue;
    changed.add(writer.stamp(row, now));
    if (await writer.deviceOnly?.call(row) ?? false) continue;
    synced.add(writer.idOf(row));
    final hlc = nextHlc().toString();
    log.addAll([
      for (final f in fields)
        ChangeLogCompanion.insert(
          entity: writer.table,
          entityId: writer.idOf(row),
          field: f,
          value: jsonEncode(json[f]),
          hlc: hlc,
        ),
    ]);
  }
  if (changed.isEmpty) return;
  await writer.upsertAll(changed);
  if (synced.isEmpty) return;
  await _markDirty(db, writer.table, synced);
  await db.batch((b) => b.insertAll(db.changeLog, log));
}

Future<void> _markDirty(AppDatabase db, String table, List<String> ids) {
  final placeholders = List.filled(ids.length, '?').join(', ');
  return db.customUpdate(
    'UPDATE $table SET dirty = 1, version = version + 1 '
    'WHERE id IN ($placeholders)',
    variables: [for (final id in ids) Variable<String>(id)],
    updates: {db.allTables.firstWhere((t) => t.actualTableName == table)},
  );
}
