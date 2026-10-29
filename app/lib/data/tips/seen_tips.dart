import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'seen_tips.g.dart';

/// One-time hints a person can put away for good (docs/09 M14): each is a
/// `local_meta` key on this device, never synced or exported — a hint is
/// a suggestion, and each device asks on its own.
enum Tip {
  /// "Made with simple rules · Turn on …" under a proposal's subtitle
  /// (M14.2); one flag for Break it down and Brain dump (D4).
  thinkingHint('tip_thinking_hint'),

  /// Today's "Ask Siri …" card (M14.3, iPhone).
  siriToday('tip_siri_today'),

  /// Brain dump's first-use card on how dictation splits lines (M14.5).
  dictationLines('tip_dictation_lines');

  const Tip(this.key);

  /// The `local_meta` key; stable, never renamed.
  final String key;
}

/// The [Tip]s put away on this device. Each write is persisted before the
/// state is published, and awaited (as `LearningMeta`).
@Riverpod(keepAlive: true)
class SeenTips extends _$SeenTips {
  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<Set<Tip>> build() async {
    final keys = {for (final t in Tip.values) t.key: t};
    final rows = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.isIn(keys.keys))).get();
    return {for (final r in rows) ?keys[r.key]};
  }

  /// Puts [tip] away for good.
  Future<void> putAway(Tip tip) async {
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: tip.key, value: '1'),
        );
    final seen = state.value ?? await future;
    state = AsyncData({...seen, tip});
  }
}
