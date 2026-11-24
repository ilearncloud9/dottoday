import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../timeline/calendar/calendar_world.dart';

/// Mac/web Settings pages as forms (docs/09 M20.7 part 5b, ED-450): the
/// drawn pages become "Label:" forms on the Mac and the web, keep the
/// phone rows elsewhere, and their controls write what the rows did.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  const wide = Size(1280, 900);
  final mac = TargetPlatformVariant.only(TargetPlatform.macOS);

  Future<void> open(
    WidgetTester tester,
    SettingsPage page, {
    Size size = wide,
    List<Device> devices = const [],
    AlarmCapabilities caps = const AlarmCapabilities(AlarmTier.none, [
      AlarmBlocker.notAPhone,
    ]),
    List<Alert>? alerts,
  }) async {
    final router = await pumpCalendar(
      tester,
      size: size,
      devices: devices,
      wakeUpAlarm: caps,
      settings: (s) => s.copyWith(
        wakeUpAlarm: true,
        missionMode: MissionMode.always,
        alarmDeviceId: 'iphone',
        defaultAlerts: alerts ?? s.defaultAlerts,
      ),
    );
    router.go(AppRoutes.settingsPage(page));
    await tester.pumpAndSettle();
  }

  testWidgets('Planning on the Mac: labels, checkboxes and pop-ups', (
    tester,
  ) async {
    await open(tester, SettingsPage.planning);
    expect(find.text('Snap to:'), findsOneWidget);
    expect(find.text('Nudges:'), findsOneWidget);
    expect(find.byType(FormCheck), findsNWidgets(6));
    expect(find.byType(Switch), findsNothing);

    // The pop-up picks in place (Flutter's menu without the native bridge).
    await tester.tap(find.byTooltip('Snap to'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 min').last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(FormMenu), matching: find.text('15 min')),
      findsOneWidget,
    );

    // The whole line toggles its checkbox.
    final roll = find.widgetWithText(FormCheck, 'Roll unfinished to tomorrow');
    expect(tester.widget<FormCheck>(roll).value, isFalse);
    await tester.tap(find.text('Roll unfinished to tomorrow'));
    await tester.pumpAndSettle();
    expect(tester.widget<FormCheck>(roll).value, isTrue);
  }, variant: mac);

  testWidgets('Planning on an iPad keeps the phone rows', (tester) async {
    await open(tester, SettingsPage.planning, size: const Size(1180, 820));
    expect(find.byType(FormLine), findsNothing);
    expect(find.text('Snap to:'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Help and about, not drawn as a form, keeps its rows', (
    tester,
  ) async {
    await open(tester, SettingsPage.helpAbout);
    expect(find.byType(FormLine), findsNothing);
  }, variant: mac);

  testWidgets('Task starts: each alert a chip; × removes it', (tester) async {
    await open(
      tester,
      SettingsPage.reminders,
      alerts: const [
        Alert(kind: AlertKind.before, offsetMin: 10),
        Alert(kind: AlertKind.atStart),
      ],
    );
    expect(find.byType(InputChip), findsNWidgets(2));
    await tester.tap(find.byTooltip('Remove 10 min before'));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsOneWidget);
    expect(find.text('Add…'), findsOneWidget);
  }, variant: mac);

  testWidgets('Missions: set from the Mac for the phone that rings', (
    tester,
  ) async {
    await open(tester, SettingsPage.missions);
    expect(
      find.text(
        'Missions run on the phone or tablet that rings Wake Up. '
        'This page sets them for it.',
      ),
      findsOneWidget,
    );
    expect(find.text('Mission:'), findsOneWidget);
    // Walk's sensor is the phone's: offered, with why.
    final walk = find.widgetWithText(FormRadio, 'Walk');
    expect(tester.widget<FormRadio>(walk).onTap, isNotNull);
    expect(
      find.text('Uses a sensor on the phone that rings'),
      findsNWidgets(2),
    );
  }, variant: mac);

  testWidgets('Alarm sounds on: this Mac is listed but never chosen', (
    tester,
  ) async {
    final seen = DateTime.utc(2026, 11, 3, 8);
    await open(
      tester,
      SettingsPage.alarmDevice,
      devices: [
        Device(
          id: 'iphone',
          userId: testUserId,
          platform: DevicePlatform.ios,
          form: DeviceForm.phone,
          canRing: true,
          alarmOn: true,
          lastSeenUtc: seen,
        ),
        Device(
          id: 'mac',
          userId: testUserId,
          platform: DevicePlatform.macos,
          form: DeviceForm.desktop,
          canRing: false,
          alarmOn: false,
          lastSeenUtc: seen,
        ),
      ],
    );
    expect(find.text('Can ring:'), findsOneWidget);
    expect(find.text("Can't ring:"), findsOneWidget);
    final macRow = find.widgetWithText(FormListRow, 'Mac').first;
    expect(tester.widget<FormListRow>(macRow).onTap, isNull);
    expect(tester.widget<FormListRow>(macRow).dimmed, isTrue);
  }, variant: mac);

  testWidgets('Account: the name is edited in place', (tester) async {
    await open(tester, SettingsPage.account);
    expect(find.text('Name:'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(FormLine),
        matching: find.byType(TextField),
      ),
      'Kody',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Kody'), findsWidgets);
  }, variant: mac);
}
