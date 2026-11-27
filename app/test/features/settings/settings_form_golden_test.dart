// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/features/settings/settings_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart' show loadAppFonts;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/account_fakes.dart';
import '../../support/account_screen_fakes.dart';
import '../../support/timeline_fakes.dart';
import '../timeline/calendar/calendar_world.dart';

/// The Mac/web Settings pages as forms beside their drawings (docs/09
/// M20.7 part 5b, ED-450): the right pane of Settings in two panes at
/// 1280, light and dark, on the Mac; two on the web where the words
/// differ ("This browser", "In this browser").
void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  const wide = Size(1280, 900);
  const pages = [
    SettingsPage.yourDay,
    SettingsPage.planning,
    SettingsPage.reminders,
    SettingsPage.dataPrivacy,
    SettingsPage.sounds,
    SettingsPage.notifications,
    SettingsPage.wakeUp,
    SettingsPage.missions,
    SettingsPage.alarmDevice,
    SettingsPage.learning,
    SettingsPage.export,
    SettingsPage.account,
    SettingsPage.appearance,
    SettingsPage.wakeWindDown,
  ];

  Future<void> open(
    WidgetTester tester,
    SettingsPage page,
    ThemeMode mode, {
    Size size = wide,
    bool later = false,
    int pending = 0,
  }) async {
    final router = await pumpCalendar(
      tester,
      size: size,
      mode: mode,
      settings: _seeded,
      devices: _devices,
      // This Mac never rings; it sets things for the iPhone (E-FullA-v2).
      wakeUpAlarm: const AlarmCapabilities(AlarmTier.none, [
        AlarmBlocker.notAPhone,
      ]),
      extra: [
        accountServiceProvider.overrideWithValue(
          FakeAccountService(
            account: const SignedIn(
              email: 'kody@example.com',
              method: SignInMethod.email,
            ),
          ),
        ),
        ...accountScreenOverrides(
          FakeAccountActions(),
          later: later,
          pending: pending,
        ),
      ],
    );
    // A sub-page is pushed from its parent, as in the app.
    final parent = settingsPlace(AppLocalizationsEn(), page).parent;
    if (parent != null) {
      router.go(AppRoutes.settingsPage(parent));
      await tester.pumpAndSettle();
      unawaited(router.push(AppRoutes.settingsPage(page)));
    } else {
      router.go(AppRoutes.settingsPage(page));
    }
    await tester.pumpAndSettle();
  }

  for (final page in pages) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('mac ${page.name} ${mode.name}', (tester) async {
        await open(tester, page, mode);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/settings_form_mac_${page.name}_${mode.name}.png',
          ),
        );
      }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
    }
  }

  // `DesktopAccountChoose` (ED-494): B1 waiting after Decide later, with
  // changes waiting to sync.
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('mac account choose ${mode.name}', (tester) async {
      await open(tester, SettingsPage.account, mode, later: true, pending: 3);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/settings_form_mac_account_choose_${mode.name}.png',
        ),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  }

  // From a 920 pane the dial sits beside the table (ED-452).
  testWidgets('mac wakeWindDown wide light', (tester) async {
    await open(
      tester,
      SettingsPage.wakeWindDown,
      ThemeMode.light,
      size: const Size(1600, 1000),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        'goldens/settings_form_mac_wakeWindDown_wide_light.png',
      ),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  for (final page in [
    SettingsPage.notifications,
    SettingsPage.export,
    SettingsPage.appearance,
  ]) {
    testWidgets('web ${page.name} light', (tester) async {
      debugWebChromeOverride = true;
      addTearDown(() => debugWebChromeOverride = null);
      await open(tester, page, ThemeMode.light);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_form_web_${page.name}_light.png'),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  }
}

/// The drawings' state: Wake Up on with missions, the card and the check;
/// three alerts; quiet hours on.
Settings _seeded(Settings s) => s.copyWith(
  wakeUpAlarm: true,
  // E-FullA-v2's week: Weekdays 6:30–11:00 PM, Weekend 8:30–12:30 AM.
  dayBoundaries: {
    for (final d in Weekday.values)
      d: d.index < 5
          ? const TimeWindow(start: '06:30', end: '23:00')
          : const TimeWindow(start: '08:30', end: '24:30'),
  },
  wakeUpAlarmDays: {
    for (final d in Weekday.values)
      if (d.index < 5) d,
  },
  sleepTargetMin: 480,
  wakeUpCard: true,
  wakeUpCheck: true,
  missionMode: MissionMode.always,
  alarmDeviceId: 'iphone',
  quietHours: Settings.suggestedQuietHours,
  defaultAlerts: const [
    Alert(kind: AlertKind.before, offsetMin: 10),
    Alert(kind: AlertKind.atStart),
    Alert(kind: AlertKind.before, offsetMin: 60),
  ],
);

final _seen = DateTime.utc(2026, 11, 3, 8);

/// The iPhone rings; an iPad with alarms off; an Android phone not seen for
/// 3 days; this Mac and the web can't ring.
final _devices = [
  Device(
    id: 'iphone',
    userId: testUserId,
    platform: DevicePlatform.ios,
    form: DeviceForm.phone,
    canRing: true,
    alarmOn: true,
    rings: true,
    lastSeenUtc: _seen,
  ),
  Device(
    id: 'ipad',
    userId: testUserId,
    platform: DevicePlatform.ios,
    form: DeviceForm.tablet,
    canRing: true,
    alarmOn: false,
    lastSeenUtc: _seen,
  ),
  Device(
    id: 'pixel',
    userId: testUserId,
    platform: DevicePlatform.android,
    form: DeviceForm.phone,
    canRing: true,
    alarmOn: true,
    lastSeenUtc: DateTime.utc(2026, 10, 31, 8),
  ),
  Device(
    id: 'mac',
    userId: testUserId,
    platform: DevicePlatform.macos,
    form: DeviceForm.desktop,
    canRing: false,
    alarmOn: false,
    lastSeenUtc: _seen,
  ),
];
