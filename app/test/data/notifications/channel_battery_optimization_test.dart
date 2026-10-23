import 'package:dottoday/data/notifications/channel_battery_optimization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// The `dottoday/power` channel (docs/09 M6.5.5).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dottoday/power');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('reads the restriction and opens the system list', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return call.method == 'isRestricted' ? true : null;
    });
    const power = ChannelBatteryOptimization();
    expect(await power.restricted(), isTrue);
    await power.openSettings();
    expect(calls, ['isRestricted', 'openSettings']);
  });

  test('no handler (older build, tests) reads as not restricted', () async {
    expect(await const ChannelBatteryOptimization().restricted(), isFalse);
  });
}
