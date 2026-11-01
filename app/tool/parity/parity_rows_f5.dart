// Parity rows for PRD F5 (calendars) and F6 (notifications).
import 'parity_model.dart';

const _macCal = Cell(Status.owner, 'Calendars on this Mac (08 §6.1)');
const _cloud = Cell(Status.owner, 'Google/Microsoft calendars (08 §6.1)');

const f5Rows = <String, ParityRow>{
  'F5.1': ParityRow(
    tests: [
      'integration_test/calendar_prompt_test.dart',
      'test/data/calendar/channel_device_calendar_gateway_test.dart',
      'test/data/calendar/function_cloud_calendars_test.dart',
      'supabase/tests/0005_calendar_oauth.sql',
    ],
    all: ci,
    ios: Cell(Status.device, 'calendar_prompt/denied · sim, M7.7'),
    android: Cell(Status.device, 'calendar_prompt/denied · emulator, M7.7'),
    macos: _macCal,
    web: _cloud,
    note:
        'Device calendars on iPhone/Android (EventKit, CalendarContract) and '
        'the Mac (EventKit channel, M7.1b); Google/Microsoft on all four through '
        'the backend (owner gate: OAuth clients); Apple on web via CalDAV is '
        'Phase 2 (07 Web).',
  ),
  'F5.2': ParityRow(
    tests: [
      'test/features/timeline/all_day_import_test.dart',
      'test/features/settings/calendars_page_test.dart',
      'test/features/settings/cloud_calendars_group_test.dart',
    ],
    all: ci,
    ios: Cell(Status.device, 'calendar_import · sim, M7.7'),
    android: Cell(Status.device, 'calendar_import · emulator, M7.7'),
    macos: _macCal,
    web: _cloud,
  ),
  'F5.3': ParityRow(
    tests: [
      'test/data/calendar/calendar_importer_test.dart',
      'test/domain/calendar/calendar_import_plan_test.dart',
      'integration_test/calendar_import_test.dart',
    ],
    all: ci,
    ios: Cell(Status.device, 'calendar_import · sim, M7.7'),
    android: Cell(Status.device, 'calendar_import · emulator, M7.7'),
    macos: _macCal,
    web: _cloud,
  ),
  'F5.4': ParityRow(
    tests: [
      'integration_test/calendar_write_back_test.dart',
      'test/domain/calendar/write_back_merge_test.dart',
      'supabase/functions/calendar-sync/sync_test.ts',
    ],
    all: ci,
    ios: Cell(
      Status.device,
      'calendar_write_back/revoked/regranted · sim, M7.7',
    ),
    android: Cell(
      Status.device,
      'calendar_write_back/revoked · emulator, M7.7',
    ),
    macos: _macCal,
    web: _cloud,
    note: 'Invitees kept on a real iPhone: owner gate (08 §6.1).',
  ),
  'F5.5': ParityRow(
    tests: [
      'test/domain/calendar/travel_time_test.dart',
      'test/features/timeline/travel_suggestion_test.dart',
      'test/features/timeline/task_sheet_travel_golden_test.dart',
    ],
    all: ci,
    note:
        'A rule on the device, no routing service (M7.5): same Dart on all four.',
  ),
  'F5.6': ParityRow(
    tests: [
      'test/core/utils/web_links_test.dart',
      'test/features/timeline/note_links_test.dart',
    ],
    all: ci,
    ios: Cell(Status.device, 'calendar_import opens Safari · sim, M7.7'),
    android: Cell(
      Status.device,
      'calendar_import opens Chrome · emulator, M7.7',
    ),
  ),
  'F5.7': ParityRow(
    tests: [
      'test/domain/calendar/calendar_import_plan_test.dart',
      'test/data/calendar/calendar_series_writes_test.dart',
      'test/domain/calendar/calendar_series_edit_test.dart',
      'test/features/timeline/editor_calendar_series_test.dart',
      'test/data/calendar/calendar_series_write_back_test.dart',
      'test/data/calendar/calendar_series_channel_test.dart',
      'supabase/functions/calendar-sync/sync_test.ts',
      'supabase/functions/_shared/calendar/calendar_test.ts',
    ],
    all: ci,
    note:
        'Google/Microsoft series write-back waits on the calendar-sync '
        'deploy (owner gate, 08 §6.1).',
  ),
};

const f6Rows = <String, ParityRow>{
  'F6.1': ParityRow(
    tests: [
      'test/shared/pickers/alerts_editor_test.dart',
      'test/domain/notifications/notification_planner_test.dart',
    ],
    all: ci,
    note: 'Minutes before are a fixed set 5/10/15/30/60 (M3f.2 decision).',
  ),
  'F6.2': ParityRow(
    tests: [
      'test/domain/notifications/notification_planner_test.dart',
      'test/domain/notifications/wind_down_reminder_test.dart',
      'test/domain/notifications/day_summary_test.dart',
      'test/features/settings/settings_screen_test.dart',
    ],
    all: ci,
    note:
        'M8.4d: default set (up to 5) in the Alerts editor; Quiet hours '
        '(loud first dot still rings); day-start summary per weekday at Wake '
        'Up, skipped on an empty day; Apple keeps the nearest 50 pending.',
  ),
  'F6.3': ParityRow(
    tests: [
      'test/domain/notifications/notification_planner_test.dart',
      'test/data/notifications/os_notification_gateway_test.dart',
      'test/data/notifications/timer_notification_platform_test.dart',
      'integration_test/notification_exactness_test.dart',
    ],
    all: ci,
    ios: Cell(Status.device, 'notification_exactness 20/20/0 · sim, M8.4'),
    android: Cell(
      Status.device,
      'notification_exactness 20/20/0 · emulator, M8.4',
    ),
    macos: Cell(Status.device, 'notification_exactness 20/20/0 · macOS, M8.4'),
  ),
  'F6.4': ParityRow(
    tests: [
      'test/data/notifications/notification_responder_test.dart',
      'test/data/notifications/fln_notification_platform_test.dart',
      'test/features/notifications/in_app_alert_banner_test.dart',
    ],
    all: ci,
    macos: macNotify,
    note:
        'Web system notifications carry Done and Open (Chrome shows two '
        'actions, M5.3a); the in-app strip offers Done and Snooze 10 min '
        '(M8.4d).',
  ),
  'F6.5': ParityRow(
    tests: [
      'test/data/notifications/notification_content_test.dart',
      'test/domain/notifications/notification_payload_test.dart',
    ],
    all: ci,
  ),
  'F6.6': ParityRow(
    tests: [
      'test/data/notifications/alarm_sound_test.dart',
      'test/data/notifications/reminder_sounds_test.dart',
      'test/data/notifications/fln_notification_platform_test.dart',
      'test/data/notifications/in_app_alerts_test.dart',
      'test/data/notifications/sound_player_test.dart',
      'test/domain/notifications/sound_resolution_test.dart',
      'test/policy/sounds_manifest_test.dart',
      'test/policy/mac_bundled_sounds_test.dart',
      'test/features/settings/sounds_page_test.dart',
      'integration_test/sound_channels_test.dart',
      'integration_test/sound_test.dart',
    ],
    all: Cell(Status.manual, 'hear each sound and its preview (08 §6.1 E)'),
    note:
        'M8.4d: Dot, Chime, Bell, Ripple (tool/gen_sounds.dart) or the '
        'system sound. M15 (docs/12, ADR-0015): 48 bundled sounds, a sound '
        'per task, a Start sound for loud dots, a Done sound; Android one '
        'channel per sound (45), Apple a .caf per notification, the web '
        'plays it in the in-app strip. Focus/DND respected (time-sensitive '
        'on Apple, health panel M6.5.8 names a muted sound channel).',
  ),
  'F6.7': ParityRow(
    tests: [
      'test/web/browser_notifications_web_test.dart',
      'test/data/notifications/server_push_mirror_test.dart',
      'supabase/tests/0003_web_push.sql',
    ],
    all: Cell(Status.na, 'web-only bullet'),
    web: Cell(
      Status.manual,
      'sw.js in real Chrome (08 §6.1 E); VAPID (08 §6.1)',
    ),
  ),
  'F6.8': ParityRow(
    tests: [
      'test/domain/notifications/alarm_policy_test.dart',
      'test/policy/time_sensitive_entitlement_test.dart',
      'integration_test/killed_app_schedule_test.dart',
      'test/domain/notifications/notification_health_test.dart',
    ],
    all: ci,
    ios: Cell(
      Status.owner,
      'time-sensitive on a real iPhone (08 §6.1); killed-app sim M6.5.10',
    ),
    android: Cell(Status.device, 'killed_app_check · CI emulator, every push'),
    macos: Cell(
      Status.owner,
      'Release time-sensitive entitlement, paid team (08 §6.1)',
    ),
  ),
};

/// macOS notification actions: delivery is counted (M8.4), the buttons in
/// Notification Center need a person (08 §6.1).
const macNotify = Cell(Status.owner, 'Done/Snooze/Open on the Mac (08 §6.1)');
