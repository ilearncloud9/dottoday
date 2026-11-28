import 'package:dottoday/data/layout/reduce_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reduce Transparency, which Flutter does not report (ED-248 C): asked of
/// iOS and macOS over `dottoday/reduce_transparency`, false elsewhere.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dottoday/reduce_transparency');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  Future<List<bool>> read(ProviderContainer container, int count) async {
    final seen = <bool>[];
    final sub = container.listen(
      reduceTransparencyProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    for (var i = 0; i < 20 && seen.length < count; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    sub.close();
    return seen;
  }

  test('Android: false, the platform is not asked', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    var asked = false;
    messenger.setMockMethodCallHandler(channel, (_) async {
      asked = true;
      return true;
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(await read(container, 1), [false]);
    expect(asked, isFalse);
  });

  test('iOS without the native side: false', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(await read(container, 1), [false]);
  });

  test('iOS: the setting now, then its changes', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'get');
      return true;
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final seen = <bool>[];
    final sub = container.listen(
      reduceTransparencyProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    addTearDown(sub.close);
    for (var i = 0; i < 20 && seen.isEmpty; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(seen, [true]);
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall('changed', false)),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);
    expect(seen, [true, false]);
  });
}
