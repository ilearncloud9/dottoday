import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_searches.g.dart';

/// Search › RECENT (`A-ios-search`): the last five queries, on this device
/// only (`local_meta`, never synced or exported — search terms can be
/// personal, 06 §5).
@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  static const _key = 'recent_searches';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<List<String>> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    if (row == null) return const [];
    final decoded = jsonDecode(row.value);
    return decoded is List
        ? [for (final q in decoded) ?(q is String ? q : null)]
        : const [];
  }

  /// Puts [query] first (a committed search: submitted or a result opened).
  Future<void> remember(String query) async {
    final next = withRecent(state.value ?? await future, query);
    state = AsyncData(next);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: _key, value: jsonEncode(next)),
        );
  }

  /// Forgets every recent search (Settings › Privacy, docs/09 M3f.7).
  Future<void> clear() async {
    state = const AsyncData([]);
    await (_db.delete(_db.localMeta)..where((m) => m.key.equals(_key))).go();
  }
}
