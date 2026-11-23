// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/calendar/cloud_calendar_providers.dart';
import 'package:dottoday/data/calendar/no_device_calendar_gateway.dart';
import 'package:dottoday/data/notifications/fln_exact_alarms.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/exact_alarms.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/settings/pages/about_page.dart';
import 'package:dottoday/features/settings/pages/account_page.dart';
import 'package:dottoday/features/settings/pages/calendars_page.dart';
import 'package:dottoday/features/settings/pages/changelog_page.dart';
import 'package:dottoday/features/settings/pages/data_pages.dart';
import 'package:dottoday/features/settings/pages/info_pages.dart';
import 'package:dottoday/features/settings/pages/settings_pages.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/account_fakes.dart';
import '../../support/account_screen_fakes.dart';
import '../../support/calendar_fakes.dart';
import '../../support/cloud_calendar_fakes.dart';
import '../../support/dot_golden.dart';
import '../../support/energy_history.dart';
import '../../support/sync_fakes.dart';
import '../../support/timeline_fakes.dart';

final _overrides = _overridesWith();

List<Override> _overridesWith({
  NotificationPermission permission = const UnwiredNotificationPermission(),
  ExactAlarms exactAlarms = const AlwaysExactAlarms(),
  DeviceCalendarGateway calendarGateway = const NoDeviceCalendarGateway(),
  List<Override> extra = const [],
  Settings settings = const Settings(use24h: true),
  List<Occurrence> rows = const [],
  String? accentHex,
}) => [
  ...extra,
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
    profile: testProfile(
      settings: settings,
    ).copyWith(displayName: 'Kody', accentHex: accentHex),
    notificationPermission: permission,
    exactAlarms: exactAlarms,
    calendarGateway: calendarGateway,
    occurrences: FakeOccurrenceRepository(rows),
  ),
  appVersionProvider.overrideWith((ref) async => '0.1.0 (1)'),
  envProvider.overrideWithValue(
    Env(
      supabaseUrl: Uri.parse('https://example.supabase.co'),
      supabaseAnonKey: 'anon',
    ),
  ),
];

Widget _settings() => const SettingsScreen();

/// A group's page (M20.7): its rows left the root.
Widget _page(SettingsPage page) => settingsPageFor(page);

Future<void> _open(WidgetTester tester, String row) async {
  // The list builds lazily: scroll until the row exists.
  await tester.scrollUntilVisible(
    find.text(row),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(row));
}

void main() {
  // energyHistory() reads the zone database while tests are declared.
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  // P1 (`A-ios-settings`): the first screenful, as the render.
  goldenMatrix(
    'settings',
    height: 844,
    overrides: _overrides,
    build: (_) => _settings(),
  );
  // Day shape with a sleep target that pulls Wind Down earlier (docs/15
  // W4 AC: the row in both states; the plain one is 'settings' above).
  goldenMatrix(
    'settings_day_shape_sleep',
    height: 900,
    widths: const {'compact'},
    overrides: _overridesWith(
      settings: const Settings(use24h: true, sleepTargetMin: 9 * 60 + 15),
    ),
    build: (_) => _page(SettingsPage.wakeWindDown),
  );
  // Settings › Learning (docs/13 §4.1, §11): nothing yet (0/10), on the
  // way (7/10, energy 7/20), and ready (the reality thread revealed, one
  // task's length known, energy available but off). Light/dark, 1×/2×,
  // the largest text and RTL.
  for (final (name, count) in [('0', 0), ('7', 7), ('ready', 20)]) {
    goldenMatrix(
      'settings_learning_$name',
      height: 844,
      widths: const {'compact', 'expanded'},
      a11yVariants: true,
      overrides: _overridesWith(rows: energyHistory(count: count)),
      build: (_) => _page(SettingsPage.learning),
    );
  }
  goldenMatrix(
    'settings_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    overrides: _overrides,
    build: (_) => _settings(),
  );
  // M20.7 part 1: each group's page, holding today's rows.
  for (final page in [
    SettingsPage.yourDay,
    SettingsPage.wakeWindDown,
    SettingsPage.planning,
    SettingsPage.appearance,
    SettingsPage.dataPrivacy,
    SettingsPage.helpAbout,
  ]) {
    goldenMatrix(
      'settings_group_${page.name}',
      height: 1100,
      widths: const {'compact', 'expanded'},
      overrides: _overrides,
      build: (_) => _page(page),
    );
  }
  // M20.7 part 4a (ED-084): Wake Up and Wind Down with Weekdays and a
  // Weekend that winds down after midnight, the alarm on.
  for (final (name, platform) in [
    ('settings_wake_wind_split', TargetPlatform.iOS),
    ('settings_wake_wind_split_android', TargetPlatform.android),
  ]) {
    goldenMatrix(
      name,
      height: 1400,
      platform: platform,
      widths: const {'compact'},
      overrides: _overridesWith(
        settings: Settings(
          use24h: false,
          wakeUpAlarm: true,
          dayBoundaries: {
            for (final d in Weekday.values)
              d: d.index < 5
                  ? const TimeWindow(start: '06:30', end: '23:00')
                  : const TimeWindow(start: '08:30', end: '24:30'),
          },
        ),
      ),
      build: (_) => _page(SettingsPage.wakeWindDown),
    );
  }
  // M20.7 part 3 (E-G3-9b, ED-161): Appearance in Less (the preview's Now
  // ring), with a custom App colour first, and Edit palette.
  goldenMatrix(
    'settings_appearance_less',
    height: 1100,
    widths: const {'compact'},
    overrides: _overridesWith(
      settings: const Settings(use24h: true, uiLayout: UiLayout.minimal),
      accentHex: '#7A9E4A',
    ),
    build: (_) => _page(SettingsPage.appearance),
  );
  for (final (name, platform) in [
    ('settings_edit_palette', TargetPlatform.iOS),
    ('settings_edit_palette_android', TargetPlatform.android),
  ]) {
    goldenMatrix(
      name,
      height: 900,
      platform: platform,
      widths: const {'compact'},
      act: (t) => _open(t, 'Edit palette'),
      overrides: _overridesWith(accentHex: '#7A9E4A'),
      build: (_) => _page(SettingsPage.appearance),
    );
  }
  // E-R2-33: Shift later tasks, "Cancel · Shift later tasks" on iPhone,
  // the title row and radio buttons on Android.
  for (final (name, platform) in [
    ('settings_shift_sheet', TargetPlatform.iOS),
    ('settings_shift_sheet_android', TargetPlatform.android),
  ]) {
    goldenMatrix(
      name,
      height: 844,
      platform: platform,
      widths: const {'compact'},
      act: (t) => _open(t, 'Shift later tasks'),
      overrides: _overrides,
      build: (_) => _page(SettingsPage.planning),
    );
  }
  goldenMatrix(
    'settings_group_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    overrides: _overrides,
    build: (_) => _page(SettingsPage.planning),
  );
  // Derived (§5.3): Different days and Send feedback.
  goldenMatrix(
    'settings_weekdays',
    height: 844,
    widths: const {'compact', 'expanded'},
    // The schedule's Edit (the per-weekday sheet until M20.7 part 4b).
    act: (t) => _open(t, 'Edit'),
    overrides: _overrides,
    build: (_) => _page(SettingsPage.wakeWindDown),
  );
  goldenMatrix(
    'settings_feedback',
    height: 640,
    widths: const {'compact', 'expanded'},
    act: (t) => _open(t, 'Send feedback'),
    overrides: _overrides,
    build: (_) => _page(SettingsPage.helpAbout),
  );
  // M8.2 (derived, §5.3): the diagnostics opt-in shows what it adds.
  goldenMatrix(
    'settings_feedback_diagnostics',
    height: 900,
    widths: const {'compact', 'expanded'},
    act: (t) async {
      await _open(t, 'Send feedback');
      await t.pumpAndSettle();
      await t.tap(find.text('Add diagnostics'));
    },
    overrides: _overrides,
    build: (_) => _page(SettingsPage.helpAbout),
  );
  // M8.4d (derived, §5.3): REMINDERS with quiet hours on, a three-alert
  // default set, a sound and summary days; the Sound and Day-start
  // summary sheets.
  final reminders = _overridesWith(
    settings: const Settings(
      use24h: true,
      defaultAlerts: [
        Alert(kind: AlertKind.before, offsetMin: 10),
        Alert(kind: AlertKind.atStart),
        Alert(kind: AlertKind.atEnd),
      ],
      quietHours: Settings.suggestedQuietHours,
      daySummaryDays: {
        Weekday.mon,
        Weekday.tue,
        Weekday.wed,
        Weekday.thu,
        Weekday.fri,
      },
      reminderSound: 'chime',
    ),
  );
  goldenMatrix(
    'settings_reminders',
    height: 844,
    widths: const {'compact', 'expanded'},
    overrides: reminders,
    build: (_) => _page(SettingsPage.reminders),
  );
  // Sound is its own page now (sounds_page_golden_test.dart, docs/12 §6).
  for (final (name, row) in [('settings_day_summary', 'Day-start summary')]) {
    goldenMatrix(
      name,
      height: 844,
      widths: const {'compact', 'expanded'},
      act: (t) => _open(t, row),
      overrides: reminders,
      build: (_) => _page(SettingsPage.reminders),
    );
  }
  // M3f.7 sub-pages (derived, §5.3).
  for (final (name, page) in [
    ('account', const AccountPage()),
    ('calendars', const CalendarsPage()),
    ('export', const ExportPage()),
    ('help', const HelpPage()),
    ('privacy', const PrivacyPage()),
    ('about', const AboutPage()),
    ('changelog', const ChangelogPage()),
  ]) {
    goldenMatrix(
      'settings_page_$name',
      height: 844,
      widths: const {'compact', 'expanded'},
      overrides: _overrides,
      build: (_) => page,
    );
  }
  // M7.1: device calendars allowed (grouped, inherited colours) and denied.
  for (final (name, gateway) in [
    (
      'connected',
      FakeDeviceCalendarGateway(
        state: PermissionState.granted,
        list: sampleCalendars,
      ),
    ),
    ('denied', FakeDeviceCalendarGateway(state: PermissionState.denied)),
  ]) {
    goldenMatrix(
      'settings_page_calendars_$name',
      height: 844,
      widths: const {'compact', 'expanded'},
      overrides: _overridesWith(calendarGateway: gateway),
      build: (_) => const CalendarsPage(),
    );
  }
  // M7.4 (derived, §5.3): a Google account on a device with no calendars
  // of its own (the web): its calendars, Disconnect, Connect rows.
  goldenMatrix(
    'settings_page_calendars_google',
    height: 1100,
    widths: const {'compact', 'expanded'},
    overrides: _overridesWith(
      extra: [
        cloudCalendarsProvider.overrideWithValue(
          FakeCloudCalendars(list: [sampleCloudAccount]),
        ),
        accountProvider.overrideWith(
          (ref) => Stream.value(
            const SignedIn(
              email: 'kody@example.com',
              method: SignInMethod.email,
            ),
          ),
        ),
      ],
    ),
    build: (_) => const CalendarsPage(),
  );
  // M6.3: signed in and synced — `A-ios-settings` "Kody · synced just now".
  goldenMatrix(
    'settings_synced',
    height: 300,
    overrides: _overridesWith(
      extra: [
        syncServiceProvider.overrideWithValue(
          FakeSyncService(
            SyncStatus(
              state: SyncState.synced,
              lastSyncedUtc: DateTime.utc(2026, 10, 21, 9),
            ),
          ),
        ),
      ],
    ),
    build: (_) => _settings(),
  );
  // M6.1/M6.5: Account signed in (Sign out, Sign out everywhere, Delete).
  goldenMatrix(
    'settings_page_account_signed_in',
    height: 600,
    widths: const {'compact', 'expanded'},
    overrides: _overridesWith(
      extra: [
        accountServiceProvider.overrideWithValue(
          FakeAccountService(
            account: const SignedIn(
              email: 'kody@example.com',
              method: SignInMethod.email,
            ),
          ),
        ),
        // CR-160: no database behind the sign-out check.
        ...accountScreenOverrides(FakeAccountActions()),
      ],
    ),
    build: (_) => const AccountPage(),
  );
  // M3f.8: notifications denied, on Reminders.
  goldenMatrix(
    'settings_notifications_off',
    height: 900,
    widths: const {'compact', 'expanded'},
    act: (t) => t.scrollUntilVisible(
      find.text('Notifications are off'),
      200,
      scrollable: find.byType(Scrollable).first,
    ),
    overrides: _overridesWith(permission: const _Denied()),
    build: (_) => _page(SettingsPage.reminders),
  );
  // Android without "Alarms & reminders" (M5.6, derived).
  goldenMatrix(
    'settings_exact_alarm',
    height: 900,
    widths: const {'compact', 'expanded'},
    act: (t) => t.scrollUntilVisible(
      find.text('Reminders may come a few minutes after their time'),
      200,
      scrollable: find.byType(Scrollable).first,
    ),
    overrides: _overridesWith(exactAlarms: const _Inexact()),
    build: (_) => _page(SettingsPage.reminders),
  );
}

final class _Inexact implements ExactAlarms {
  const _Inexact();

  @override
  Future<bool> allowed() async => false;

  @override
  Future<void> request() async {}
}

final class _Denied implements NotificationPermission {
  const _Denied();

  @override
  Future<PermissionState> status() async => PermissionState.denied;

  @override
  Future<PermissionState> request() async => PermissionState.denied;

  @override
  Future<bool> openSettings() async => false;
}
