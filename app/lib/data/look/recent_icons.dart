import 'dart:convert';

import 'package:dottoday/core/theme/look_metrics.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/domain/look/recent_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_icons.g.dart';

/// The icons last picked on this device, newest first, at most
/// [DotLook.recentIcons] (ED-086 "Recently used"; owner, 4c: on the
/// device, never synced). Kept in `local_meta` as a JSON list of keys.
@Riverpod(keepAlive: true)
class RecentIcons extends _$RecentIcons {
  static const _key = 'recent_icons';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<List<String>> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    return _decode(row?.value);
  }

  /// Puts [iconKey] first.
  Future<void> use(String iconKey) async {
    final now = state.value ?? await future;
    final next = pushRecent(now, iconKey, max: DotLook.recentIcons);
    state = AsyncData(next);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: _key, value: jsonEncode(next)),
        );
  }

  /// A stored list; anything unreadable is an empty one (it is only a
  /// convenience, never user data).
  static List<String> _decode(String? value) {
    if (value == null) return const [];
    try {
      final list = jsonDecode(value);
      if (list is! List) return const [];
      return [
        for (final k in list)
          if (k is String) k,
      ].take(DotLook.recentIcons).toList();
    } on FormatException {
      return const [];
    }
  }
}
