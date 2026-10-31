// The Wake Up alarm on the Android emulator (docs/15 W1b, ADR-0017): armed
// through the real AlarmGateway, it rings in WakeUpRingService at its time;
// Snooze arms it again with the count raised, and "I'm up" forgets it.
// Exact alarms and notifications: tool/device_tests.sh grants them. Android
// only; AlarmKit (iOS 26) is the real-device gate in docs/08 §6.1 C.
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rings at its time; Snooze re-arms once; I am up forgets it', (
    tester,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final container = await startApp(tester);
    final gateway = container.read(alarmGatewayProvider);
    final alarm = WakeUpAlarm(
      id: WakeUpAlarm.testId,
      fireAtUtc: DateTime.now().toUtc().add(const Duration(seconds: 3)),
      sound: catalogueSound('start.bells')!,
      title: 'Wake Up',
      body: 'Device check',
      stopLabel: "I'm up",
      snoozeLabel: 'Snooze',
      snoozeMinutes: 9,
      snoozeLimit: 3,
      rampSeconds: 15,
    );
    expect(await gateway.test(alarm), isTrue);
    await waitUntil(
      tester,
      () async => await _ringing() == WakeUpAlarm.testId,
      timeout: const Duration(seconds: 30),
    );

    await _channel.invokeMethod<void>('perform', {
      'action': 'snooze',
      'id': WakeUpAlarm.testId,
    });
    await waitUntil(tester, () async => await _ringing() == null);
    final snoozed = await _stored(WakeUpAlarm.testId);
    expect(snoozed?['state'], 'snoozed');
    expect(snoozed?['snoozes'], 1);

    // A resync leaves the snoozed test alarm alone: only "I'm up" ends it.
    expect(await gateway.sync(const []), isEmpty);
    expect(await _stored(WakeUpAlarm.testId), isNotNull);

    await _channel.invokeMethod<void>('perform', {
      'action': 'stop',
      'id': WakeUpAlarm.testId,
    });
    expect(await _stored(WakeUpAlarm.testId), isNull);
  });

  // The Wake Up Check (docs/15 W3): armed by "I'm up", called off when the
  // day starts (`sync`'s started days), never armed by the test alarm.
  testWidgets("I'm up arms the check; a start calls it off", (tester) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await startApp(tester);
    const id = 'wakeup:2099-01-01';
    Map<String, Object> alarm(int inMs) => {
      'id': id,
      'fireAtMs': DateTime.now().millisecondsSinceEpoch + inMs,
      'sound': 'start_bells',
      'title': 'Wake Up',
      'body': 'Device check',
      'stop': "I'm up",
      'snooze': 'Snooze',
      'snoozeMin': 9,
      'snoozeLimit': 3,
      'rampSec': 15,
      'minimal': false,
      'checkMin': 10,
      'checkTitle': 'Start Run?',
      'checkBody': 'Tap to start.',
      'checkStart': 'Start',
      'checkTarget': '',
      'checkLoud': false,
    };
    Future<bool?> armed() =>
        _channel.invokeMethod<bool>('checkArmed', {'id': id});

    await _channel.invokeMethod<Object>('sync', {
      'alarms': [alarm(3000)],
      'started': <String>[],
    });
    await waitUntil(
      tester,
      () async => await _ringing() == id,
      timeout: const Duration(seconds: 30),
    );
    expect(await armed(), isFalse, reason: 'only "I\'m up" arms it');
    await _channel.invokeMethod<void>('perform', {'action': 'stop', 'id': id});
    expect(await armed(), isTrue);

    await _channel.invokeMethod<Object>('sync', {
      'alarms': <Object>[],
      'started': ['2099-01-01'],
    });
    expect(await armed(), isFalse);
  });
}
