import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/proposal_harness.dart';
import '../../support/rebalance_fixtures.dart';
import '../../support/test_app.dart';

// Low-energy mode (docs/09 M12.2, 11 D2, `B-ios-low-energy`) over a real
// database: the next dot, the Later pile, no counts, the proposal that
// moves optional tasks to tomorrow (nothing written before Accept, offered
// once), and Not today.

final _wake = DateTime.utc(2026, 10, 22, 11); // 07:00 in New York

Future<ProposalHarness> _pump(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(390, 1600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final profile = profileFixture().copyWith(
    settings: Settings(use24h: false, lowEnergyUntil: _wake),
  );
  final h = ProposalHarness(rebalanceNow, profile: profile);
  addTearDown(() => h.dispose(tester));
  await h.seed(
    tester,
    WriteBatch(
      userId: userId,
      profile: profile,
      occurrences: [
        for (final o in rebalanceDayRows())
          o.title == 'Gym' ? o.copyWith(energy: Energy.high) : o,
      ],
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...h.overrides,
        minuteTickProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: testApp(
        Scaffold(
          body: ProposalHost(
            child: LowEnergyView(today: DateTime(2026, 10, 21)),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
  return h;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> _unmount(WidgetTester tester) => tester.runAsync(() async {
  await tester.pumpWidget(const SizedBox());
  await Future<void>.delayed(const Duration(milliseconds: 50));
});

Future<Map<String, int?>> _starts(
  WidgetTester tester,
  ProposalHarness h,
) async {
  final rows = (await tester.runAsync(
    () => h.base.db.select(h.base.db.occurrences).get(),
  ))!;
  return {for (final r in rows) r.title: r.startUtc};
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the next dot, the later pile and no counts', (tester) async {
    await _pump(tester);
    expect(find.text('Reply to email'), findsOneWidget);
    expect(find.text('until 11:30 AM · 5 min left'), findsOneWidget);
    expect(find.text('LATER · 6'), findsOneWidget);
    expect(find.text('Nudges are off until tomorrow\'s Wake Up'), findsOne);
    expect(find.textContaining(' of '), findsNothing, reason: 'no counts');
    await tester.tap(find.byTooltip("Show what's later"));
    await tester.pumpAndSettle();
    expect(find.text('Spanish lesson'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('Propose: nothing is written before Accept; offered once', (
    tester,
  ) async {
    final h = await _pump(tester);
    final before = await _starts(tester, h);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await tester.tap(find.text('Propose'));
        await _settle(tester);
        expect(find.text('Tomorrow'), findsOneWidget);
      },
      edit: () => tester.tap(find.byTooltip('Keep Read as it is')),
      leave: () => tester.tap(find.text('Discard')),
    );
    expect(await _starts(tester, h), before);
    expect(find.text('Move everything optional to tomorrow?'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('Accept moves the optional ones; pins and high energy stay', (
    tester,
  ) async {
    final h = await _pump(tester);
    await tester.tap(find.text('Propose'));
    await _settle(tester);
    final accept = find.text('Move them');
    await tester.ensureVisible(accept);
    await tester.runAsync(() async {
      await tester.tap(accept);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await _settle(tester);
    final moved = h.writes.batches.last.occurrences.map((o) => o.title);
    expect(moved, ['Spanish lesson', 'Call the dentist', 'Groceries', 'Read']);
    for (final o in h.writes.batches.last.occurrences) {
      expect(
        o.startUtc!.isAfter(_wake.subtract(const Duration(seconds: 1))),
        isTrue,
      );
    }
    await _unmount(tester);
  });

  testWidgets('Not today moves the next dot to tomorrow, with Undo', (
    tester,
  ) async {
    final h = await _pump(tester);
    final before = (await _starts(tester, h))['Reply to email']!;
    await tester.runAsync(() async {
      await tester.tap(find.text('Not today'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await _settle(tester);
    final after = (await _starts(tester, h))['Reply to email']!;
    expect(after - before, const Duration(days: 1).inMilliseconds);
    expect(find.text('Undo'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    await expectA11yGuidelines(tester);
    handle.dispose();
    await _unmount(tester);
  });
}
