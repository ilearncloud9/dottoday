// The Android ringing screen at dawn on the emulator (docs/09 M20.8 part 4;
// E-R2-19-B, ED-314; ED-459): the real gateway arms the test alarm a few
// seconds ahead with E-R2-19-B's sample day, and it rings through the
// full-screen intent. A full-screen intent only opens the screen while the
// device is locked, so the runner sleeps the emulator at `RING_ARMED` and
// saves the screen at `RING_SHOT` (the M20.8 part 4 review runner; theme,
// rotation and font size are set on the emulator around the run).
// Exact alarms and notifications: tool/device_tests.sh grants them.
import 'package:dottoday/data/notifications/fln_exact_alarms.dart';
import 'package:dottoday/data/notifications/os_alarm_gateway.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/domain/notifications/wake_up_arc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _channel = MethodChannel('dottoday/alarm');

/// E-R2-19-B's sample morning from Wake Up 6:30: the run, coffee, standup,
/// deep work and the rest, as shares of the day.
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

/// Which mornings to ring, comma-separated (`--dart-define=RINGS=`).
const _rings = String.fromEnvironment(
  'RINGS',
  defaultValue: 'full,minimal,empty',
);

WakeUpAlarm _alarm(String kind) => WakeUpAlarm(
  id: WakeUpAlarm.testId,
  fireAtUtc: DateTime.now().toUtc().add(const Duration(seconds: 8)),
  sound: catalogueSound('start.bells')!,
  title: 'Wake Up',
  body: kind == 'empty' ? 'Good morning.' : 'First: Morning run at 6:45 AM',
  stopLabel: "I'm up",
  snoozeLabel: 'Snooze',
  snoozeMinutes: 9,
  snoozeLimit: 3,
  minimal: kind == 'minimal',
).withArcs(kind == 'empty' ? const [] : _day);

Future<void> _until(Future<bool> Function() check) async {
  final end = DateTime.now().add(const Duration(seconds: 40));
  while (DateTime.now().isBefore(end)) {
    if (await check()) return;
    // Real time, no frames: the app is behind the lock screen meanwhile.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
  fail('the alarm did not ring');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the ringing screen at dawn: full, minimal, empty day', (
    tester,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    const gateway = OsAlarmGateway(
      platform: HealthPlatform.android,
      permission: UnwiredNotificationPermission(),
      exactAlarms: AlwaysExactAlarms(),
    );
    for (final kind in _rings.split(',')) {
      expect(await gateway.test(_alarm(kind)), isTrue);
      debugPrint('RING_ARMED $kind');
      await _until(
        () async =>
            await _channel.invokeMethod<String>('ringingId') ==
            WakeUpAlarm.testId,
      );
      // The screen turns on and draws over the lock screen.
      await Future<void>.delayed(const Duration(seconds: 4));
      debugPrint('RING_SHOT $kind');
      await Future<void>.delayed(const Duration(seconds: 4));
      await _channel.invokeMethod<void>('perform', {
        'action': 'stop',
        'id': WakeUpAlarm.testId,
      });
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  });
}
