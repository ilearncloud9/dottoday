import 'package:dottoday/data/search/recent_searches.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/repositories/search_repository.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'timeline_fakes.dart';

/// Word-prefix search over a [FakeOccurrenceRepository], like the FTS
/// index (titles and notes; Trash excluded), live.
final class FakeSearchRepository implements SearchRepository {
  FakeSearchRepository(this.occurrences);

  final FakeOccurrenceRepository occurrences;

  List<Occurrence> _hits(String userId, String query, int limit) {
    if (query.trim().isEmpty) return const [];
    final terms = query.trim().split(RegExp(r'\s+'));
    bool matches(Occurrence o) {
      final text = '${o.title} ${o.notes ?? ''}';
      return terms.every((t) => matchSpans(text, t).isNotEmpty);
    }

    return occurrences.rows
        .where((o) => o.userId == userId && o.deletedAt == null && matches(o))
        .take(limit)
        .toList();
  }

  @override
  Future<List<Occurrence>> search(
    String userId,
    String query, {
    int limit = 50,
  }) async => _hits(userId, query, limit);

  @override
  Stream<List<Occurrence>> watch(
    String userId,
    String query, {
    int limit = 50,
  }) => occurrences.watchInbox(userId).map((_) => _hits(userId, query, limit));
}

/// Recent searches in memory.
final class FakeRecentSearches extends RecentSearches {
  FakeRecentSearches([this.initial = const []]);

  final List<String> initial;

  @override
  Future<List<String>> build() async => initial;

  @override
  Future<void> remember(String query) async =>
      state = AsyncData(withRecent(state.value ?? initial, query));

  @override
  Future<void> clear() async => state = const AsyncData([]);
}
