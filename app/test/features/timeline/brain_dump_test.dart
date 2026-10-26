import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/proposal_harness.dart';
import '../../support/rebalance_fixtures.dart';
import '../../support/test_app.dart';
import '../../support/thinking_fakes.dart';

// Brain-dump to thread (docs/09 M12.5, 11 B4, derived — §B4) over a real
// database: a pasted list is one task per line (R-07), placed by rules when
// no model is on the device, shown as a proposal — nothing is written
// before Accept — and kept in the local history.

const _dump = 'Email Sam\nTaxes 45m\nCall the bank 4pm';

Future<ProposalHarness> _pump(
  WidgetTester tester, {
  ThinkingAvailability model = ThinkingAvailability.unavailable,
  bool sheet = false,
}) async {
  tester.view
    ..physicalSize = const Size(390, 1600)
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
      overrides: [
        ...h.overrides,
        minuteTickProvider.overrideWith((ref) => const Stream.empty()),
        thinkingTransportProvider.overrideWithValue(
          FakeThinkingTransport(
            state: model,
            answers: {
              ThinkingKind.planFromText:
                  '{"dots":[{"title":"Model task","durationMin":20}]}',
            },
          ),
        ),
      ],
      child: testApp(
        Scaffold(
          body: ProposalHost(
            child: sheet
                ? Builder(
                    builder: (context) => TextButton(
                      onPressed: () =>
                          showBrainDump(context, DateTime(2026, 10, 21)),
                      child: const Text('Open'),
                    ),
                  )
                : SingleChildScrollView(
                    child: BrainDumpBody(today: DateTime(2026, 10, 21)),
                  ),
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

Future<void> _planIt(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).first, text);
  await tester.pump();
  await tester.runAsync(() async {
    await tester.tap(find.text('Plan it'));
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await _settle(tester);
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('rules: one task per line, placed; nothing before Accept', (
    tester,
  ) async {
    final h = await _pump(tester);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await _planIt(tester, _dump);
        expect(find.text('3 tasks on Today, in the first free time'), findsOne);
        expect(find.text('Email Sam'), findsOneWidget);
        expect(find.text('Taxes'), findsOneWidget);
        expect(find.text('Call the bank'), findsOneWidget);
        expect(find.text('on-device'), findsNothing, reason: 'rules');
      },
      edit: () => tester.tap(find.byTooltip('Keep Email Sam as it is')),
      leave: () => tester.tap(find.text('Discard')),
    );
    await _unmount(tester);
  });

  testWidgets('Accept writes the lines left in one batch', (tester) async {
    final h = await _pump(tester);
    await _planIt(tester, _dump);
    final accept = find.text('Add to day');
    await tester.ensureVisible(accept);
    await tester.runAsync(() async {
      await tester.tap(accept);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await _settle(tester);
    final rows = h.writes.batches.last.occurrences;
    expect(rows.map((o) => o.title).toSet(), {
      'Email Sam',
      'Taxes',
      'Call the bank',
    });
    final bank = rows.singleWhere((o) => o.title == 'Call the bank');
    expect(bank.startUtc, DateTime.utc(2026, 10, 21, 20), reason: '4 PM EDT');
    expect(rows.singleWhere((o) => o.title == 'Taxes').durationMin, 45);
    await _unmount(tester);
  });

  testWidgets('from its sheet: the sheet closes, the proposal stays', (
    tester,
  ) async {
    final h = await _pump(tester, sheet: true);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await _planIt(tester, _dump);
    expect(find.byType(BrainDumpBody), findsNothing);
    expect(find.text('Add to day'), findsOneWidget);
    expect(h.writes.batches, isEmpty);
    await _unmount(tester);
  });

  testWidgets('the on-device model answers when it is there', (tester) async {
    await _pump(tester, model: ThinkingAvailability.available);
    await _planIt(tester, 'anything');
    expect(find.text('Model task'), findsOneWidget);
    expect(find.text('on-device'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('dumps are kept, searchable, and can be used again', (
    tester,
  ) async {
    final h = await _pump(tester);
    await _planIt(tester, _dump);
    await tester.tap(find.text('Discard'));
    await _settle(tester);
    final kept = (await tester.runAsync(
      () => LocalThinkingMemory(h.base.db, () async => []).dumps(),
    ))!;
    expect(kept.single.text, _dump, reason: 'kept even after Discard');
    // A new sheet shows the history (its read runs on the real database).
    await tester.runAsync(() => tester.pumpWidget(const SizedBox()));
    await tester.runAsync(
      () => tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...h.overrides,
            minuteTickProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: testApp(
            Scaffold(
              body: SingleChildScrollView(
                child: BrainDumpBody(
                  key: const ValueKey('again'),
                  today: DateTime(2026, 10, 21),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await _settle(tester);
    expect(find.text('EARLIER DUMPS'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'nothing like it');
    await tester.pump();
    expect(find.text('Use again'), findsNothing);
    await tester.enterText(find.byType(TextField).last, 'taxes');
    await tester.pump();
    await tester.tap(find.text('Use again'));
    await tester.pump();
    expect(find.text(_dump), findsOneWidget);
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
