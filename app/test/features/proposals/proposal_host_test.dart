import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/proposal_harness.dart';
import '../../support/sample_proposal.dart';
import '../../support/test_app.dart';

// B3 ProposalSheet (docs/09 M10.2, CLAUDE.md §11 proposal rule): nothing
// is written before Accept; Accept is one write-path batch with Undo;
// Discard, × and Esc write nothing; a sheet on phones, the right-hand
// panel at the expanded width.

final _now = DateTime.utc(2026, 10, 21, 15, 25);

class _Opener extends ConsumerWidget {
  const _Opener(this.proposal);

  final Proposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: TextButton(
      onPressed: () => ref
          .read(activeProposalProvider.notifier)
          .open(
            ProposalRequest(
              proposal: proposal,
              title: 'Running late',
              subtitle: 'Deep work ran over by 25 min',
              acceptLabel: 'Accept plan',
              acceptedMessage: 'Plan applied',
            ),
          ),
      child: const Text('Propose'),
    ),
  );
}

Future<ProposalHarness> _pump(
  WidgetTester tester, {
  double width = 390,
  int edits = 4,
}) async {
  tester.view
    ..physicalSize = Size(width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = ProposalHarness(_now);
  addTearDown(() => h.dispose(tester));
  await h.seed(
    tester,
    WriteBatch(
      userId: userId,
      profile: profileFixture(),
      occurrences: sampleDayRows(),
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: h.overrides,
      child: testApp(
        Scaffold(body: ProposalHost(child: _Opener(sampleProposal(edits)))),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return h;
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Propose'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phones: nothing is written before Accept', (tester) async {
    final h = await _pump(tester);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () => _open(tester),
      edit: () => tester.tap(find.byTooltip('Keep Reply to email as it is')),
      leave: () => tester.tap(find.text('Discard')),
    );
    // A bottom sheet, not the panel.
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('× in the header and a pinned line write nothing', (
    tester,
  ) async {
    final h = await _pump(tester);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await _open(tester);
        expect(find.byType(BottomSheet), findsOneWidget);
        // The pinned line has no ×.
        expect(find.byTooltip('Keep Lunch with Sam as it is'), findsNothing);
        expect(find.text('pinned · untouched'), findsOneWidget);
      },
      leave: () => tester.tap(find.byTooltip('Close')),
    );
  });

  testWidgets('Accept writes the remaining lines once, then Undo', (
    tester,
  ) async {
    final h = await _pump(tester);
    await _open(tester);
    await tester.tap(find.byTooltip('Keep Reply to email as it is'));
    await tester.pumpAndSettle();
    expect(find.text('shifted +25 min'), findsNothing);
    final accept = find.text('Accept plan');
    await tester.ensureVisible(accept);
    await tester.runAsync(() async {
      await tester.tap(accept);
      // A second tap while writing does nothing (one batch, one Undo).
      await tester.tap(accept, warnIfMissed: false);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(h.writes.batches, hasLength(1));
    final written = h.writes.batches.single.occurrences;
    expect(written.map((o) => o.title), ['Spanish lesson', 'Call the dentist']);
    expect(find.byType(ProposalSheet), findsNothing);
    expect(find.text('Plan applied'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.text('Undo'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    final db = h.base.db;
    final spanish = await tester.runAsync(
      () => (db.select(
        db.occurrences,
      )..where((o) => o.id.equals(sampleDayRows()[2].id))).getSingle(),
    );
    expect(spanish!.durationMin, 60, reason: 'Undo puts the row back');
  });

  testWidgets('a failed Accept keeps the sheet and says so', (tester) async {
    final h = await _pump(tester);
    await _open(tester);
    h.writes.failNext = true;
    final accept = find.text('Accept plan');
    await tester.ensureVisible(accept);
    await tester.runAsync(() async {
      await tester.tap(accept);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.byType(ProposalSheet), findsOneWidget);
    expect(find.textContaining("Couldn't save"), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text('Try again'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(find.byType(ProposalSheet), findsNothing);
    expect(h.writes.batches, hasLength(2));
  });

  testWidgets('every line removed: nothing to change, Accept off', (
    tester,
  ) async {
    await _pump(tester, edits: 1);
    await _open(tester);
    await tester.tap(find.byTooltip('Keep Reply to email as it is'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing to change'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Accept plan'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('expanded: the right-hand panel, Esc discards', (tester) async {
    final h = await _pump(tester, width: 1280);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await _open(tester);
        expect(find.byType(BottomSheet), findsNothing);
        expect(find.byType(Dialog), findsNothing);
        expect(find.text('Propose'), findsOneWidget, reason: 'content stays');
      },
      leave: () => tester.sendKeyEvent(LogicalKeyboardKey.escape),
    );
  });

  testWidgets('the sheet meets the a11y guidelines', (tester) async {
    await _pump(tester);
    await _open(tester);
    await expectA11yGuidelines(tester);
  });
}
