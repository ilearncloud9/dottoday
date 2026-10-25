import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart';

/// Hard-deletes [userId]'s tombstones older than [cutoff] in one
/// transaction and returns how many rows went.
///
/// Kept regardless of age:
/// - dirty rows: the server hasn't seen the delete yet; purging would
///   resurrect the row on the next pull (docs/04 §4).
/// - series-instance tombstones at or after [materialisationStart]: the
///   `Materialiser` reads them as "skip this instance"; without one a
///   deleted future instance would be re-created (M1.3).
Future<int> purgeTombstones(
  AppDatabase db,
  String userId, {
  required DateTime cutoff,
  required DateTime materialisationStart,
}) {
  final c = Variable<int>(cutoff.millisecondsSinceEpoch);
  final u = Variable<String>(userId);
  final m = Variable<int>(materialisationStart.millisecondsSinceEpoch);
  return db.transaction(() async {
    var removed = await db.customUpdate(
      'DELETE FROM subtasks WHERE user_id = ? AND dirty = 0 '
      'AND deleted_at IS NOT NULL AND deleted_at < ?',
      variables: [u, c],
      updates: {db.subtasks},
      updateKind: UpdateKind.delete,
    );
    removed += await db.customUpdate(
      'DELETE FROM occurrences WHERE user_id = ? AND dirty = 0 '
      'AND deleted_at IS NOT NULL AND deleted_at < ? '
      'AND (series_id IS NULL OR original_start_utc < ?) '
      // A subtask still waiting to sync would block the FK cascade's intent.
      'AND id NOT IN (SELECT occurrence_id FROM subtasks WHERE dirty = 1)',
      variables: [u, c, m],
      updates: {db.occurrences},
      updateKind: UpdateKind.delete,
    );
    removed += await db.customUpdate(
      'DELETE FROM series WHERE user_id = ? AND dirty = 0 '
      'AND deleted_at IS NOT NULL AND deleted_at < ?',
      variables: [u, c],
      updates: {db.seriesTable},
      updateKind: UpdateKind.delete,
    );
    removed += await db.customUpdate(
      'DELETE FROM routines WHERE user_id = ? AND dirty = 0 '
      'AND deleted_at IS NOT NULL AND deleted_at < ?',
      variables: [u, c],
      updates: {db.routinesTable},
      updateKind: UpdateKind.delete,
    );
    return removed;
  });
}
