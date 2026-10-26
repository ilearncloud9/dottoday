@Tags(['golden'])
library;

import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_flow.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/thinking_fakes.dart';
import '../../support/timeline_fakes.dart';

// Break it down's mini thread (`B-ios-break-it-down`, docs/09 M10.4) at 1,
// 3 and 7 steps: a sheet on phones, a popover at the medium width, the
// right-hand panel at the expanded width.

const _titles = [
  'Gather documents',
  'Log in to the portal',
  'Enter income',
  'Enter deductions',
  'Check the totals',
  'Review and submit',
  'Save the receipt',
];
const _minutes = [10, 15, 40, 25, 10, 10, 5];

String _answer(int n) => jsonEncode({
  'steps': [
    for (var i = 0; i < n; i++) {'title': _titles[i], 'minutes': _minutes[i]},
  ],
});

final _taxes = Occurrence(
  id: '01928c3e-0000-7000-8000-00000000d0a1',
  userId: testUserId,
  title: 'Do taxes',
  startUtc: DateTime.utc(2026, 10, 21, 14),
  tzId: 'Europe/Berlin',
  durationMin: 90,
  colorKey: 'amber',
  iconKey: 'list',
  createdAt: DateTime.utc(2026, 10, 20),
  updatedAt: DateTime.utc(2026, 10, 20),
);

class _Opener extends StatelessWidget {
  const _Opener();

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => breakDown(context, BreakdownTarget.task(_taxes)),
      child: const Text('Open'),
    ),
  );
}

void main() {
  setUpAll(tz_data.initializeTimeZones);
  for (final steps in [1, 3, 7]) {
    // A model proposes at most 5 steps (M10.1); 7 is the user's usual
    // breakdown, which the sheet holds in full.
    final memory = LocalThinkingMemory(AppDatabase(NativeDatabase.memory()));
    goldenMatrix(
      'breakdown_mini_thread_$steps',
      height: 1300,
      overrides: [
        ...timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 7, 22),
          occurrences: FakeOccurrenceRepository([_taxes]),
          subtasks: FakeSubtaskRepository(const []),
          profile: testProfile(),
        ),
        thinkingTransportProvider.overrideWithValue(
          FakeThinkingTransport(
            answers: {ThinkingKind.breakDown: _answer(steps)},
          ),
        ),
        thinkingMemoryProvider.overrideWithValue(memory),
      ],
      build: (_) => const Scaffold(body: ProposalHost(child: _Opener())),
      act: (tester) async {
        await tester.runAsync(() async {
          await memory.clear();
          if (steps == 7) {
            await memory.saveBreakdown('Do taxes', [
              for (var i = 0; i < 7; i++)
                ProposedStep(title: _titles[i], durationMin: _minutes[i]),
            ]);
          }
          await tester.tap(find.text('Open'));
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
      },
    );
  }
}
