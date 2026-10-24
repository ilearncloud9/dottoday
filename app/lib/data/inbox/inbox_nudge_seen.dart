import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_nudge_seen.g.dart';

/// The local day the "Plan your inbox" card was last put away (docs/02
/// F3.3), kept in `local_meta` per device and never synced (docs/05): a
/// nudge is a suggestion, and each device's Today asks on its own. Null
/// until the first time.
@Riverpod(keepAlive: true)
class InboxNudgeSeen extends _$InboxNudgeSeen {
  static const _key = 'inbox_nudge_day';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<DateTime?> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  /// Puts the card away for [day] (a local date): it returns tomorrow.
  Future<void> putAway(DateTime day) async {
    final date = DateTime(day.year, day.month, day.day);
    state = AsyncData(date);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(
            key: _key,
            value: date.toIso8601String().substring(0, 10),
          ),
        );
  }
}
