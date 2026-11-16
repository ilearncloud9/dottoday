import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart';

/// The server field versions this device last pulled (ADR-0002): what lets
/// a local edit made on top of them go up unchallenged (`mergeRemote`).
final class FieldSeen {
  FieldSeen(this._db);

  final AppDatabase _db;

  /// The versions last pulled for [ids] of [entity]: id → field → HLC.
  Future<Map<String, Map<String, String>>> seen(
    String entity,
    List<String> ids,
  ) async {
    final rows = await (_db.select(
      _db.fieldSeen,
    )..where((f) => f.entity.equals(entity) & f.entityId.isIn(ids))).get();
    final out = <String, Map<String, String>>{};
    for (final r in rows) {
      (out[r.entityId] ??= {})[r.field] = r.hlc;
    }
    return out;
  }

  /// Records [versions] as pulled for row [id] of [entity].
  Future<void> remember(
    String entity,
    String id,
    Map<String, String> versions,
  ) async {
    for (final MapEntry(key: field, value: hlc) in versions.entries) {
      await _db
          .into(_db.fieldSeen)
          .insertOnConflictUpdate(
            FieldSeenCompanion.insert(
              entity: entity,
              entityId: id,
              field: field,
              hlc: hlc,
            ),
          );
    }
  }
}
