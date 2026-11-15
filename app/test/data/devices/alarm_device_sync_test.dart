import 'package:dottoday/data/devices/device_identity.dart';
import 'package:dottoday/data/devices/device_remote.dart';
import 'package:dottoday/data/devices/device_reporter.dart';
import 'package:dottoday/data/devices/drift_device_repository.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/notifications/wake_up_arming.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../domain/fixtures.dart';
import '../../support/timeline_fakes.dart';
import '../writes/write_harness.dart';

// "Alarm sounds on" through the real database (ED-084): only the chosen
// device arms Wake Up; the others take back what they armed when they
// sync. Before a device is chosen the first phone to sync claims it.

final class _Remote implements DeviceRemote {
  final puts = <Device>[];
  final others = <Device>[];

  @override
  Future<void> put(Device device) async => puts.add(device);

  @override
  Future<List<Device>> list() async => [...others, ...puts.take(1)];
}

void main() {
  setUpAll(initializeDateFormatting);
  final now = DateTime.utc(2026, 11, 15, 12);

  late WriteHarness h;
  late FakeAlarmGateway alarms;
  late FakeGateway pending;
  late _Remote remote;
  late DriftDeviceRepository devices;

  setUp(() => alarms = FakeAlarmGateway());

  Future<NotificationSync> setUpSync(
    Settings settings, {
    DevicePlatform platform = DevicePlatform.ios,
    DeviceForm form = DeviceForm.phone,
  }) async {
    h = WriteHarness(now);
    addTearDown(h.dispose);
    pending = FakeGateway();
    remote = _Remote();
    devices = DriftDeviceRepository(h.db);
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture().copyWith(tzId: 'UTC', settings: settings),
        // Tomorrow's first task, so tomorrow's Wake Up is planned.
        occurrences: [
          occurrenceFixture().copyWith(
            startUtc: DateTime.utc(2026, 11, 16, 9),
            tzId: 'UTC',
          ),
        ],
      ),
    );
    await h.effects.idle;
    return NotificationSync(
      clock: h.clock,
      planner: NotificationPlanner(clock: h.clock),
      gateway: pending,
      occurrences: DriftOccurrenceRepository(h.db),
      series: DriftSeriesRepository(h.db),
      settings: DriftSettingsRepository(h.db),
      arming: WakeUpArming(alarms, h.db),
      ringsWakeUp: form != DeviceForm.desktop,
      devices: DeviceReporter(
        identity: DeviceIdentity(
          h.db,
          platform: platform,
          form: form,
          newId: () => 'self',
        ),
        devices: devices,
        clock: h.clock,
        remote: remote,
        claim: (profile, id) => h.writes.apply(
          WriteBatch(
            userId: profile.id,
            profile: profile.copyWith(
              settings: profile.settings.copyWith(alarmDeviceId: id),
            ),
          ),
        ),
      ),
    );
  }

  Future<Settings> stored() async =>
      (await DriftSettingsRepository(h.db).findLocalProfile())!.settings;

  bool wakeUpPending() => pending.pendingSet.values.any(
    (n) => n.purpose == NotificationPurpose.wakeUp,
  );

  test('the chosen phone arms and reports Ready with the time', () async {
    final sync = await setUpSync(
      const Settings(wakeUpAlarm: true, alarmDeviceId: 'self'),
    );
    await sync.resync(userId);
    expect(alarms.armed.map((a) => a.fireAtUtc), [
      DateTime.utc(2026, 11, 16, 7),
    ]);
    final row = remote.puts.single;
    expect(row.rings, isTrue);
    expect(row.armedWakeUtc, DateTime.utc(2026, 11, 16, 7));
    expect((await devices.findById(userId, 'self'))!.rings, isTrue);
  });

  test(
    'another device is chosen: this phone disarms and rings nothing',
    () async {
      final sync = await setUpSync(
        const Settings(wakeUpAlarm: true, alarmDeviceId: 'self'),
      );
      await sync.resync(userId);
      expect(alarms.armed, isNotEmpty);

      await h.writes.apply(
        WriteBatch(
          userId: userId,
          profile: profileFixture().copyWith(
            tzId: 'UTC',
            settings: const Settings(wakeUpAlarm: true, alarmDeviceId: 'ipad'),
          ),
        ),
      );
      await sync.resync(userId);
      expect(alarms.disarmed, 1);
      expect(wakeUpPending(), isFalse, reason: 'not on the notification path');
      final row = remote.puts.last;
      expect(row.rings, isFalse);
      expect(row.armedWakeUtc, isNull);
    },
  );

  test('none chosen: the first phone to sync claims it, and rings', () async {
    final sync = await setUpSync(const Settings(wakeUpAlarm: true));
    await sync.resync(userId);
    expect((await stored()).alarmDeviceId, 'self');
    expect(alarms.armed, isNotEmpty);
  });

  test('alarm off: nothing is claimed', () async {
    final sync = await setUpSync(const Settings());
    await sync.resync(userId);
    expect((await stored()).alarmDeviceId, isNull);
    expect(remote.puts.single.alarmOn, isFalse);
  });

  test('a Mac is listed but never claims or rings', () async {
    final sync = await setUpSync(
      const Settings(wakeUpAlarm: true),
      platform: DevicePlatform.macos,
      form: DeviceForm.desktop,
    );
    await sync.resync(userId);
    expect((await stored()).alarmDeviceId, isNull);
    final row = remote.puts.single;
    expect((row.canRing, row.alarmOn, row.rings), (false, false, false));
    expect(alarms.armed, isEmpty);
  });

  test('an unchanged row is sent once, then again after 6 h', () async {
    final sync = await setUpSync(
      const Settings(wakeUpAlarm: true, alarmDeviceId: 'self'),
    );
    await sync.resync(userId);
    h.clock.advance(const Duration(hours: 1));
    await sync.resync(userId);
    expect(remote.puts, hasLength(1));
    h.clock.advance(const Duration(hours: 5));
    await sync.resync(userId);
    expect(remote.puts, hasLength(2));
  });
}
