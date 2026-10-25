import 'dart:io';

import 'package:dottoday/data/focus/channel_deep_work.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/focus/deep_work.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// 11 A3 / docs/09 M10.5: Deep work never silences the alarm channel. Do
// Not Disturb is only ever the alarms-only level, the native side refuses
// any other, and dot-start alarms are alarm-usage audio, which that level
// lets through.

const _kotlin =
    'android/app/src/main/kotlin/app/dottoday/planner/focus/DeepWork.kt';

final class _Links implements LinkLauncher {
  @override
  Future<bool> open(Uri uri, {bool sameWindow = false}) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the one level asked for is alarms-only', () {
    expect(deepWorkDndLevel, 'alarms');
  });

  test('Kotlin sets alarms-only or back to all, nothing quieter', () {
    final source = File(_kotlin).readAsStringSync();
    expect(source, contains('INTERRUPTION_FILTER_ALARMS'));
    expect(source, isNot(contains('INTERRUPTION_FILTER_NONE')));
    expect(source, isNot(contains('INTERRUPTION_FILTER_PRIORITY')));
    expect(source, contains('"alarms"'), reason: 'refuses other levels');
    expect(source, isNot(contains('setNotificationPolicy')));
  });

  test('dot-start alarms are alarm-usage audio', () {
    final source = File(
      'lib/data/notifications/fln_notification_platform.dart',
    ).readAsStringSync();
    expect(source, contains('AudioAttributesUsage.alarm'));
  });

  test('turnOn sends the alarms level and the planned end', () async {
    const channel = MethodChannel('dottoday/deep_work');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    MethodCall? sent;
    messenger.setMockMethodCallHandler(channel, (call) async {
      sent = call;
      return true;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final gateway = ChannelDeepWork(_Links(), kind: DeepWorkKind.dnd);
    final end = DateTime.utc(2026, 10, 21, 9);
    expect(await gateway.turnOn(end), isTrue);
    expect(sent!.method, 'turnOn');
    expect(sent!.arguments, {
      'level': 'alarms',
      'until_ms': end.millisecondsSinceEpoch,
    });
  });

  test('iPhone/Mac and the web never call the channel', () async {
    for (final kind in [DeepWorkKind.shortcuts, DeepWorkKind.none]) {
      final gateway = ChannelDeepWork(_Links(), kind: kind);
      expect(await gateway.turnOn(DateTime.utc(2026)), isFalse);
      expect((await gateway.status()).kind, kind);
    }
  });
}
