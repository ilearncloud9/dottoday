// The snoozed Wake Up as a Live Activity at dawn on the iOS 26 simulator
// (docs/09 M20.8 part 5; E-R2-19-B, ED-314; ED-464): the real gateway arms
// the test alarm with E-R2-19-B's sample day, it rings, Snooze counts down
// on the Lock Screen and in the Dynamic Island, and it rings again. The
// runner saves the screen at each `SNOOZE_SHOT` mark while the test holds
// still (the Lock Screen, the island's views and StandBy are the system's,
// out of the app's reach). iOS only.
//   flutter drive --target=integration_test/wake_up_snooze_activity_test.dart
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/domain/notifications/wake_up_arc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';

const _channel = MethodChannel('dottoday/alarm');

/// E-R2-19-B's sample morning from Wake Up, as on Android's ringing test.
const _day = [
  WakeUpArc(from: 0.0104, to: 0.0417, colorKey: 'coral'),
  WakeUpArc(from: 0.0417, to: 0.0528, colorKey: 'amber'),
  WakeUpArc(from: 0.0625, to: 0.0736, colorKey: 'sky'),
  WakeUpArc(from: 0.1042, to: 0.1875, colorKey: 'indigo'),
  WakeUpArc(from: 0.25, to: 0.2812, colorKey: 'rose'),
  WakeUpArc(from: 0.3125, to: 0.3333, colorKey: 'slate'),
  WakeUpArc(from: 0.3542, to: 0.3854, colorKey: 'mint'),
  WakeUpArc(from: 0.4792, to: 0.5208, colorKey: 'violet'),
  WakeUpArc(from: 0.625, to: 0.6458, colorKey: 'brown'),
];

/// Real time, no frames: the app is behind the Lock Screen meanwhile.
Future<void> _until(Future<bool> Function() check, Duration limit) async {
  final end = DateTime.now().add(limit);
  while (DateTime.now().isBefore(end)) {
    if (await check()) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  fail('not within $limit');
}

Future<bool> _ringing() async =>
    await _channel.invokeMethod<String>('ringingId') == WakeUpAlarm.testId;

/// Marks a moment for the runner and holds still while it is saved.
Future<void> _shot(String name, int seconds) async {
  debugPrint('SNOOZE_SHOT $name');
  await Future<void>.delayed(Duration(seconds: seconds));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('snoozed: the dawn countdown, then ringing again', (
    tester,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    final container = await startApp(tester);
    final gateway = container.read(alarmGatewayProvider);
    await gateway.requestAuthorization();
    final alarm = WakeUpAlarm(
      id: WakeUpAlarm.testId,
      fireAtUtc: DateTime.now().toUtc().add(const Duration(seconds: 8)),
      sound: catalogueSound('start.bells')!,
      title: 'Wake Up',
      body: 'First: Morning run at 6:45 AM',
      stopLabel: "I'm up",
      snoozeLabel: 'Snooze',
      snoozeMinutes: 2,
      snoozeLimit: 3,
    ).withArcs(_day);
    expect(await gateway.test(alarm), isTrue, reason: 'AlarmKit armed it');
    await _until(_ringing, const Duration(seconds: 40));
    await _shot('ringing', 8);
    await _channel.invokeMethod<void>('perform', {
      'action': 'snooze',
      'id': WakeUpAlarm.testId,
    });
    await _until(() async => !await _ringing(), const Duration(seconds: 20));
    // Two minutes of countdown: the Lock Screen, the island, StandBy.
    await _shot('snoozed', 90);
    await _until(_ringing, const Duration(seconds: 60));
    await _shot('ringing_again', 30);
    await _channel.invokeMethod<void>('perform', {
      'action': 'stop',
      'id': WakeUpAlarm.testId,
    });
  });
}
