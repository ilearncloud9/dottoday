import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/focus/channel_deep_work.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/focus/deep_work.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_providers.g.dart';

/// Deep work's quiet mode for this build (docs/09 M10.5).
@Riverpod(keepAlive: true)
DeepWorkGateway deepWorkGateway(Ref ref) =>
    ChannelDeepWork(ref.watch(linkLauncherProvider));

/// Deep work here now; re-read with `ref.invalidate` after Settings.
@riverpod
Future<DeepWorkStatus> deepWorkStatus(Ref ref) =>
    ref.watch(deepWorkGatewayProvider).status();

/// Focus's "Chime every 15 min" (off by default, 11 A3): a sound on this
/// device, so remembered here only (`local_meta`), never synced.
@Riverpod(keepAlive: true)
class FocusChime extends _$FocusChime {
  static const _key = 'focus_chime';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<bool> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    return row?.value == 'on';
  }

  Future<void> set({required bool on}) async {
    state = AsyncData(on);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: _key, value: on ? 'on' : 'off'),
        );
  }
}
