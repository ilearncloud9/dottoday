import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/live_activity/live_activity_sink.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_activity_dismissed.g.dart';

/// Whether the user has ever dismissed the live dot themselves: the
/// trigger of minimal mode's widget hint (docs/14 §5, M16). iOS sends one
/// `dismissedByUser` event on `dottoday/live_activity` for a Live Activity
/// (ios/Shared/LiveActivities.swift); Android keeps a swipe of the ongoing
/// notification (OngoingDot.kt) until read with `takeDismissed` on
/// `dottoday/ongoing`, on each build — launch and every resume (R-13). It
/// is kept in `local_meta`, per device and never synced, like the other
/// nudge flags. The hint itself still follows the one-a-day, twice-ever
/// budget.
@Riverpod(keepAlive: true)
class LiveActivityDismissed extends _$LiveActivityDismissed {
  static const _key = 'live_activity_dismissed';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<bool> build() async {
    // Only phones show the live dot outside the app: elsewhere nothing.
    if (kIsWeb) return false;
    final android = defaultTargetPlatform == TargetPlatform.android;
    if (!android && defaultTargetPlatform != TargetPlatform.iOS) return false;
    if (!android) {
      LiveActivitySink.liveActivityChannel.setMethodCallHandler((call) async {
        if (call.method == 'dismissedByUser') await record();
      });
    }
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    if (row != null) return true;
    if (android && await _swipedOnAndroid()) {
      await _remember();
      return true;
    }
    return false;
  }

  /// Android's ongoing notification swiped away since the last read.
  Future<bool> _swipedOnAndroid() async {
    final taken = await LiveActivitySink.ongoingChannel.invokeMethod<bool>(
      'takeDismissed',
    );
    return taken ?? false;
  }

  /// The user dismissed one: remembered for good.
  Future<void> record() async {
    state = const AsyncData(true);
    await _remember();
  }

  Future<void> _remember() => _db
      .into(_db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: _key, value: 'true'),
      );
}
