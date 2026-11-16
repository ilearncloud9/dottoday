import 'package:dottoday/domain/devices/alarm_device.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter_test/flutter_test.dart';

// "Alarm sounds on" (ED-084): one device rings Wake Up; before one is
// chosen every phone rings, so an upgrade silences nobody.

final _now = DateTime.utc(2026, 11, 15, 20);

Device _phone({
  bool alarmOn = true,
  bool rings = true,
  Duration seen = Duration.zero,
}) => Device(
  id: 'p',
  userId: 'u',
  platform: DevicePlatform.ios,
  form: DeviceForm.phone,
  canRing: true,
  alarmOn: alarmOn,
  rings: rings,
  armedWakeUtc: DateTime.utc(2026, 11, 16, 5, 30),
  lastSeenUtc: _now.subtract(seen),
);

void main() {
  group('ringsOnThisDevice', () {
    test('only the chosen device rings', () {
      const s = Settings(wakeUpAlarm: true, alarmDeviceId: 'a');
      expect(ringsOnThisDevice(s, canRing: true, deviceId: 'a'), isTrue);
      expect(ringsOnThisDevice(s, canRing: true, deviceId: 'b'), isFalse);
    });

    test('none chosen yet: every phone, as before the list', () {
      const s = Settings(wakeUpAlarm: true);
      expect(ringsOnThisDevice(s, canRing: true, deviceId: 'b'), isTrue);
    });

    test('a Mac or the web never rings, even when named', () {
      const s = Settings(wakeUpAlarm: true, alarmDeviceId: 'mac');
      expect(ringsOnThisDevice(s, canRing: false, deviceId: 'mac'), isFalse);
    });
  });

  test(
    'the first phone claims only when the alarm is on and none is chosen',
    () {
      expect(
        claimsAlarmDevice(const Settings(wakeUpAlarm: true), canRing: true),
        isTrue,
      );
      expect(claimsAlarmDevice(const Settings(), canRing: true), isFalse);
      expect(
        claimsAlarmDevice(
          const Settings(wakeUpAlarm: true, alarmDeviceId: 'a'),
          canRing: true,
        ),
        isFalse,
      );
      expect(
        claimsAlarmDevice(const Settings(wakeUpAlarm: true), canRing: false),
        isFalse,
      );
    },
  );

  group('alarmDeviceState', () {
    test('ready, waiting, alarms off, offline, none', () {
      expect(alarmDeviceState(_phone(), nowUtc: _now), AlarmDeviceState.ready);
      expect(
        alarmDeviceState(_phone(rings: false), nowUtc: _now),
        AlarmDeviceState.waitingToSync,
      );
      expect(
        alarmDeviceState(_phone(alarmOn: false), nowUtc: _now),
        AlarmDeviceState.alarmsOff,
      );
      expect(
        alarmDeviceState(_phone(seen: const Duration(hours: 25)), nowUtc: _now),
        AlarmDeviceState.offline,
      );
      expect(alarmDeviceState(null, nowUtc: _now), AlarmDeviceState.noDevice);
      expect(
        alarmDeviceState(_phone().copyWith(deletedAt: _now), nowUtc: _now),
        AlarmDeviceState.noDevice,
      );
    });
  });

  group('deviceNeedsReport', () {
    test('first, changed, or every 6 h', () {
      final a = _phone();
      expect(deviceNeedsReport(null, a), isTrue);
      final later = a.copyWith(
        lastSeenUtc: a.lastSeenUtc.add(const Duration(hours: 1)),
      );
      expect(deviceNeedsReport(a, later), isFalse);
      expect(deviceNeedsReport(a, later.copyWith(rings: false)), isTrue);
      expect(
        deviceNeedsReport(
          a,
          a.copyWith(lastSeenUtc: a.lastSeenUtc.add(deviceSeenEvery)),
        ),
        isTrue,
      );
    });
  });
}
