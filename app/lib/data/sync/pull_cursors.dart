import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:drift/drift.dart';

/// Each owner's pull cursor per synced entity (docs/04 §4): where its next
/// pull starts, kept per owner (CR-160) so accounts never share one.
final class PullCursors {
  PullCursors(this._db);

  final AppDatabase _db;

  /// The start of time: a pull from here brings every row.
  static final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// Whether [owner] has pulled [entity] before.
  Future<bool> has(String owner, String entity) async =>
      await (_db.select(_db.syncCursors)
            ..where((c) => c.ownerId.equals(owner) & c.entity.equals(entity)))
          .getSingleOrNull() !=
      null;

  /// Where [entity]'s next pull starts: after the last row pulled, or
  /// from its instant on for a cursor saved before v17.
  Future<PullCursor> after(String owner, String entity) async {
    final row =
        await (_db.select(_db.syncCursors)
              ..where((c) => c.ownerId.equals(owner) & c.entity.equals(entity)))
            .getSingleOrNull();
    if (row?.sinceAt case final at?) return (updatedAt: at, id: row!.sinceId);
    final since = DateTime.fromMillisecondsSinceEpoch(
      row?.sinceUtc ?? 0,
      isUtc: true,
    );
    return (updatedAt: since.toIso8601String(), id: null);
  }

  /// Inside the caller's transaction: [entity]'s next pull starts after
  /// [last].
  Future<void> save(String owner, String entity, PullCursor last) => _db
      .into(_db.syncCursors)
      .insertOnConflictUpdate(
        SyncCursorsCompanion.insert(
          ownerId: owner,
          entity: entity,
          sinceUtc: DateTime.parse(last.updatedAt).millisecondsSinceEpoch,
          sinceAt: Value(last.updatedAt),
          sinceId: Value(last.id),
        ),
      );
}
