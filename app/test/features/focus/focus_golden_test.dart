@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/features/focus/focus_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/focus_fakes.dart';
import '../../support/timeline_fakes.dart';

// Focus (`B-ios-focus`, docs/09 M10.5): full screen on phones and narrow
// windows, centred in the content area on Mac/web — the same view, its
// width capped to the readable column.

final _date = DateTime(2026, 10, 21);

void main() {
  // The fixtures below resolve Berlin while the tests are declared.
  tz_data.initializeTimeZones();
  final rows = demoDayRows(_date);
  final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
  final all = demoDaySubtasks(_date);
  final mine = [
    for (final s in all)
      if (s.occurrenceId == deep.id) s,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final steps = <Subtask>[
    for (final s in all)
      if (s.occurrenceId != deep.id) s,
    mine[0].copyWith(
      done: true,
      durationMin: 25,
      doneAt: DateTime.utc(2026, 10, 21, 7, 25),
    ),
    mine[1].copyWith(done: false, durationMin: 30),
    mine[2].copyWith(done: false, durationMin: 20),
  ];
  goldenMatrix(
    'focus',
    height: 1200,
    overrides: [
      ...timelineOverrides(
        // 9:40:40 Berlin: "STEP 2 OF 3 · 14:20 left".
        now: DateTime.utc(2026, 10, 21, 7, 40, 40),
        occurrences: FakeOccurrenceRepository(rows),
        subtasks: FakeSubtaskRepository(steps),
        profile: testProfile(settings: const Settings(use24h: true)),
      ),
      ...focusOverrides(
        deepWork: FakeDeepWork()..on = true,
        sounds: FakeSoundPlayer(),
      ),
    ],
    build: (_) => Scaffold(
      body: SafeArea(
        child: FocusView(id: deep.id, onLeave: () {}),
      ),
    ),
    act: (tester) async {
      // The step timer ticks every second: stop it with the test.
      addTearDown(() => tester.pumpWidget(const SizedBox()));
    },
  );
}
