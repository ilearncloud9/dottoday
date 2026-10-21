import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';

/// Rows one user action writes together, all or nothing (docs/09 M2.3).
///
/// Every row must belong to [userId]. A soft delete is a row with
/// `deletedAt` set; nothing is ever hard-deleted through this path.
///
/// ```dart
/// WriteBatch(userId: me, occurrences: [moved, ...shiftedFollowers])
/// ```
final class WriteBatch {
  const WriteBatch({
    required this.userId,
    this.profile,
    this.series = const [],
    this.occurrences = const [],
    this.subtasks = const [],
  });

  final String userId;
  final Profile? profile;

  /// Saved series are (re-)materialised in the same transaction.
  final List<Series> series;
  final List<Occurrence> occurrences;
  final List<Subtask> subtasks;

  /// Whether the batch writes nothing.
  bool get isEmpty =>
      profile == null &&
      series.isEmpty &&
      occurrences.isEmpty &&
      subtasks.isEmpty;

  /// Whether every row is owned by [userId].
  bool get isSingleOwner =>
      (profile == null || profile!.id == userId) &&
      series.every((s) => s.userId == userId) &&
      occurrences.every((o) => o.userId == userId) &&
      subtasks.every((s) => s.userId == userId);
}
