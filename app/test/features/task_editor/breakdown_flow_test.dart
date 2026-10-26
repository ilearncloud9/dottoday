import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_flow.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/proposal_harness.dart';
import '../../support/sample_proposal.dart';
import '../../support/test_app.dart';
import '../../support/thinking_fakes.dart';

// Break it down (11 B1, docs/09 M10.4): model steps as a mini thread in
// the proposal sheet; nothing is written before Accept; Accept writes the
// steps and grows the task; depth stops at 3; without a model, the usual
// breakdown or an empty template.

final _now = DateTime.utc(2026, 10, 21, 13);
const _steps =
    '{"steps":[{"title":"Clear the inbox","minutes":10},'
    '{"title":"Reply to Sam","minutes":15},{"title":"Archive","minutes":5}]}';

Occurrence get _task => sampleDayRows().first; // Reply to email, 30 min

class _Opener extends StatelessWidget {
  const _Opener({this.draft});

  final ValueChanged<List<ProposedStep>>? draft;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => breakDown(
        context,
        draft == null
            ? BreakdownTarget.task(_task)
            : BreakdownTarget(
                title: 'Do taxes',
                durationMin: 30,
                colorKey: 'amber',
                iconKey: 'list',
                onDraftAccepted: draft,
              ),
      ),
      child: const Text('Break it down'),
    ),
  );
}

Future<(ProposalHarness, FakeThinkingTransport)> _pump(
  WidgetTester tester, {
  ThinkingAvailability model = ThinkingAvailability.available,
  ValueChanged<List<ProposedStep>>? draft,
  double width = 390,
  WriteBatch? history,
}) async {
  tester.view
    ..physicalSize = Size(width, 1600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = ProposalHarness(_now);
  addTearDown(() => h.dispose(tester));
  final transport = FakeThinkingTransport(
    state: model,
    answers: {
      ThinkingKind.breakDown: _steps,
      ThinkingKind.suggestDuration: '{"minutes":20}',
    },
  );
  await h.seed(
    tester,
    WriteBatch(
      userId: userId,
      profile: profileFixture(),
      occurrences: [...sampleDayRows(), ...?history?.occurrences],
      subtasks: [...?history?.subtasks],
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...h.overrides,
        thinkingTransportProvider.overrideWithValue(transport),
      ],
      child: testApp(
        Scaffold(
          body: ProposalHost(child: _Opener(draft: draft)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (h, transport);
}

/// Taps Break it down and lets the database answer: real waits and pumps
/// in turn (the reads hop between the real and the test zone) until the
/// sheet is up, at most 2 s.
Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Break it down'));
  for (
    var i = 0;
    i < 20 && find.byType(ProposalSheet).evaluate().isEmpty;
    i++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> _accept(WidgetTester tester) async {
  final accept = find.text('Accept');
  await tester.ensureVisible(accept);
  await tester.runAsync(() async {
    await tester.tap(accept);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pumpAndSettle();
}

Finder _field(String text) => find.widgetWithText(TextField, text);

/// Three earlier runs of [_task] with "Reply to Sam" really ticked 25 min
/// after the real start (docs/13 §5).
WriteBatch _replyHistory() {
  final runs = [
    for (var d = 1; d <= 3; d++)
      _task.copyWith(
        id: '01928c3e-0000-7000-8000-00000000d00$d',
        startUtc: _now.subtract(Duration(days: d)),
        actualStartUtc: _now.subtract(Duration(days: d)),
        actualEndUtc: _now.subtract(Duration(days: d, minutes: -30)),
      ),
  ];
  return WriteBatch(
    userId: userId,
    occurrences: runs,
    subtasks: [
      for (final (i, o) in runs.indexed)
        subtaskFixture().copyWith(
          id: '01928c3e-0000-7000-8000-00000000e00$i',
          occurrenceId: o.id,
          title: 'Reply to Sam',
          done: true,
          doneAt: o.actualStartUtc!.add(const Duration(minutes: 25)),
        ),
    ],
  );
}

void main() {
  testWidgets('the usual breakdown proposes usual step lengths, unwritten', (
    tester,
  ) async {
    final (h, transport) = await _pump(tester, history: _replyHistory());
    await _open(tester);
    await _accept(tester); // remembers the model's steps (Reply to Sam 15)
    transport.prompts.clear();
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () => _open(tester),
      leave: () => tester.tap(find.text('Discard')),
    );
    await _open(tester);
    expect(find.text('your usual'), findsOneWidget);
    // Reply to Sam really takes 25 min; the others keep their saved 10/5.
    expect(find.text('Total 40 min · the dot grows to fit'), findsOneWidget);
    expect(transport.prompts, isEmpty);
  });

  testWidgets('nothing is written before Accept', (tester) async {
    final (h, _) = await _pump(tester);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () => _open(tester),
      edit: () async {
        await tester.enterText(_field('Archive'), 'Archive the rest');
        await tester.tap(find.text('Add a step'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('10 min').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('20 min').last);
      },
      leave: () => tester.tap(find.text('Discard')),
    );
  });

  testWidgets('Accept writes the steps, grows the dot, remembers them', (
    tester,
  ) async {
    final (h, transport) = await _pump(tester);
    await _open(tester);
    expect(find.text('on-device'), findsOneWidget);
    expect(find.text('Total 30 min · the dot grows to fit'), findsOneWidget);
    await tester.enterText(_field('Archive'), 'Archive the rest');
    await tester.pumpAndSettle();
    await _accept(tester);
    final batch = h.writes.batches.single;
    expect(batch.subtasks.map((s) => (s.title, s.durationMin)), [
      ('Clear the inbox', 10),
      ('Reply to Sam', 15),
      ('Archive the rest', 5),
    ]);
    expect(batch.subtasks.every((s) => s.occurrenceId == _task.id), isTrue);
    expect(find.text('Steps added to Reply to email'), findsOneWidget);
    // The usual breakdown is offered next time, without the model.
    transport.prompts.clear();
    await _open(tester);
    expect(find.text('your usual'), findsOneWidget);
    expect(_field('Archive the rest'), findsOneWidget);
    expect(transport.prompts, isEmpty);
  });

  testWidgets('a step splits to depth 3 and no further', (tester) async {
    final (_, transport) = await _pump(tester);
    await _open(tester);
    transport.answers[ThinkingKind.breakDown] =
        '{"steps":[{"title":"Open mail","minutes":5}]}';
    Future<void> splitFirst(String title) async {
      await tester.tap(find.byTooltip('More for $title'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Break this down').first);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
    }

    await splitFirst('Clear the inbox');
    expect(find.text('depth 2 of 3'), findsOneWidget);
    await splitFirst('Open mail');
    expect(find.text('depth 3 of 3'), findsOneWidget);
    await tester.tap(find.byTooltip('More for Open mail').last);
    await tester.pumpAndSettle();
    expect(find.text('Break this down'), findsNothing, reason: 'depth 3');
    expect(transport.prompts.map((p) => p.prompt).last, contains('Open mail'));
  });

  testWidgets('no model: an empty template, Accept waits for titles', (
    tester,
  ) async {
    final (h, _) = await _pump(tester, model: ThinkingAvailability.unavailable);
    await _open(tester);
    expect(find.text('on-device'), findsNothing);
    expect(_field('Step 1'), findsOneWidget);
    expect(find.text('Total 30 min · the dot grows to fit'), findsOneWidget);
    final accept = find.ancestor(
      of: find.text('Accept'),
      matching: find.byWidgetPredicate((w) => w is FilledButton),
    );
    expect(tester.widget<FilledButton>(accept).onPressed, isNull);
    for (final (i, t) in ['Open', 'Do', 'Close'].indexed) {
      await tester.enterText(_field('Step ${i + 1}'), t);
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(accept).onPressed, isNotNull);
    await _accept(tester);
    expect(h.writes.batches.single.subtasks, hasLength(3));
  });

  testWidgets('Add step 1: Accept hands the steps to the draft, no write', (
    tester,
  ) async {
    List<ProposedStep>? accepted;
    final (h, _) = await _pump(tester, draft: (s) => accepted = s);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () => _open(tester),
    );
    await _accept(tester);
    expect(accepted?.map((s) => s.title), [
      'Clear the inbox',
      'Reply to Sam',
      'Archive',
    ]);
    expect(h.writes.batches, isEmpty, reason: 'written with the task on Save');
    expect(find.byType(ProposalSheet), findsNothing);
  });

  testWidgets('Add step 1 on a wide screen: over the popover, not the panel', (
    tester,
  ) async {
    await _pump(tester, width: 1280, draft: (_) {});
    await _open(tester);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('the sheet meets the a11y guidelines', (tester) async {
    await _pump(tester);
    await _open(tester);
    await expectA11yGuidelines(tester);
  });

  test('the clock override keeps the harness deterministic', () {
    expect(clockProvider, isNotNull);
  });
}
