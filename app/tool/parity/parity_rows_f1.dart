// Parity rows for PRD F1 (Timeline). See parity_model.dart for statuses.
import 'parity_model.dart';
import 'parity_rows.dart';

const f1Rows = <String, ParityRow>{
  'F1.1': ParityRow(
    tests: [
      'test/shared/dot/thread_day_test.dart',
      'test/features/timeline/today_screen_test.dart',
      'test/features/timeline/today_spread_test.dart',
      'test/web_parity_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    macos: Cell(Status.device, 'app_launch · macOS, M8.4'),
    note:
        'Concept A thread (ADR-0007): Wake Up → Bedtime with the now dot; the '
        'three-day spread from 840 px; Mac and web pixel-identical at 1280.',
  ),
  'F1.2': ParityRow(
    tests: [
      'test/shared/dot/thread_drag_test.dart',
      'test/features/timeline/today_drag_test.dart',
      'test/domain/scheduling/drag_math_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    macos: jMac,
    note:
        'Resize is the end grip only (M3b.5); the start moves with the task. '
        'Touch holds 250 ms, a mouse lifts at once (`today_spread_test`).',
  ),
  'F1.3': ParityRow(
    tests: [
      'test/features/timeline/today_drag_test.dart',
      'test/domain/scheduling/move_with_followers_test.dart',
      'test/shared/dot/thread_drag_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    macos: jMac,
    note: 'Touch: second finger toggles the chip (device runs); desktop: Alt.',
  ),
  'F1.4': ParityRow(
    tests: [
      'test/features/timeline/running_late_sheet_test.dart',
      'test/domain/scheduling/running_late_test.dart',
      'test/features/timeline/today_spread_test.dart',
    ],
    all: ci,
  ),
  'F1.5': ParityRow(
    tests: [
      'test/domain/scheduling/day_scheduler_test.dart',
      'test/shared/dot/thread_drag_test.dart',
    ],
    all: Cell(Status.gap, 'no pin control — M8.4b'),
    note:
        'Pins are honoured everywhere (scheduler, drag, Running late) but no '
        'screen lets a person pin or unpin a task.',
  ),
  'F1.6': ParityRow(
    tests: [
      'test/features/timeline/today_select_test.dart',
      'test/shared/dot/thread_select_test.dart',
    ],
    all: ci,
    note: 'One day at a time (M3b.7); desktop adds Shift/⌘/Ctrl-click.',
  ),
  'F1.7': ParityRow(
    tests: [
      'test/features/timeline/today_screen_test.dart',
      'test/shared/dot/thread_day_test.dart',
    ],
    all: ci,
  ),
  'F1.8': ParityRow(
    tests: [
      'test/features/timeline/today_screen_test.dart',
      'test/features/timeline/today_keys_test.dart',
      'test/shared/dot/day_pager_test.dart',
      'test/app_menu_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    web: Cell(Status.manual, '⌘/Ctrl+←/→ in real Chrome (08 §6.2)'),
    note:
        'Days step with ⌘/Ctrl+←/→ (07 macOS, 10 §4), not bare arrows; the '
        'Mac Go menu does the same. In a browser ⌘← may be Back — checked by hand.',
  ),
  'F1.9': ParityRow(
    tests: [
      'test/features/timeline/today_screen_test.dart',
      'test/shared/dot/task_dot_test.dart',
      'test/policy/no_shame_copy_test.dart',
    ],
    all: ci,
    note: 'The done haptic is felt only on a phone (08 §6.1 hardware pass).',
  ),
  'F1.10': ParityRow(
    tests: [
      'test/shared/dot/thread_day_test.dart',
      'test/shared/dot/thread_golden_test.dart',
    ],
    all: Cell(Status.gap, 'no calendar badge on rows — M8.4b'),
    note:
        'Time, title, icon and colour show on every row; subtask progress on '
        'the live row and the sheet (10 §3); imported events have no badge.',
  ),
  'F1.11': ParityRow(
    tests: [
      'test/shared/dot/thread_drag_test.dart',
      'test/domain/scheduling/drag_math_test.dart',
      'test/features/timeline/today_spread_test.dart',
    ],
    all: ci,
    ios: jIos,
    android: jAnd,
    note:
        'Lift haptic needs a physical phone (08 §6.1 hardware pass); edge '
        'auto-scroll is Flutter\'s `EdgeDraggingAutoScroller`.',
  ),
  'F1.12': ParityRow(
    tests: [
      'test/shared/dot/thread_drag_test.dart',
      'test/features/timeline/today_drag_test.dart',
      'test/data/calendar/calendar_shift_test.dart',
    ],
    all: ci,
    ios: Cell(Status.device, 'calendar_write_back · sim, M7.7'),
    android: Cell(Status.device, 'calendar_write_back · emulator, M7.7'),
    macos: Cell(Status.owner, 'Calendars on this Mac (08 §6.1)'),
    note: 'Web calendar events come from Google/Microsoft (F5.1).',
  ),
  'F1.13': ParityRow(
    tests: [
      'test/shared/dot/thread_day_test.dart',
      'test/features/timeline/layout/week_layout_test.dart',
    ],
    all: Cell(Status.gap, 'columns or a recorded decision — M8.4b'),
    note:
        'Overlaps are allowed; the thread lists them in start order with the '
        'overrun line, the Week board stacks them. No side-by-side columns.',
  ),
  'F1.14': ParityRow(
    tests: [
      'test/data/perf/db_performance_test.dart',
      'integration_test/thread_perf_test.dart',
    ],
    all: ci,
    ios: Cell(Status.owner, 'iPhone 12-class profile run (08 §6.1)'),
    android: Cell(Status.owner, 'Pixel 6a profile run, M5.9b (08 §6.1)'),
    macos: Cell(Status.device, 'profile run 0 missed frames, M3b.9'),
    note:
        '`thread_perf_test` needs `flutter drive --profile` on hardware '
        '(M5.9b); the thread is a sliver (lazy) on every target.',
  ),
  'F1.15': ParityRow(
    tests: [
      'test/domain/time/day_boundaries_test.dart',
      'test/data/scheduling/day_room_providers_test.dart',
    ],
    all: Cell(Status.gap, 'outside-hours zone + test — M8.4b'),
    note:
        'Per-weekday Wake Up/Bedtime work (M3d.3); a task outside them '
        'renders inline but has no test and no collapsed zone.',
  ),
  'F1.16': ParityRow(
    tests: [
      'test/shared/dot/thread_golden_test.dart',
      'test/features/timeline/layout/timeline_day_test.dart',
    ],
    all: Cell(Status.gap, 'bottom-of-day golden — M8.4b'),
  ),
  'F1.17': ParityRow(
    tests: [
      'test/keyboard_flow_test.dart',
      'test/features/timeline/today_keys_test.dart',
      'test/core/shortcuts/app_shortcuts_test.dart',
    ],
    all: Cell(Status.gap, '↑↓ select, ⌘↑↓ move, Delete — M8.4b'),
    ios: Cell(
      Status.na,
      'desktop/web keys (PRD); hardware keyboards get the same',
    ),
    android: Cell(
      Status.na,
      'desktop/web keys (PRD); hardware keyboards get the same',
    ),
    note:
        'Built: Tab/Enter open, Enter/Space done, ⌘/Ctrl+D, ⌘/Ctrl+←/→/T, Esc '
        '(M3e.6). Missing on Mac and web: ↑↓ select, ⌘/Ctrl+↑↓ move 5 (Shift '
        '15), Delete → Trash with Undo.',
  ),
  'F1.18': ParityRow(
    tests: [
      'test/shared/feedback/undo_snackbar_test.dart',
      'test/features/timeline/today_drag_test.dart',
      'test/features/timeline/today_select_test.dart',
      'test/app_menu_test.dart',
    ],
    all: ci,
  ),
};
