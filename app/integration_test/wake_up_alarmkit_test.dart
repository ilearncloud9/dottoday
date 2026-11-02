// The Wake Up alarm through AlarmKit on the iOS 26 simulator (docs/15 W1b,
// ADR-0017): armed through the real AlarmGateway, AlarmKit alerts at its
// time; Snooze counts down and alerts again; after a snooze on a mission
// morning Stop opens the mission and the alarm comes back a minute later.
// tool/device_tests.sh keeps the app in front (DEVICE_HOLD), as each
// alert sends it away. iOS only; Android has wake_up_alarm_test.dart.
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'live_activity_test.dart' show waitUntil;
import 'support/cal_app.dart';

const _channel = MethodChannel('dottoday/alarm');

Future<String?> _ringing() => _channel.invokeMethod<String>('ringingId');

Future<Map<Object?, Object?>?> _stored(String id) async {
  final all = await _channel.invokeListMethod<Map<Object?, Object?>>('stored');
  return all?.where((a) => a['id'] == id).firstOrNull;
}

Future<void> _press(String action, String id) =>
    _channel.invokeMethod<void>('perform', {'action': action, 'id': id});

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AlarmKit rings, snoozes, and opens the mission', (tester) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    final container = await startApp(tester);
    final gateway = container.read(alarmGatewayProvider);
    await gateway.requestAuthorization();
    expect(await _channel.invokeMethod<String>('alarmKitStatus'), 'authorized');

    // Each alert sends the app away; the runner brings it back.
    debugPrint('DEVICE_HOLD front');
    final alarm = WakeUpAlarm(
      id: WakeUpAlarm.testId,
      fireAtUtc: DateTime.now().toUtc().add(const Duration(seconds: 5)),
      sound: catalogueSound('start.bells')!,
      title: 'Wake Up',
      body: 'Device check',
      stopLabel: "I'm up",
      snoozeLabel: 'Snooze',
      snoozeMinutes: 9,
      snoozeLimit: 3,
      rampSeconds: 15,
    );
    expect(await gateway.test(alarm), isTrue, reason: 'AlarmKit armed it');
    await waitUntil(
      tester,
      () async => await _ringing() == WakeUpAlarm.testId,
      timeout: const Duration(seconds: 30),
    );
    debugPrint('DEVICE_SHOT alarmkit_ringing');
    await Future<void>.delayed(const Duration(seconds: 3));
    await _press('snooze', WakeUpAlarm.testId);
    await waitUntil(tester, () async => await _ringing() == null);
    final snoozed = await _stored(WakeUpAlarm.testId);
    expect(snoozed?['state'], 'countdown');
    expect(snoozed?['snoozes'], 1);
    await _press('stop', WakeUpAlarm.testId);
    expect(await _stored(WakeUpAlarm.testId), isNull);

    // A mission "only after a snooze", snoozing a minute: the second ring's
    // Stop opens the mission and arms the ring again a minute out.
    const id = 'wakeup:2099-01-02';
    await _channel.invokeMethod<Object>('sync', {
      'alarms': [
        {
          'id': id,
          'fireAtMs': DateTime.now().millisecondsSinceEpoch + 5000,
          'sound': 'start_bells.caf',
          'title': 'Wake Up',
          'body': 'Device check',
          'stop': "I'm up",
          'snooze': 'Snooze',
          'snoozeMin': 1,
          'snoozeLimit': 3,
          'rampSec': 0,
          'minimal': false,
          'mission': 'standUp',
          'missionAfterSnooze': true,
        },
      ],
      'started': <String>[],
    });
    await waitUntil(
      tester,
      () async => await _ringing() == id,
      timeout: const Duration(seconds: 30),
    );
    await _press('snooze', id);
    await waitUntil(
      tester,
      () async => await _ringing() == id,
      timeout: const Duration(seconds: 90),
    );
    debugPrint('DEVICE_SHOT alarmkit_snooze_rang');
    await Future<void>.delayed(const Duration(seconds: 3));
    await _channel.invokeMethod<Object>('drainEvents');
    await _press('up', id);
    final events = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'drainEvents',
    );
    expect(events?.map((e) => e['kind']), contains('mission'));
    final quiet = await _stored(id);
    expect(quiet?['state'], 'scheduled', reason: 'it rings again');
    final reRing = quiet!['fireAtMs']! as int;
    expect(
      reRing - DateTime.now().millisecondsSinceEpoch,
      inInclusiveRange(50000, 61000),
    );
    await _channel.invokeMethod<void>('dismiss', {'id': id});
    expect(await _stored(id), isNull);
    debugPrint('DEVICE_RELEASE front');
  });
}
