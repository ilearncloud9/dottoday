import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import 'settings_harness.dart';

// Settings › Wake Up alarm › Sound and snooze (docs/15 §9, M17.2): every
// option the alarm has is a row; rows the alarm doesn't use while off, or
// this device can't use, are not drawn.

const _on = Settings(use24h: true, wakeUpAlarm: true);

Future<SettingsHarness> _pump(
  WidgetTester tester, {
  Settings settings = _on,
  FakeAlarmGateway? gateway,
  List<Device> devices = const [],
}) => pumpSettings(
  tester,
  settings: settings,
  location: AppRoutes.settingsPage(SettingsPage.wakeUp),
  alarmGateway: gateway,
  devices: devices,
);

Device _device(String id, DeviceForm form, {bool rings = true}) => Device(
  id: id,
  userId: testUserId,
  platform: DevicePlatform.ios,
  form: form,
  canRing: true,
  alarmOn: true,
  rings: rings,
  armedWakeUtc: DateTime.utc(2026, 10, 22, 5),
  lastSeenUtc: DateTime.utc(2026, 10, 21, 8),
);

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Alarm sounds on: the chosen device, its state, and a pick', (
    tester,
  ) async {
    final h = await _pump(
      tester,
      settings: _on.copyWith(alarmDeviceId: 'self'),
      devices: [
        _device('self', DeviceForm.phone),
        _device('ipad', DeviceForm.tablet, rings: false),
      ],
    );
    expect(find.text('Alarm sounds on'), findsOneWidget);
    expect(find.text('This iPhone'), findsOneWidget);
    expect(find.text('Ready · 07:00'), findsOneWidget);
    await _tap(tester, 'Alarm sounds on');
    await _tap(tester, 'iPad');
    expect((await storedSettings(h)).alarmDeviceId, 'ipad');
  });

  testWidgets('Alarm sounds on: hidden while the alarm is off', (tester) async {
    await _pump(tester, settings: const Settings(use24h: true));
    expect(find.text('Alarm sounds on'), findsNothing);
  });

  testWidgets('off: the switch, the test and health only', (tester) async {
    await _pump(tester, settings: const Settings(use24h: true));
    expect(find.text('Wake Up and Wind Down'), findsWidgets);
    expect(find.text('Alarm sound'), findsNothing);
    expect(find.text('Snooze length'), findsNothing);
    expect(find.text('Notification health'), findsOneWidget);
  });

  testWidgets('on: sound, vary, ramp and snooze, with their defaults', (
    tester,
  ) async {
    await _pump(tester);
    for (final row in [
      'Alarm sound',
      'Vary the sound',
      'Volume ramp',
      'Snooze length',
      'Snooze limit',
    ]) {
      expect(find.text(row), findsOneWidget, reason: row);
    }
    expect(find.text('30 s'), findsOneWidget);
    expect(find.text('9 min'), findsOneWidget);
    expect(find.text('3 times'), findsOneWidget);
  });

  testWidgets('picks write; snooze off hides its length and limit', (
    tester,
  ) async {
    final h = await _pump(tester);
    await _tap(tester, 'Snooze length');
    await _tap(tester, '15 min');
    expect((await storedSettings(h)).wakeUpSnoozeMin, 15);
    await _tap(tester, 'Snooze limit');
    await _tap(tester, 'No limit');
    expect((await storedSettings(h)).wakeUpSnoozeMax, 0);
    await _tap(tester, 'Vary the sound');
    expect((await storedSettings(h)).wakeUpVarySound, isTrue);
    await _tap(tester, 'Rings again a few minutes later.');
    expect((await storedSettings(h)).wakeUpSnooze, isFalse);
    expect(find.text('Snooze length'), findsNothing);
  });

  testWidgets('Vary the sound: choose 2–6, the calm three to start', (
    tester,
  ) async {
    final h = await _pump(
      tester,
      settings: _on.copyWith(wakeUpVarySound: true),
    );
    expect(find.text('3 sounds'), findsOneWidget);
    await _tap(tester, 'Sounds to vary');
    await _tap(tester, 'Rain');
    expect((await storedSettings(h)).wakeUpRotationIds.toSet(), {
      ...defaultWakeUpRotationIds,
      'start.rain',
    });
    await _tap(tester, 'Gentle');
    await _tap(tester, 'Soft bells');
    expect((await storedSettings(h)).wakeUpRotationIds.toSet(), {
      'start.dawn_chorus',
      'start.rain',
    });
    // Two left: neither can go.
    await _tap(tester, 'Rain');
    expect((await storedSettings(h)).wakeUpRotationIds, hasLength(2));
  });

  testWidgets('iPhone: no volume ramp (AlarmKit sets the volume)', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await _pump(tester);
    expect(find.text('Volume ramp'), findsNothing);
    expect(find.text('Vary the sound'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('minimal: switch and sound, the rest behind More options', (
    tester,
  ) async {
    await _pump(tester, settings: _on.copyWith(uiLayout: UiLayout.minimal));
    expect(find.text('Alarm sound'), findsOneWidget);
    expect(find.text('Snooze length'), findsNothing);
    await _tap(tester, 'More options');
    expect(find.text('Snooze length'), findsOneWidget);
    expect(find.text('Vary the sound'), findsOneWidget);
  });

  testWidgets('the test alarm goes through the gateway', (tester) async {
    final gateway = FakeAlarmGateway();
    await _pump(tester, gateway: gateway);
    await _tap(tester, 'Send me a test alarm');
    await _tap(tester, 'Send');
    expect(gateway.tests.single.id, 'wakeup:test');
  });

  testWidgets('switching on asks for alarms (iOS 26 prompt)', (tester) async {
    final gateway = FakeAlarmGateway();
    final h = await _pump(
      tester,
      settings: const Settings(use24h: true),
      gateway: gateway,
    );
    await _tap(tester, "Rings like an alarm at Wake Up on days you've planned");
    expect((await storedSettings(h)).wakeUpAlarm, isTrue);
    expect(gateway.authorizationRequests, 1);
  });

  testWidgets('Morning card: follows the alarm until chosen; its rows', (
    tester,
  ) async {
    final h = await _pump(tester);
    expect(find.text('Show it when I first open the app'), findsOneWidget);
    await _tap(tester, 'Offer to shift the day when I\'m up after plan');
    expect((await storedSettings(h)).wakeUpLateOffer, isFalse);
    expect(find.text('Offer after'), findsNothing);
    expect(find.text('Check after'), findsOneWidget, reason: "the check's");
    await _tap(tester, "Your day on one screen when you're up");
    expect((await storedSettings(h)).wakeUpCard, isFalse);
    expect(find.text('Show it when I first open the app'), findsNothing);
  });

  testWidgets('the two delays say which setting they change (ED-337)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    for (final row in ['Offer after', 'Check after']) {
      await tester.ensureVisible(find.text(row));
      expect(
        find.bySemanticsLabel(RegExp('(^|\n)$row\n')),
        findsOneWidget,
        reason: row,
      );
    }
    expect(find.bySemanticsLabel(RegExp('(^|\n)After\n')), findsNothing);
    // Each picker's title names its setting too.
    await _tap(tester, 'Offer after');
    expect(find.text('Offer after'), findsNWidgets(2));
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await _tap(tester, 'Check after');
    expect(find.text('Check after'), findsNWidgets(2));
    handle.dispose();
  });

  testWidgets('Morning card off for anyone without Wake Up', (tester) async {
    await _pump(tester, settings: const Settings(use24h: true));
    expect(find.text('Morning card'), findsWidgets);
    expect(find.text('Show it when I first open the app'), findsNothing);
  });
}
