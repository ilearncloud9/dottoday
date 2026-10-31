import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/notifications/wake_up_arming.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/timeline_fakes.dart';

// Arming the week's Wake Up alarms through AlarmGateway (docs/15 W1b): what
// was armed is remembered on the device, so an engine that can't reach the
// gateway still never rings an armed Wake Up twice.

PlannedNotification _wakeUp(DateTime at) => PlannedNotification(
  id: 1,
  occurrenceId: 'first',
  alertIndex: PlannedNotification.wakeUpIndex,
  fireAtUtc: at,
  kind: AlertKind.atStart,
  sound: 'start.bells',
  loud: true,
  purpose: NotificationPurpose.wakeUp,
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final mon = DateTime.utc(2026, 11, 2, 11);
  final tue = DateTime.utc(2026, 11, 3, 11);
  final on = profileFixture().copyWith(
    settings: const Settings(wakeUpAlarm: true, wakeUpSnoozeMin: 10),
  );

  test('arms each Wake Up with its day id, words and snooze', () async {
    final gateway = FakeAlarmGateway();
    final armed = await WakeUpArming(
      gateway,
      db,
    ).arm([_wakeUp(mon), _wakeUp(tue)], profile: on, tasks: const {});
    expect(armed, {mon, tue});
    expect(gateway.armed.map((a) => a.id), [
      'wakeup:2026-11-02',
      'wakeup:2026-11-03',
    ]);
    final first = gateway.armed.first;
    expect(first.snoozeMinutes, 10);
    expect(first.snoozeLimit, 3);
    expect(first.sound.id, 'start.bells');
    expect(first.stopLabel, "I'm up");
  });

  test('snooze off: no Snooze on the alarm', () async {
    final gateway = FakeAlarmGateway();
    await WakeUpArming(gateway, db).arm(
      [_wakeUp(mon)],
      profile: on.copyWith(settings: on.settings.copyWith(wakeUpSnooze: false)),
      tasks: const {},
    );
    expect(gateway.armed.single.snoozeMinutes, 0);
  });

  test('gateway out of reach: the last armed set still counts', () async {
    await WakeUpArming(
      FakeAlarmGateway(),
      db,
    ).arm([_wakeUp(mon)], profile: on, tasks: const {});
    final later = await WakeUpArming(
      FakeAlarmGateway()..reachable = false,
      db,
    ).arm([_wakeUp(mon), _wakeUp(tue)], profile: on, tasks: const {});
    expect(later, {mon});
  });

  test('switched off: everything disarmed once, then nothing', () async {
    final gateway = FakeAlarmGateway();
    final arming = WakeUpArming(gateway, db);
    await arming.arm([_wakeUp(mon)], profile: on, tasks: const {});
    final off = profileFixture();
    expect(await arming.arm(const [], profile: off, tasks: const {}), isEmpty);
    expect(await arming.arm(const [], profile: off, tasks: const {}), isEmpty);
    expect(gateway.disarmed, 1);
  });

  test('a device that arms nothing rings everything on the old path', () async {
    final gateway = FakeAlarmGateway()..arms = false;
    final armed = await WakeUpArming(
      gateway,
      db,
    ).arm([_wakeUp(mon)], profile: on, tasks: const {});
    expect(armed, isEmpty);
  });
}
