import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../domain/fixtures.dart';
import 'proposal_harness.dart';
import 'rebalance_fixtures.dart';
import 'test_app.dart';
import 'thinking_fakes.dart';

/// Brain dump over a real database ([ProposalHarness]), its body inline
/// or behind an Open button ([sheet]); [model] and [vendor] set the
/// thinking status (docs/09 M12.5, M14.2).
Future<ProposalHarness> pumpBrainDump(
  WidgetTester tester, {
  ThinkingAvailability model = ThinkingAvailability.notEligible,
  ThinkingVendor vendor = ThinkingVendor.none,
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
        thinkingVendorProvider.overrideWithValue(vendor),
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
  await settleBrainDump(tester);
  return h;
}

/// Lets the real database's reads land.
Future<void> settleBrainDump(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> unmountBrainDump(WidgetTester tester) => tester.runAsync(() async {
  await tester.pumpWidget(const SizedBox());
  await Future<void>.delayed(const Duration(milliseconds: 50));
});

/// Types [text] and taps Plan it.
Future<void> planBrainDumpText(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).first, text);
  await tester.pump();
  await tester.runAsync(() async {
    await tester.tap(find.text('Plan it'));
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await settleBrainDump(tester);
}
