import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

/// The write that turns [current] into [backup] for [userId] (M2.4).
///
/// Backup rows are re-owned to [userId] and written as they were (Trash
/// rows stay in Trash). Live current rows absent from the backup get
/// `deletedAt = now`, never a hard delete, so the change syncs and stays
/// restorable for 30 days (R-11). The profile keeps [userId] and its
/// original `createdAt`.
///
/// ```dart
/// writes.apply(restorePlan(current: mine, backup: old, userId: me, now: t));
/// ```
WriteBatch restorePlan({
  required ExportBundle current,
  required ExportBundle backup,
  required String userId,
  required DateTime now,
}) {
  final b = backup.reownedTo(userId);
  final seriesIds = {for (final s in b.series) s.id};
  final occurrenceIds = {for (final o in b.occurrences) o.id};
  final subtaskIds = {for (final s in b.subtasks) s.id};
  final routineIds = {for (final r in b.routines) r.id};
  return WriteBatch(
    userId: userId,
    profile: b.profile.copyWith(
      id: userId,
      createdAt: current.profile.createdAt,
    ),
    series: [
      ...b.series,
      for (final s in current.series)
        if (s.deletedAt == null && !seriesIds.contains(s.id))
          s.copyWith(deletedAt: now),
    ],
    occurrences: [
      ...b.occurrences,
      for (final o in current.occurrences)
        if (o.deletedAt == null && !occurrenceIds.contains(o.id))
          o.copyWith(deletedAt: now),
    ],
    subtasks: [
      ...b.subtasks,
      for (final s in current.subtasks)
        if (s.deletedAt == null && !subtaskIds.contains(s.id))
          s.copyWith(deletedAt: now),
    ],
    routines: [
      ...b.routines,
      for (final r in current.routines)
        if (r.deletedAt == null && !routineIds.contains(r.id))
          r.copyWith(deletedAt: now),
    ],
  );
}
