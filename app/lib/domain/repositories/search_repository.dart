import 'package:dottoday/domain/entities/occurrence.dart';

/// Full-text search over task titles, notes and subtasks, including done
/// tasks; Trash is excluded (docs/02 F8, R-11).
abstract interface class SearchRepository {
  /// Up to [limit] of [userId]'s occurrences matching every term of
  /// [query] (prefix match, case- and accent-insensitive), best match
  /// first, then most recent start. Empty for a blank query.
  Future<List<Occurrence>> search(
    String userId,
    String query, {
    int limit = 50,
  });
}
