import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:drift/drift.dart';

/// Puts every row [owner] holds on this device back in the outbox, and
/// nobody else's (CR-160). With [only] (entity → ids), just those rows:
/// guest work brought into an account, whose server has none of it, while
/// the account's other rows keep their own clocks. Current values, fresh
/// clocks; inside the caller's transaction. Device-calendar imports and
/// their subtasks stay out (docs/09 M7.2).
Future<void> requeueOwner(
  AppDatabase db,
  String owner,
  SharedHlc hlc, {
  Map<String, Set<String>>? only,
}) async {
  final clock = await hlc.clock();
  final occurrences = [
    for (final r in await (db.select(
      db.occurrences,
    )..where((o) => o.userId.equals(owner))).get())
      occurrenceFromRow(r),
  ];
  final local = {
    for (final o in occurrences)
      if (isDeviceOnly(o)) o.id,
  };
  final rows = <(String, String, Map<String, Object?>)>[
    for (final r in await (db.select(
      db.profiles,
    )..where((p) => p.id.equals(owner))).get())
      ('profiles', r.id, profileFromRow(r).toJson()),
    for (final r in await (db.select(
      db.seriesTable,
    )..where((s) => s.userId.equals(owner))).get())
      ('series', r.id, seriesFromRow(r).toJson()),
    for (final o in occurrences)
      if (!local.contains(o.id)) ('occurrences', o.id, o.toJson()),
    for (final r in await (db.select(
      db.subtasks,
    )..where((s) => s.userId.equals(owner))).get())
      if (!local.contains(r.occurrenceId))
        ('subtasks', r.id, subtaskFromRow(r).toJson()),
    for (final r in await (db.select(
      db.routinesTable,
    )..where((r) => r.userId.equals(owner))).get())
      ('routines', r.id, routineFromRow(r).toJson()),
    for (final r in await (db.select(
      db.revealHintsTable,
    )..where((h) => h.userId.equals(owner))).get())
      ('reveal_hints', r.id, revealHintFromRow(r).toJson()),
  ];
  final picked = only == null
      ? rows
      : [
          for (final r in rows)
            if (only[r.$1]?.contains(r.$2) ?? false) r,
        ];
  if (only == null) {
    await (db.delete(db.changeLog)..where((c) => c.ownerId.equals(owner))).go();
  } else {
    for (final (entity, id, _) in picked) {
      await (db.delete(db.changeLog)..where(
            (c) =>
                c.ownerId.equals(owner) &
                c.entity.equals(entity) &
                c.entityId.equals(id),
          ))
          .go();
    }
  }
  await db.batch((b) {
    for (final (entity, id, json) in picked) {
      final at = clock.now().toString();
      for (final field in pushableColumns[entity]!) {
        if (!json.containsKey(field)) continue;
        b.insert(
          db.changeLog,
          ChangeLogCompanion.insert(
            ownerId: owner,
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
