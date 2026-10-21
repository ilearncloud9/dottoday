import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/repositories/search_repository.dart';
import 'package:dottoday/domain/search/search_query.dart';
import 'package:drift/drift.dart';

/// [SearchRepository] over the FTS5 `search_index` (search.drift).
final class DriftSearchRepository implements SearchRepository {
  DriftSearchRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Occurrence>> search(
    String userId,
    String query, {
    int limit = 50,
  }) async {
    final match = ftsQuery(query);
    if (match == null) return const [];
    // Title hits outrank notes and subtasks (bm25 column weights).
    final rows = await _db
        .customSelect(
          'SELECT o.* FROM search_index s '
          'JOIN occurrences o ON o.rowid = s.rowid '
          'WHERE search_index MATCH ? AND s.user_id = ? '
          'ORDER BY bm25(search_index, 0.0, 10.0, 2.0, 2.0), '
          'o.start_utc DESC, o.id '
          'LIMIT ?',
          variables: [
            Variable<String>(match),
            Variable<String>(userId),
            Variable<int>(limit),
          ],
          readsFrom: {_db.occurrences, _db.searchIndex},
        )
        .get();
    return [
      for (final r in rows)
        occurrenceFromRow(await _db.occurrences.mapFromRow(r)),
    ];
  }
}
