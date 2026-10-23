import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';

/// Puts every row on this device back in the outbox (docs/09 M6.5): after
/// the account it synced with is deleted, or another account signs in,
/// that server has none of it, while the outbox only holds what was never
/// sent. Current values, fresh clocks; inside the caller's transaction.
Future<void> requeueAll(AppDatabase db, SharedHlc hlc) async {
  final clock = await hlc.clock();
  final rows = <(String, String, Map<String, Object?>)>[
    for (final r in await db.select(db.profiles).get())
      ('profiles', r.id, profileFromRow(r).toJson()),
    for (final r in await db.select(db.seriesTable).get())
      ('series', r.id, seriesFromRow(r).toJson()),
    for (final r in await db.select(db.occurrences).get())
      ('occurrences', r.id, occurrenceFromRow(r).toJson()),
    for (final r in await db.select(db.subtasks).get())
      ('subtasks', r.id, subtaskFromRow(r).toJson()),
  ];
  await db.delete(db.changeLog).go();
  await db.batch((b) {
    for (final (entity, id, json) in rows) {
      final at = clock.now().toString();
      for (final field in pushableColumns[entity]!) {
        if (!json.containsKey(field)) continue;
        b.insert(
          db.changeLog,
          ChangeLogCompanion.insert(
            entity: entity,
            entityId: id,
            field: field,
            value: jsonEncode(json[field]),
            hlc: at,
          ),
        );
      }
    }
  });
  await hlc.save();
}
