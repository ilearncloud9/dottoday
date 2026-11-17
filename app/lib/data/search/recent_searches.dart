import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_searches.g.dart';

/// Search › RECENT (`A-ios-search`): the last five queries of the owner the
/// app shows, on this device only (`local_meta`, never synced or exported —
/// search terms can be personal, 06 §5). Kept per owner and rebuilt at
/// every change of owner (CR-160 I4): the next person never sees them.
@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  static const kind = 'recent_searches';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// Whose queries [state] holds; null before a profile exists.
  String? _owner;

  @override
  Future<List<String>> build() async {
    ref.watch(ownerEpochProvider);
    _owner = null;
    final owner = await shownOwnerId(_db);
    _owner = owner;
    if (owner == null) return const [];
    final raw = await readOwned(_db, kind, owner);
    final decoded = raw == null ? null : _decode(raw);
    return decoded is List
        ? [for (final q in decoded) ?(q is String ? q : null)]
        : const [];
  }

  /// Puts [query] first (a committed search: submitted or a result opened).
  Future<void> remember(String query) async {
    final epoch = ref.read(ownerEpochProvider);
    final current = state.value ?? await future;
    final owner = _owner;
    // The owner changed meanwhile: the query was the previous owner's and
    // must not land in the next one's list.
    if (owner == null || !ref.mounted) return;
    if (ref.read(ownerEpochProvider) != epoch) return;
    final next = withRecent(current, query);
    state = AsyncData(next);
    await writeOwned(_db, kind, owner, jsonEncode(next));
  }

  /// Forgets the shown owner's recent searches (Settings › Privacy, docs/09
  /// M3f.7).
  Future<void> clear() async {
    await future;
    final owner = _owner;
    state = const AsyncData([]);
    if (owner == null) return;
    await forgetOwned(_db, const [kind], owner);
  }

  static Object? _decode(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
