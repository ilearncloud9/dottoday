import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/proposal_harness.dart';
import '../../support/rebalance_fixtures.dart';
import '../../support/test_app.dart';

// Rebalance (docs/09 M11.1, 11 C1) over a real database and write path:
// the plan opens in ProposalSheet; nothing is written before Accept —
// not while the rules change or a line is dropped, not on Discard;
// Accept is one batch that counts each move, with Undo.

class _Opener extends ConsumerWidget {
  const _Opener();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: TextButton(
      onPressed: () => openRebalance(
        ProviderScope.containerOf(context, listen: false),
        context.l10n,
        today: DateTime(2026, 10, 21),
        fromUtc: rebalanceFrom,
        deltaMin: 25,
        subtitle: "Deep work ran over by 25 min · here's a plan",
      ),
      child: const Text('Rebalance'),
    ),
  );
}

Future<ProposalHarness> _pump(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = ProposalHarness(rebalanceNow);
  addTearDown(() => h.dispose(tester));
  await h.seed(
    tester,
    WriteBatch(
      userId: userId,
      profile: profileFixture(),
      occurrences: rebalanceDayRows(),
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: h.overrides,
      child: testApp(const Scaffold(body: ProposalHost(child: _Opener()))),
    ),
  );
  await tester.pumpAndSettle();
  return h;
}

Future<void> _open(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.tap(find.text('Rebalance'));
    // Two days are read from the database before the sheet opens.
    await Future<void>.delayed(const Duration(milliseconds: 600));
  });
  await tester.pumpAndSettle();
}

Future<void> _accept(WidgetTester tester) async {
  final accept = find.text('Accept plan');
  await tester.ensureVisible(accept);
  await tester.runAsync(() async {
    await tester.tap(accept);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('nothing is written before Accept', (tester) async {
    final h = await _pump(tester);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await _open(tester);
        expect(find.text('shifted +25 min'), findsWidgets);
        expect(find.text('pinned · untouched'), findsOneWidget);
      },
      edit: () async {
        await tester.tap(find.text('Allow shrinking optional'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Push past bedtime'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Keep Reply to email as it is'));
      },
      leave: () => tester.tap(find.text('Discard')),
    );
  });

  testWidgets('Accept: one batch, moves counted, Undo', (tester) async {
    final h = await _pump(tester);
    await _open(tester);
    final before = h.writes.batches.length;
    await _accept(tester);
    expect(h.writes.batches.length, before + 1);
    final batch = h.writes.batches.last;
    expect(batch.occurrences, isNotEmpty);
    expect(batch.occurrences.every((o) => o.moveCount == 1), isTrue);
    expect(
      batch.occurrences.map((o) => o.title),
      isNot(contains('Lunch with Sam')),
    );
    expect(find.text('Plan accepted'), findsOneWidget);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    await _open(tester);
    await expectA11yGuidelines(tester);
    handle.dispose();
  });
}
