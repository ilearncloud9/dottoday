// The parity rows (docs/parity-checklist.md, R-13): one per PRD feature ID.
// F1–F6 live in their own files; F7–F11 and the device runs are here.
import 'parity_model.dart';
import 'parity_rows_f1.dart';
import 'parity_rows_f2.dart';
import 'parity_rows_f5.dart';

/// The first-day journey (`integration_test/journey_test.dart`): onboarding,
/// quick add, drag with Shift later tasks, a repeat edited for all days.
const jIos = Cell(Status.device, 'journey · iPhone 17 Pro sim, M8.4b');
const jAnd = Cell(Status.device, 'journey · API 37 emulator, M8.4; CI API 34');

/// The Mac runs the journey's expanded variant: the three-day spread, a
/// mouse drag with Alt for "Shift later tasks", the editor panel (M8.4b).
const jMac = Cell(Status.device, 'journey (spread) · macOS, M8.4b');

/// Every row, keyed by PRD ID.
const parityRows = <String, ParityRow>{
  ...f1Rows,
  ...f2Rows,
  ...f5Rows,
  ...f6Rows,
  ..._f7Rows,
  ..._f8Rows,
};

const _f7Rows = <String, ParityRow>{
  'F7.1': ParityRow(
    tests: [
      'test/features/onboarding/flow_rules_test.dart',
      'test/features/onboarding/account_step_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    macos: Cell(Status.device, 'onboarding · macOS, M8.4'),
  ),
  'F7.2': ParityRow(
    tests: [
      'test/supabase/auth_flow_test.dart',
      'test/data/auth/supabase_account_service_test.dart',
      'test/web/auth_vault_web_test.dart',
    ],
    all: Cell(Status.owner, 'Apple/Google OAuth consoles (08 §6.1)'),
    note:
        'Email link verified on the iPhone sim, Android emulator and Chrome '
        '(M6.1); Apple and Google need the owner\'s console set-up on all four; '
        'the Mac email link is in the 08 §6.1 Mac run.',
  ),
  'F7.3': ParityRow(
    tests: [
      'test/data/sync/sync_engine_test.dart',
      'test/supabase/two_devices_test.dart',
      'supabase/tests/0002_sync_push.sql',
    ],
    all: ci,
    ios: Cell(Status.device, 'two devices by hand · sim, M6.6'),
    android: Cell(Status.device, 'two devices by hand · emulator, M6.6'),
    note:
        'Background sync on phones; Mac and web sync while open (M6.5.6). '
        'Offline-day and two-device scenarios on all four: 08 §6.2.',
  ),
  'F7.4': ParityRow(
    tests: [
      'test/shared/sync/sync_status_line_test.dart',
      'test/features/sync_status/sync_status_test.dart',
    ],
    all: ci,
    note: 'Concept A shows a status line, not a pill (M6.3).',
  ),
  'F7.5': ParityRow(
    tests: [
      'test/domain/export/export_import_test.dart',
      'test/data/backup/backup_service_test.dart',
      'test/features/settings/export_page_test.dart',
      'test/data/export/folder_writer_test.dart',
    ],
    all: Cell(Status.manual, 'system sheets reach the person (08 §6.1 E)'),
    note:
        'Share sheet on phones, save panel on the Mac, downloads on web (M8.1); '
        'logic is CI-tested, the system sheets need a person.',
  ),
  'F7.6': ParityRow(
    tests: [
      'test/data/trash/trash_purge_test.dart',
      'test/data/trash/trash_and_undo_test.dart',
      'test/features/settings/settings_pages_test.dart',
    ],
    all: ci,
  ),
  'F7.7': ParityRow(
    tests: [
      'test/supabase/delete_account_test.dart',
      'supabase/functions/delete-account/deletion_test.ts',
      'test/features/settings/settings_pages_test.dart',
    ],
    all: ci,
    note:
        'Confirmation email needs `delete-account` deployed with mail secrets '
        '(08 §6.1 Supabase project).',
  ),
};

const _f8Rows = <String, ParityRow>{
  'F8.1': ParityRow(
    tests: [
      'test/features/timeline/week_screen_test.dart',
      'test/features/timeline/month_screen_test.dart',
      'test/web_parity_test.dart',
      'test/policy/no_platform_layout_test.dart',
    ],
    all: ci,
    note:
        'Week board from 840 px; phones use the week strip + Month (10 §5.2 W1).',
  ),
  'F8.2': ParityRow(
    tests: [
      'test/data/repositories/search_repository_test.dart',
      'test/features/search/search_screen_test.dart',
      'tool/web_db_probe.dart',
    ],
    all: ci,
    web: Cell(
      Status.auto,
      'FTS5 in the WASM build: `tool/web_db_probe.dart` (CI)',
    ),
  ),
  'F8.3': ParityRow(
    tests: [
      'test/features/settings/settings_screen_test.dart',
      'test/features/settings/settings_pages_test.dart',
    ],
    all: ci,
    note:
        'Web shows "Uses your computer\'s lock" instead of App lock (07 Web). '
        'Four Concept A accents on every target; no Android dynamic accent '
        '(PRD F8.3, M8.4c).',
  ),
  'F9.1': ParityRow(
    tests: [
      'test/domain/snapshot/day_snapshot_test.dart',
      'test/data/snapshot/snapshot_store_json_test.dart',
      'test/policy/surface_contract_test.dart',
    ],
    all: ci,
    ios: Cell(
      Status.device,
      'Next up on the sim, M5.4; device needs App Group (08 §6.1)',
    ),
    android: Cell(Status.device, 'all three widgets · emulator, M5.4'),
    macos: Cell(Status.device, 'menu-bar Next up, M5.5'),
    web: Cell(Status.later, 'tab title, favicon, Badging API — M9.7'),
  ),
  'F9.2': ParityRow(
    tests: ['test/policy/surface_contract_test.dart'],
    all: Cell(Status.later, 'M9.3–M9.5'),
    macos: Cell(Status.later, 'menu-bar dot M9.6'),
    web: Cell(Status.later, 'web live dot M9.7'),
  ),
  'F9.3': ParityRow(tests: [], all: Cell(Status.na, 'Phase 2 (ADR-0010)')),
  'F10.1': ParityRow(
    tests: [
      'test/features/onboarding/flow_rules_test.dart',
      'test/features/onboarding/reminders_step_test.dart',
      'integration_test/onboarding_test.dart',
    ],
    all: ci,
    ios: Cell(Status.device, 'onboarding · iPhone 17 Pro sim, M8.4'),
    android: Cell(
      Status.device,
      'onboarding · API 37 emulator, M8.4; CI API 34',
    ),
    macos: Cell(Status.device, 'onboarding · macOS, M8.4'),
    note: 'Real OS permission prompts are in the 08 §6.1 hardware pass.',
  ),
  'F11.1': ParityRow(
    tests: [
      'test/domain/feedback_mail_test.dart',
      'test/data/feedback/diagnostics_reader_test.dart',
      'test/features/settings/whats_new_banner_test.dart',
    ],
    all: Cell(Status.manual, 'composer opens (08 §6.1 E)'),
    note: 'Recipient is an owner gate (08 §6.1 Feedback address).',
  ),
};

/// Device and browser runs behind the "✓ device" cells of M8.4.
const parityRuns = <Run>[
  Run(
    '2026-10-24',
    Target.ios,
    'device_tests.sh: app_launch, onboarding, journey, deep_link, notification_exactness (iPhone 17 Pro sim)',
    'all pass; app_launch failed once right after boot (onboarding timeout), passed on rerun; exactness 20/20/0',
  ),
  Run(
    '2026-10-24',
    Target.android,
    'device_tests.sh: app_launch, onboarding, journey, deep_link, notification_exactness (API 37 emulator)',
    'all pass; exactness 20/20/0',
  ),
  Run(
    '2026-10-24',
    Target.macos,
    'flutter test -d macos: app_launch, onboarding, deep_link, notification_exactness',
    'all pass after the AppRestart fix (onboarding\'s restart tripped the menu bar lock); exactness 20/20/0 with provisional authorisation',
  ),
  Run(
    '2026-10-24',
    Target.macos,
    'flutter test -d macos: journey',
    'not applicable: phone-shaped (pager fling); expanded variant M8.4b',
  ),
  Run(
    '2026-10-24',
    Target.web,
    'flutter test --platform chrome --tags web test/web; flutter build web',
    '7 Chrome tests pass (Playwright headless shell via CHROME_EXECUTABLE); release web build ok. No web integration driver in the repo (no chromedriver): CI a11y-web covers axe, PWA/CSP/offline and the encrypted DB probe',
  ),
];
