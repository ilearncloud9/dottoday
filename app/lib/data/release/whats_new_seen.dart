import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/release/releases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'whats_new_seen.g.dart';

/// The newest version whose notes this device has seen (PRD F11, R-19),
/// kept in `local_meta` (per device, never synced: each device updates on
/// its own). The first run records the running version, so a fresh install
/// never hears about "what's new".
@Riverpod(keepAlive: true)
class WhatsNewSeen extends _$WhatsNewSeen {
  static const _key = 'whats_new_seen';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<String> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    if (row != null) return row.value;
    final current = await ref.read(appVersionNameProvider.future);
    await _write(current);
    return current;
  }

  /// Notes up to [version] have been seen: the banner goes.
  Future<void> markSeen(String version) async {
    final seen = await future;
    if (compareVersions(seen, version) >= 0) return;
    state = AsyncData(version);
    await _write(version);
  }

  Future<void> _write(String value) => _db
      .into(_db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: _key, value: value),
      );
}

/// Releases this device hasn't seen the notes of, newest first; empty
/// while loading, on a fresh install or when up to date.
@riverpod
List<Release> unseenReleasesNow(Ref ref) {
  final seen = ref.watch(whatsNewSeenProvider).value;
  final current = ref.watch(appVersionNameProvider).value;
  if (seen == null || current == null) return const [];
  return unseenReleases(seen: seen, current: current);
}
