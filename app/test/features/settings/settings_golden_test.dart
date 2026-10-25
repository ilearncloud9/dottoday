// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
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
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/account_fakes.dart';
import '../../support/calendar_fakes.dart';
import '../../support/cloud_calendar_fakes.dart';
import '../../support/dot_golden.dart';
import '../../support/sync_fakes.dart';
import '../../support/timeline_fakes.dart';

final _overrides = _overridesWith();

List<Override> _overridesWith({
  NotificationPermission permission = const UnwiredNotificationPermission(),
  ExactAlarms exactAlarms = const AlwaysExactAlarms(),
  DeviceCalendarGateway calendarGateway = const NoDeviceCalendarGateway(),
  List<Override> extra = const [],
  Settings settings = const Settings(use24h: true),
}) => [
  ...extra,
  ...timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 9),
    profile: testProfile(settings: settings).copyWith(displayName: 'Kody'),
    notificationPermission: permission,
    exactAlarms: exactAlarms,
    calendarGateway: calendarGateway,
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
  goldenMatrix(
    'settings_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    overrides: _overrides,
    build: (_) => _settings(),
  );
  // The rest of the list (LOOK, DATA, ABOUT), scrolled.
  goldenMatrix(
    'settings_lower',
    height: 844,
    widths: const {'compact', 'expanded'},
    act: (tester) => tester.drag(find.byType(ListView), const Offset(0, -1200)),
    overrides: _overrides,
    build: (_) => _settings(),
  );
  // Derived (§5.3): Different days and Send feedback.
  goldenMatrix(
    'settings_weekdays',
    height: 844,
    widths: const {'compact', 'expanded'},
    act: (t) => _open(t, 'Different days'),
    overrides: _overrides,
    build: (_) => _settings(),
  );
  goldenMatrix(
    'settings_feedback',
    height: 640,
    widths: const {'compact', 'expanded'},
    act: (t) => _open(t, 'Send feedback'),
    overrides: _overrides,
    build: (_) => _settings(),
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
    build: (_) => _settings(),
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
    act: (t) async {
      await t.scrollUntilVisible(
        find.text('REMINDERS'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // REMINDERS at the top, so the whole group is in view.
      await Scrollable.ensureVisible(t.element(find.text('REMINDERS')));
    },
    overrides: reminders,
    build: (_) => _settings(),
  );
  for (final (name, row) in [
    ('settings_sound', 'Sound'),
    ('settings_day_summary', 'Day-start summary'),
  ]) {
    goldenMatrix(
      name,
      height: 844,
      widths: const {'compact', 'expanded'},
      act: (t) => _open(t, row),
      overrides: reminders,
      build: (_) => _settings(),
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
      ],
    ),
    build: (_) => const AccountPage(),
  );
  // M3f.8: notifications denied, above REMINDERS.
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
    build: (_) => _settings(),
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
    build: (_) => _settings(),
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
