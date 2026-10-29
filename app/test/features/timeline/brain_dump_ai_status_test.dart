import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/brain_dump_harness.dart';
import '../../support/proposal_harness.dart';

// AI status in Brain dump (docs/09 M14.2, D4): the caption under Plan it
// names the path before the tap; a plan from the rules says "simple
// rules", and only where turning the model on would help, one dismissible
// hint — never for a device that can't run it, never after "Don't show
// again". Nothing is written before Accept with the hint showing.

const _dump = 'Email Sam\nTaxes 45m';
const _hint =
    'Made with simple rules · Turn on Apple Intelligence for smarter plans';

Future<ProposalHarness> _off(WidgetTester tester) => pumpBrainDump(
  tester,
  model: ThinkingAvailability.notEnabled,
  vendor: ThinkingVendor.appleIos,
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the caption names the rules when no model is ready', (
    tester,
  ) async {
    await pumpBrainDump(tester);
    expect(find.text('Plans with simple rules'), findsOneWidget);
    await unmountBrainDump(tester);
  });

  testWidgets('the caption names Apple Intelligence when it is ready', (
    tester,
  ) async {
    await pumpBrainDump(
      tester,
      model: ThinkingAvailability.available,
      vendor: ThinkingVendor.appleIos,
    );
    expect(
      find.text('Plans with Apple Intelligence on this device'),
      findsOneWidget,
    );
    await unmountBrainDump(tester);
  });

  testWidgets('Apple Intelligence off: the hint; nothing before Accept', (
    tester,
  ) async {
    final h = await _off(tester);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await planBrainDumpText(tester, _dump);
        expect(find.text('simple rules'), findsOneWidget);
        expect(find.bySemanticsLabel(_hint), findsOneWidget);
      },
      edit: () => tester.tap(find.byTooltip('Keep Email Sam as it is')),
      leave: () => tester.tap(find.text('Discard')),
    );
    await unmountBrainDump(tester);
  });

  testWidgets("Don't show again: gone now and next time, kept on device", (
    tester,
  ) async {
    final h = await _off(tester);
    await planBrainDumpText(tester, _dump);
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip("Don't show again"));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settleBrainDump(tester);
    expect(find.bySemanticsLabel(_hint), findsNothing);
    expect(find.text('simple rules'), findsOneWidget, reason: 'label stays');
    final rows = await tester.runAsync(
      () => h.base.db.select(h.base.db.localMeta).get(),
    );
    expect(rows!.map((r) => r.key), contains(Tip.thinkingHint.key));
    await tester.tap(find.text('Discard'));
    await settleBrainDump(tester);
    await planBrainDumpText(tester, _dump);
    expect(find.bySemanticsLabel(_hint), findsNothing);
    expect(h.writes.batches, isEmpty);
    await unmountBrainDump(tester);
  });

  for (final state in [
    ThinkingAvailability.notEligible,
    ThinkingAvailability.unknown,
  ]) {
    testWidgets('no hint when ${state.name}', (tester) async {
      await pumpBrainDump(
        tester,
        model: state,
        vendor: ThinkingVendor.appleIos,
      );
      await planBrainDumpText(tester, _dump);
      expect(find.text('simple rules'), findsOneWidget);
      expect(find.textContaining('Made with simple rules'), findsNothing);
      await unmountBrainDump(tester);
    });
  }

  testWidgets('the proposal with the hint meets a11y guidelines (R-12)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _off(tester);
    await planBrainDumpText(tester, _dump);
    await expectA11yGuidelines(tester);
    handle.dispose();
    await unmountBrainDump(tester);
  });
}
