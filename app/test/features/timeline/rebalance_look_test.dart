import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:dottoday/shared/proposals/proposed_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/proposal_harness.dart';
import '../../support/rebalance_fixtures.dart';
import '../../support/test_app.dart';

// Rebalance as E-R2-35 draws it (ED-341): each line with the day's faded
// ring beside the proposed dot; a centred panel at the expanded width
// that Esc discards; Minimal's before and after only (docs/14 §3 C1):
// no tags, no × and no rules, and still nothing written before Accept.

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
      child: const Text('Rebalance'), // l10n-ignore: test trigger
    ),
  );
}

Future<ProposalHarness> _pump(
  WidgetTester tester, {
  Size size = const Size(390, 1400),
  UiLayout layout = UiLayout.full,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final base = profileFixture();
  final profile = base.copyWith(
    settings: base.settings.copyWith(uiLayout: layout),
  );
  final h = ProposalHarness(rebalanceNow, profile: profile);
  addTearDown(() => h.dispose(tester));
  await h.seed(
    tester,
    WriteBatch(
      userId: userId,
      profile: profile,
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
    await Future<void>.delayed(const Duration(milliseconds: 600));
  });
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('each line shows the day now beside the plan', (tester) async {
    await _pump(tester);
    await _open(tester);
    expect(
      find.byType(NowRing),
      findsNWidgets(find.byType(ProposedDot).evaluate().length),
    );
  });

  testWidgets('wide: a centred panel that Esc discards, unwritten', (
    tester,
  ) async {
    final h = await _pump(tester, size: const Size(1280, 900));
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await _open(tester);
        expect(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.byType(ProposalSheet),
          ),
          findsOneWidget,
        );
      },
      leave: () async {
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
      },
    );
    expect(find.byType(ProposalSheet), findsNothing);
  });

  testWidgets('Minimal: before and after only, unwritten until Accept', (
    tester,
  ) async {
    final h = await _pump(tester, layout: UiLayout.minimal);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await _open(tester);
        expect(find.text('Reply to email'), findsOneWidget);
        expect(find.text('shifted +25 min'), findsNothing);
        expect(find.text('pinned · untouched'), findsNothing);
        expect(find.text('Shift followers'), findsNothing);
        expect(find.byTooltip('Keep Reply to email as it is'), findsNothing);
        expect(find.text('Accept plan'), findsOneWidget);
      },
      leave: () => tester.tap(find.text('Discard')),
    );
  });
}
