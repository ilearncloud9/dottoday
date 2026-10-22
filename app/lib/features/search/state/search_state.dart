import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'search_state.g.dart';

/// Most results fetched; more is a sign to type more.
const searchResultLimit = 200;

/// What is typed and the picked chip.
@immutable
final class SearchInput {
  const SearchInput({this.text = '', this.filter = const AnyResult()});

  final String text;
  final SearchFilter filter;

  SearchInput copyWith({String? text, SearchFilter? filter}) =>
      SearchInput(text: text ?? this.text, filter: filter ?? this.filter);
}

/// The Search tab's field and chip (kept while the tab is alive).
@riverpod
class SearchInputState extends _$SearchInputState {
  @override
  SearchInput build() => const SearchInput();

  void type(String text) => state = state.copyWith(text: text);

  void pick(SearchFilter filter) => state = state.copyWith(filter: filter);
}

/// Live FTS hits for [query] (docs/02 F8, R-11: done tasks included).
/// Dependencies are read synchronously (see `timelineData`).
@riverpod
Stream<List<Occurrence>> searchHits(Ref ref, String query) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(searchRepositoryProvider);
  return Stream.fromFuture(
    profile,
  ).asyncExpand((p) => repo.watch(p.id, query, limit: searchResultLimit));
}

/// What the results list shows.
@immutable
final class SearchView {
  const SearchView({
    required this.groups,
    required this.count,
    required this.today,
    required this.nowUtc,
    required this.location,
    required this.use24h,
  });

  final Map<ResultGroup, List<Occurrence>> groups;
  final int count;
  final DateTime today;
  final DateTime nowUtc;
  final tz.Location location;

  /// The user's setting (null follows the OS).
  final bool? use24h;
}

/// The hits for the current input, filtered and grouped (null while
/// loading; an empty query gives no groups).
@riverpod
SearchView? searchView(Ref ref) {
  final input = ref.watch(searchInputStateProvider);
  final profile = ref.watch(currentProfileProvider).value;
  final now = ref.watch(minuteTickProvider).value;
  if (profile == null || now == null) return null;
  final hits = input.text.trim().isEmpty
      ? const <Occurrence>[]
      : ref.watch(searchHitsProvider(input.text.trim())).value;
  if (hits == null) return null;
  final zone = tz.getLocation(profile.tzId);
  final local = tz.TZDateTime.from(now, zone);
  final today = DateTime(local.year, local.month, local.day);
  final kept = [
    for (final o in hits)
      if (passes(
        o,
        input.filter,
        today: today,
        location: zone,
        firstDayOfWeek: profile.settings.firstDayOfWeek,
      ))
        o,
  ];
  return SearchView(
    groups: groupResults(kept, zone, today: today),
    count: kept.length,
    today: today,
    nowUtc: now,
    location: zone,
    use24h: profile.settings.use24h,
  );
}
