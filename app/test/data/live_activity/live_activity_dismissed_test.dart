import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/live_activity/live_activity_dismissed.dart';
import 'package:dottoday/data/live_activity/live_activity_sink.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The widget hint's trigger (docs/14 §5, M16): iOS sends one
// `dismissedByUser` event when the user swipes a Live Activity away; it
// is kept per device in local_meta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    await db.close();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// The native side calling Dart on `dottoday/live_activity`.
  Future<void> nativeSays(String method) => TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .handlePlatformMessage(
        LiveActivitySink.liveActivityChannel.name,
        const StandardMethodCodec().encodeMethodCall(MethodCall(method)),
        (_) {},
      );

  test('never dismissed: false', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(await container().read(liveActivityDismissedProvider.future), false);
  });

  test('the event is recorded for good, on this device', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final c = container();
    await c.read(liveActivityDismissedProvider.future);
    await nativeSays('dismissedByUser');
    await pumpEventQueue();
    expect(c.read(liveActivityDismissedProvider).value, true);
    expect(await container().read(liveActivityDismissedProvider.future), true);
  });

  test('other calls change nothing', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final c = container();
    await c.read(liveActivityDismissedProvider.future);
    await nativeSays('somethingElse');
    await pumpEventQueue();
    expect(c.read(liveActivityDismissedProvider).value, false);
  });
}
