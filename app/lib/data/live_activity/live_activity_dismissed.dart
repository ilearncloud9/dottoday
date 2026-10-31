import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/live_activity/live_activity_sink.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_activity_dismissed.g.dart';

/// Whether the user has ever dismissed a Live Activity themselves (iOS):
/// the trigger of minimal mode's widget hint (docs/14 §5, M16). The native
/// side sends one `dismissedByUser` event on `dottoday/live_activity`
/// (ios/Shared/LiveActivities.swift); it is kept in `local_meta`, per
/// device and never synced, like the other nudge flags. The hint itself
/// still follows the one-a-day, twice-ever budget.
@Riverpod(keepAlive: true)
class LiveActivityDismissed extends _$LiveActivityDismissed {
  static const _key = 'live_activity_dismissed';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<bool> build() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      LiveActivitySink.liveActivityChannel.setMethodCallHandler((call) async {
        if (call.method == 'dismissedByUser') await record();
      });
    }
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    return row != null;
  }

  /// The user dismissed one: remembered for good.
  Future<void> record() async {
    state = const AsyncData(true);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: _key, value: 'true'),
        );
  }
}
