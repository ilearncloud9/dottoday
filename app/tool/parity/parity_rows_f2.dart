// Parity rows for PRD F2 (Quick Add & editor), F3 (Inbox), F4 (Recurrence).
import 'parity_model.dart';
import 'parity_rows.dart';

const f2Rows = <String, ParityRow>{
  'F2.1': ParityRow(
    tests: [
      'test/domain/quick_add/quick_add_parser_test.dart',
      'test/features/task_editor/add_what_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    macos: jMac,
  ),
  'F2.2': ParityRow(
    tests: [
      'test/features/task_editor/add_bulk_test.dart',
      'test/data/quick_add/quick_add_actions_test.dart',
      'test/web/paste_web_test.dart',
    ],
    all: ci,
    web: Cell(Status.auto, '`test/web/paste_web_test.dart` in Chrome (CI)'),
    note: 'A real clipboard paste on a phone is in the 08 §6.1 hardware pass.',
  ),
  'F2.3': ParityRow(
    tests: [
      'test/features/timeline/task_editor_test.dart',
      'test/features/timeline/editor_panel_test.dart',
      'test/features/timeline/task_sheet_test.dart',
    ],
    all: ci,
    note: 'Sheet below 840 px, side panel above — by width, not platform.',
  ),
  'F2.4': ParityRow(
    tests: [
      'test/app_shell_test.dart',
      'test/features/task_editor/add_what_test.dart',
      'test/app_menu_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    macos: jMac,
    web: Cell(
      Status.manual,
      '⌘/Ctrl+N in real Chrome (08 §6.1 E); rail + always works',
    ),
  ),
  'F2.5': ParityRow(
    tests: [
      'test/domain/quick_add/quick_add_parser_test.dart',
      'test/core/l10n/quick_add_hints_test.dart',
      'test/features/task_editor/add_what_test.dart',
    ],
    all: ci,
  ),
  'F2.6': ParityRow(
    tests: ['test/shared/time_input/time_input_test.dart'],
    all: ci,
  ),
  'F2.7': ParityRow(
    tests: [
      'test/shared/duration/duration_chips_test.dart',
      'test/shared/duration/duration_sheet_test.dart',
      'test/domain/time/duration_presets_test.dart',
    ],
    all: ci,
    note: 'Presets are editable, default 15 30 45 1 h 1.5 h 2 h (M3c.3).',
  ),
  'F2.8': ParityRow(
    tests: [
      'test/features/task_editor/add_when_test.dart',
      'test/features/task_editor/add_bulk_test.dart',
    ],
    all: ci,
  ),
  'F2.9': ParityRow(
    tests: [
      'test/features/timeline/task_editor_test.dart',
      'test/domain/validation/entity_validators_test.dart',
      'test/features/timeline/note_links_test.dart',
      'test/features/timeline/note_text_test.dart',
      'test/core/utils/markdown_lite_test.dart',
      'test/domain/recurrence/series_edit_test.dart',
    ],
    all: ci,
    note:
        'Built with the PRD limits: title, notes (links tap), start, duration, '
        'colour, icon, subtasks, alerts, repeat, travel buffer, pinned '
        '(M8.4b); energy chips and markdown-lite notes rendered in the sheet '
        '(M8.4c).',
  ),
  'F2.10': ParityRow(
    tests: [
      'test/features/task_editor/add_what_test.dart',
      'test/features/timeline/task_editor_test.dart',
      'test/features/task_editor/add_save_failure_test.dart',
      'test/features/timeline/editor_save_failure_test.dart',
    ],
    all: ci,
  ),
  'F2.11': ParityRow(
    tests: [
      'test/domain/scheduling/task_progress_test.dart',
      'test/features/timeline/editor_subtasks_test.dart',
      'test/data/db/migration_test.dart',
      'test/domain/scheduling/step_lengths_test.dart',
      'test/features/timeline/editor_step_lengths_test.dart',
      'test/features/focus/focus_view_test.dart',
    ],
    all: ci,
    note:
        'Data (M6.5.1), order and reorder (M3f.3), actual end on Done '
        '(M6.5.2), step lengths and "Length = sum of steps" in the editor '
        '(M10.3), actual start on opening Focus (M10.5).',
  ),
  'F3.1': ParityRow(
    tests: [
      'test/features/inbox/inbox_screen_test.dart',
      'test/features/inbox/wide_inbox_test.dart',
    ],
    all: ci,
    note:
        'Schedule sheet with suggestions everywhere; drag onto Today from the '
        'wide sidebar (≥ 840 px, M3e.2). Compact/medium place by dragging on '
        "the Schedule sheet's thread (PRD F3.1, M8.4c).",
  ),
  'F3.2': ParityRow(
    tests: [
      'test/features/inbox/inbox_screen_test.dart',
      'test/features/inbox/inbox_reorder_select_test.dart',
      'test/domain/scheduling/inbox_order_test.dart',
    ],
    all: ci,
    note:
        'Wide: +, right-click and screen-reader actions replace swipes (M3e.2).',
  ),
  'F3.3': ParityRow(
    tests: [
      'test/features/inbox/inbox_screen_test.dart',
      'test/domain/snapshot/day_snapshot_test.dart',
      'test/shared/navigation/dot_shell_test.dart',
      'test/domain/scheduling/inbox_nudge_test.dart',
      'test/features/timeline/inbox_nudge_card_test.dart',
      'test/data/inbox/inbox_nudge_seen_test.dart',
    ],
    all: ci,
    note:
        'Count on the Inbox tab/rail at every width, in the header and the '
        'Inbox widget; the plan-your-inbox card on Today, off by default '
        '(M8.4c).',
  ),
  'F4.1': ParityRow(
    tests: [
      'test/domain/recurrence/repeat_rule_test.dart',
      'test/shared/pickers/repeat_editor_test.dart',
      'test/domain/recurrence/recurrence_expander_test.dart',
    ],
    all: ci,
  ),
  'F4.2': ParityRow(
    tests: [
      'test/domain/recurrence/series_edit_test.dart',
      'test/features/timeline/editor_repeat_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    macos: jMac,
  ),
  'F4.3': ParityRow(
    tests: [
      'test/domain/recurrence/materialiser_test.dart',
      'test/domain/recurrence/series_edit_test.dart',
    ],
    all: ci,
  ),
  'F4.4': ParityRow(
    tests: [
      'test/domain/recurrence/subtask_occurrence_test.dart',
      'test/domain/recurrence/subtask_template_test.dart',
      'test/features/timeline/task_sheet_test.dart',
    ],
    all: ci,
  ),
  'F4.5': ParityRow(
    tests: ['test/domain/recurrence/recurrence_expander_test.dart'],
    all: ci,
    note: 'New York spring/fall cases added in M8.4 (Berlin existed).',
  ),
  'F4.6': ParityRow(
    tests: [
      'test/domain/recurrence/materialiser_test.dart',
      'test/data/refresh/daily_refresh_test.dart',
      'integration_test/background_refresh_test.dart',
    ],
    all: ci,
    ios: Cell(Status.owner, 'BGAppRefresh fires on a device (M8.5)'),
    android: Cell(Status.device, 'background_refresh · emulator, M5.2'),
    note:
        'Mac and web refresh on start, resume and every 6 h while open '
        '(M5.2, M6.5.6); web offline via the service worker (CI pwa_check).',
  ),
};
