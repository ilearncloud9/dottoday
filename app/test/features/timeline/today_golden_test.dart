// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

/// Today at 09:22 in Berlin on the demo day (T1, `Main`).
Widget _today({
  TodayView? view,
  DateTime? date,
  Set<String>? picked,
  String? editing,
}) => ProviderScope(
  overrides: [
    if (editing != null)
      editingTaskProvider.overrideWith(() => _Editing(editing)),
    if (view != null) todaySelectionProvider.overrideWith(() => _Fixed(view)),
    if (picked != null)
      taskSelectionProvider.overrideWith(
        () => _Picked((day: DateTime(2026, 10, 21), ids: picked)),
      ),
    ...timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: FakeOccurrenceRepository(
        demoDayRows(DateTime(2026, 10, 21)),
      ),
      subtasks: FakeSubtaskRepository(demoDaySubtasks(DateTime(2026, 10, 21))),
      profile: testProfile(
        settings: const Settings(use24h: false, firstDayOfWeek: 7),
      ).copyWith(displayName: 'Kody'),
    ),
  ],
  child: editing == null
      ? TodayScreen(date: date)
      : EditorPanelFrame(child: TodayScreen(date: date)),
);

/// A selection pinned to [view] (month open / another month).
final class _Fixed extends TodaySelection {
  _Fixed(this.view);

  final TodayView view;

  @override
  TodayView build() => view;
}

/// The editor panel open on [id].
final class _Editing extends EditingTask {
  _Editing(this.id);

  final String id;

  @override
  String? build() => id;
}

/// Multi-select pinned to [picked].
final class _Picked extends TaskSelection {
  _Picked(this.picked);

  final Picked picked;

  @override
  Picked build() => picked;
}

/// Ids of the demo day's tasks called [titles].
Set<String> _ids(List<String> titles) => {
  for (final o in demoDayRows(DateTime(2026, 10, 21)))
    if (titles.contains(o.title)) o.id,
};

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'today',
    height: 844,
    widths: const {'compact', 'medium'},
    build: (_) => _today(),
  );
  // T5: the Mac/web three-day spread (`A-mac-today-alt1-spread`, M3e.1).
  goldenMatrix(
    'today_spread',
    height: 800,
    widths: const {'expanded', 'expanded_min'},
    build: (_) => _today(),
  );
  // E1 as the Mac/web panel (`A-mac-editor`, M3e.5).
  goldenMatrix(
    'today_editor_panel',
    height: 1000,
    widths: const {'expanded'},
    build: (_) => _today(editing: _ids(['Deep work: roadmap']).single),
  );
  // Multi-select (docs/03 §3.2, R-05): two picked, the bar at the bottom.
  goldenMatrix(
    'today_selecting',
    height: 844,
    widths: const {'compact', 'expanded'},
    build: (_) => _today(picked: _ids(['Team standup', 'Deep work: roadmap'])),
  );
  // T2: the month pulled open over today (`A-ios-today-month`). The
  // spread has no pull-open; Mac/web Month is its own page (M3e.4).
  goldenMatrix(
    'today_month_open',
    height: 1000,
    widths: const {'compact', 'medium'},
    build: (_) => _today(view: (day: null, monthOpen: true, month: null)),
  );
  // T3: planning a future month, a free day picked (`A-ios-future-month`).
  goldenMatrix(
    'today_future_month',
    height: 1000,
    widths: const {'compact', 'medium', 'expanded'},
    build: (_) => _today(
      view: (day: DateTime(2026, 12, 14), monthOpen: true, month: null),
    ),
  );
}
