// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_flow.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/memory_database.dart';
import '../../support/thinking_fakes.dart';
import '../../support/timeline_fakes.dart';

// Break it down as E-R2-23 §1 draws it (ED-324), in the app's fonts: the
// on-device proposal ("was 2 h → now 2 h 15", four steps with rings and
// lengths, Add a step, Total, the Smallest step line), a step opened,
// the simple-rules fallback, Android, and the Mac panel beside the day.

// l10n-ignore-start: test data, the board's task and steps
const _steps = [
  ('Gather the numbers', 20),
  ('Outline the sections', 25),
  ('Write the draft', 75),
  ('Read it through', 15),
];
// l10n-ignore-end

final _report = Occurrence(
  id: '01928c3e-0000-7000-8000-00000000d0b1',
  userId: testUserId,
  title: 'Write the Q4 report', // l10n-ignore: test data
  startUtc: DateTime.utc(2026, 11, 4, 13),
  tzId: 'Europe/Berlin',
  durationMin: 120,
  colorKey: 'indigo',
  iconKey: 'document',
  createdAt: DateTime.utc(2026, 11, 1),
  updatedAt: DateTime.utc(2026, 11, 1),
);

class _Opener extends StatelessWidget {
  const _Opener();

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => breakDown(context, BreakdownTarget.task(_report)),
      child: const Text('Open'), // l10n-ignore: test trigger
    ),
  );
}

List<Override> _overrides({required bool model}) {
  final memory = LocalThinkingMemory(AppDatabase(NativeDatabase.memory()));
  return [
    ...timelineOverrides(
      now: DateTime.utc(2026, 11, 4, 8),
      occurrences: FakeOccurrenceRepository([_report]),
      subtasks: FakeSubtaskRepository(const []),
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
    thinkingTransportProvider.overrideWithValue(
      FakeThinkingTransport(
        state: model
            ? ThinkingAvailability.available
            : ThinkingAvailability.notEnabled,
        answers: {
          ThinkingKind.breakDown: jsonEncode({
            'steps': [
              for (final (t, m) in _steps) {'title': t, 'minutes': m},
            ],
          }),
        },
      ),
    ),
    thinkingMemoryProvider.overrideWithValue(memory),
    // The rules hint reads what was put away from the app database.
    ...memoryDatabaseOverrides(),
  ];
}

Future<void> _open(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.tap(find.text('Open'));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pumpAndSettle();
}

Widget _build(GoldenCell _) =>
    const Scaffold(body: ProposalHost(child: _Opener()));

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'breakdown_plan',
    height: 1000,
    widths: const {'compact', 'expanded'},
    overrides: _overrides(model: true),
    build: _build,
    act: _open,
  );
  goldenMatrix(
    'breakdown_plan_android',
    height: 1000,
    widths: const {'compact'},
    platform: TargetPlatform.android,
    overrides: _overrides(model: true),
    build: _build,
    act: _open,
  );
  goldenMatrix(
    'breakdown_plan_open',
    height: 1200,
    widths: const {'compact'},
    overrides: _overrides(model: true),
    build: _build,
    act: (tester) async {
      await _open(tester);
      // Open Write the draft and break it down again (depth 2 of 3).
      await tester.tap(find.byTooltip('More for Write the draft'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Break this down'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
    },
  );
  goldenMatrix(
    'breakdown_step_length',
    height: 700,
    widths: const {'compact'},
    overrides: _overrides(model: true),
    build: _build,
    act: (tester) async {
      await _open(tester);
      await tester.tap(find.text('20 min'));
      await tester.pumpAndSettle();
    },
  );
  goldenMatrix(
    'breakdown_plan_rules',
    height: 1000,
    widths: const {'compact'},
    overrides: _overrides(model: false),
    build: _build,
    act: _open,
  );
}
