import 'package:dottoday/data/notifications/fln_exact_alarms.dart';
import 'package:dottoday/data/notifications/os_alarm_gateway.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// The Wake Up alarm's channel (docs/15 W1b, ADR-0017): what the app hands
// AlarmKit and Android's ringing service, and how a missing handler reads.

const _channel = MethodChannel('dottoday/alarm-test');

final _alarm = WakeUpAlarm(
  id: 'wakeup:2026-11-02',
  fireAtUtc: DateTime.utc(2026, 11, 2, 6, 30),
  sound: catalogueSound('start.bells')!,
  title: 'Wake Up',
  body: 'First: Run at 07:00',
  stopLabel: "I'm up",
  snoozeLabel: 'Snooze',
  snoozeMinutes: 9,
  snoozeLimit: 3,
  rampSeconds: 30,
);

OsAlarmGateway _gateway(HealthPlatform platform) => OsAlarmGateway(
  platform: platform,
  permission: const UnwiredNotificationPermission(),
  exactAlarms: const AlwaysExactAlarms(),
  channel: _channel,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  void answer(Object? Function(MethodCall call) reply) =>
      messenger.setMockMethodCallHandler(_channel, (call) async {
        calls.add(call);
        return reply(call);
      });

  setUp(calls.clear);
  tearDown(() => messenger.setMockMethodCallHandler(_channel, null));

  test(
    'sync: each alarm with its platform sound file; armed instants back',
    () async {
      answer((call) => [_alarm.fireAtUtc.millisecondsSinceEpoch]);
      final armed = await _gateway(HealthPlatform.iphone).sync([_alarm]);
      expect(armed, {_alarm.fireAtUtc});
      final sent = (calls.single.arguments as List).single as Map;
      expect(sent['id'], 'wakeup:2026-11-02');
      expect(sent['sound'], 'start_bells.caf');
      expect(sent['snoozeMin'], 9);
      expect(sent['snoozeLimit'], 3);
      expect(sent['stop'], "I'm up");

      calls.clear();
      await _gateway(HealthPlatform.android).sync([_alarm]);
      expect(
        ((calls.single.arguments as List).single as Map)['sound'],
        'start_bells',
      );
    },
  );

  test('no handler: sync is "out of reach", test arms nothing', () async {
    final gateway = _gateway(HealthPlatform.android);
    expect(await gateway.sync([_alarm]), isNull);
    expect(await gateway.test(_alarm), isFalse);
    await gateway.disarmAll();
  });

  test('the Mac and the web never call the channel', () async {
    answer((call) => fail('called ${call.method}'));
    final gateway = _gateway(HealthPlatform.mac);
    expect(await gateway.sync([_alarm]), isEmpty);
    expect(await gateway.test(_alarm), isFalse);
    await gateway.disarmAll();
    expect(calls, isEmpty);
  });

  test('iPhone: AlarmKit status by name', () async {
    for (final (name, tier) in [
      ('authorized', AlarmTier.alarm),
      ('notAsked', AlarmTier.timeSensitive),
      ('needsUpdate', AlarmTier.timeSensitive),
    ]) {
      answer((call) => name);
      expect((await _gateway(HealthPlatform.iphone).capabilities()).tier, tier);
    }
  });

  test('requestAuthorization asks only where never asked', () async {
    var status = 'denied';
    answer((call) => call.method == 'alarmKitStatus' ? status : null);
    await _gateway(HealthPlatform.iphone).requestAuthorization();
    expect(calls.map((c) => c.method), ['alarmKitStatus']);
    status = 'notAsked';
    calls.clear();
    await _gateway(HealthPlatform.iphone).requestAuthorization();
    expect(calls.map((c) => c.method), ['alarmKitStatus', 'allowAlarms']);
  });
}
