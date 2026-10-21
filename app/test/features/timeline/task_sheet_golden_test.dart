// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

/// The live task's sheet at 09:22 (T4, `A-ios-task-sheet`).
Widget _sheet() {
  final date = DateTime(2026, 10, 21);
  final rows = demoDayRows(date);
  final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
  return ProviderScope(
    overrides: timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: FakeOccurrenceRepository(rows),
      subtasks: FakeSubtaskRepository(demoDaySubtasks(date)),
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
    child: TaskScreen(id: deep.id),
  );
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'task_sheet',
    height: 760,
    widths: const {'compact', 'medium'},
    build: (_) => _sheet(),
  );
}
