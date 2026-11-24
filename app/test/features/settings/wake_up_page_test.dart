import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import 'settings_harness.dart';

// Wake Up and Wind Down's Wake Up alarm and Reminders (E-Phones, ED-084),
// and the pages they open: Wake Up options (E-R2-32, ED-337; E-R2-38,
// ED-344), Missions (E-R2-28, ED-331) and Vary the sound (owner
// 2026-11-24). Every option the alarm has is a row (docs/15 §9).

const _on = Settings(use24h: true, wakeUpAlarm: true);

Future<SettingsHarness> _pump(
  WidgetTester tester, {
  Settings settings = _on,
  SettingsPage page = SettingsPage.wakeWindDown,
  FakeAlarmGateway? gateway,
  List<Device> devices = const [],
}) => pumpSettings(
  tester,
  settings: settings,
  location: AppRoutes.settingsPage(page),
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
    expect(find.text('This iPhone'), findsOneWidget);
    // When it last confirmed the times (E-Phones).
    expect(find.textContaining('Ready · confirmed '), findsOneWidget);
    await _tap(tester, 'Alarm sounds on');
    // Its own page (E-Phones "Alarm sounds on").
    expect(find.text('Can ring'), findsOneWidget);
    expect(
      find.text(
        'Your schedule syncs to every device. Only the device you choose '
        'rings Wake Up; the others stay quiet.',
      ),
      findsOneWidget,
    );
    await _tap(tester, 'iPad');
    expect((await storedSettings(h)).alarmDeviceId, 'ipad');
  });

  testWidgets('off: the switch and the test, the board footers', (
    tester,
  ) async {
    await _pump(tester, settings: const Settings(use24h: true));
    for (final text in [
      'Wake Up alarm',
      'Ring like an alarm',
      'Off: Wake Up is a normal reminder',
      'Send a test alarm',
      'Turn it on to ring full screen over the lock screen at Wake Up. '
          "Sound, snooze and missions appear here when it's on.",
      'Wake Up card and the start check follow the alarm until you set '
          'them yourself.',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    for (final text in ['Alarm sounds on', 'Sound', 'Snooze length']) {
      expect(find.text(text), findsNothing, reason: text);
    }
    // Health is on Settings › Reminders (E-R2-20), not here.
    expect(find.text('Notification health'), findsNothing);
    // The card and the check read Off (and the sleep target, above).
    expect(find.text('Off'), findsNWidgets(3));
  });

  testWidgets('on: one group with the board rows and footer', (tester) async {
    await _pump(tester);
    for (final row in [
      'Ring like an alarm',
      'Full screen over the lock screen',
      'Alarm sounds on',
      'Sound',
      'Volume ramp',
      'Vary the sound',
      'Snooze',
      'Snooze length',
      'Snooze limit',
      'Missions',
      'Send a test alarm',
      'Shown only when Ring like an alarm is on. One sound and snooze for '
          'every schedule; each schedule chooses its own alarm days.',
      'Wake Up card',
      'Check after 10 min',
    ]) {
      expect(find.text(row), findsOneWidget, reason: row);
    }
    expect(find.text('30 s'), findsOneWidget);
    expect(find.text('9 min'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('iPhone: no volume ramp; its own footer', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await _pump(tester, settings: const Settings(use24h: true));
    expect(find.textContaining('(iOS 26 and later)'), findsOneWidget);
    await _tap(tester, 'Ring like an alarm');
    expect(find.text('Volume ramp'), findsNothing);
    expect(find.text('Vary the sound'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
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
    await _tap(tester, 'Snooze');
    expect((await storedSettings(h)).wakeUpSnooze, isFalse);
    expect(find.text('Snooze length'), findsNothing);
  });

  testWidgets('Vary the sound: its page, then choose 2–6', (tester) async {
    final h = await _pump(tester);
    await _tap(tester, 'Vary the sound');
    await _tap(
      tester,
      'A different alarm sound each day, so it stays easy to '
      'hear.',
    );
    expect((await storedSettings(h)).wakeUpVarySound, isTrue);
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

  testWidgets('minimal: the sound, the rest behind More options', (
    tester,
  ) async {
    await _pump(tester, settings: _on.copyWith(uiLayout: UiLayout.minimal));
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Snooze length'), findsNothing);
    await _tap(tester, 'More options');
    expect(find.text('Snooze length'), findsOneWidget);
    expect(find.text('Vary the sound'), findsOneWidget);
  });

  testWidgets('the test alarm goes through the gateway', (tester) async {
    final gateway = FakeAlarmGateway();
    await _pump(tester, gateway: gateway);
    await _tap(tester, 'Send a test alarm');
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
    await _tap(tester, 'Ring like an alarm');
    expect((await storedSettings(h)).wakeUpAlarm, isTrue);
    expect(gateway.authorizationRequests, 1);
  });

  testWidgets('Wake Up card opens Wake Up options: How it works, card, check', (
    tester,
  ) async {
    final h = await _pump(tester);
    await _tap(tester, 'Wake Up card');
    expect(find.text('Wake Up options'), findsWidgets);
    expect(find.text('How it works'), findsOneWidget);
    expect(find.text('Show it when I first open the app'), findsOneWidget);
    await _tap(tester, "Offer to shift the day when I'm up after plan");
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
    await _pump(tester, page: SettingsPage.wakeUp);
    for (final row in ['Offer after', 'Check after']) {
      await tester.ensureVisible(find.text(row));
      expect(
        find.bySemanticsLabel(RegExp('(^|\n)$row\n')),
        findsOneWidget,
        reason: row,
      );
    }
    expect(find.bySemanticsLabel(RegExp('(^|\n)After\n')), findsNothing);
    await _tap(tester, 'Check after');
    expect(find.text('Check after'), findsNWidgets(2));
    handle.dispose();
  });

  testWidgets('Wake Up options without the alarm: the card, no check', (
    tester,
  ) async {
    await _pump(
      tester,
      settings: const Settings(use24h: true),
      page: SettingsPage.wakeUp,
    );
    expect(find.text('Morning card'), findsWidgets);
    expect(find.text('Show it when I first open the app'), findsNothing);
    expect(find.text("Check I've started"), findsNothing);
  });

  testWidgets('Missions: the row opens its page; the list picks', (
    tester,
  ) async {
    final h = await _pump(
      tester,
      settings: _on.copyWith(missionMode: MissionMode.always),
    );
    await _tap(tester, 'Missions');
    for (final text in [
      'Mission',
      'Stand up',
      'Walk',
      'Breathe',
      'Backup mission',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    await _tap(tester, 'Breathe');
    expect((await storedSettings(h)).missionKind, MissionKind.breathe);
  });

  testWidgets('Missions off: only when they run', (tester) async {
    await _pump(tester, page: SettingsPage.missions);
    expect(find.text('Missions'), findsWidgets);
    expect(find.text('Stand up'), findsNothing);
    expect(find.text('Backup mission'), findsNothing);
  });
}
