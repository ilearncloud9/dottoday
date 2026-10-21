import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:drift/drift.dart';

/// Reads everything [userId] owns, Trash included, as an [ExportBundle]
/// (the backup and export format, docs/05 "Export format"). Run it inside a
/// transaction for a consistent cut. Returns null if the profile is missing.
Future<ExportBundle?> readUserData(
  AppDatabase db,
  String userId,
  DateTime nowUtc,
) async {
  final profile = await (db.select(
    db.profiles,
  )..where((p) => p.id.equals(userId))).getSingleOrNull();
  if (profile == null) return null;
  final series =
      await (db.select(db.seriesTable)
            ..where((s) => s.userId.equals(userId))
            ..orderBy([(s) => OrderingTerm(expression: s.id)]))
          .get();
  final occurrences =
      await (db.select(db.occurrences)
            ..where((o) => o.userId.equals(userId))
            ..orderBy([(o) => OrderingTerm(expression: o.id)]))
          .get();
  final subtasks =
      await (db.select(db.subtasks)
            ..where((s) => s.userId.equals(userId))
            ..orderBy([(s) => OrderingTerm(expression: s.id)]))
          .get();
  return ExportBundle(
    exportedAt: nowUtc,
    profile: profileFromRow(profile),
    series: series.map(seriesFromRow).toList(),
    occurrences: occurrences.map(occurrenceFromRow).toList(),
    subtasks: subtasks.map(subtaskFromRow).toList(),
  );
}
