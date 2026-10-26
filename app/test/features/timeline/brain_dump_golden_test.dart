// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/thinking_fakes.dart';
import '../../support/timeline_fakes.dart';

// Brain dump (docs/09 M12.5, derived — 11 §B4): the sheet with a list
// typed, and its proposal on the demo day at 9:22 in Berlin — new lines in
// the free time, one with no room going to the Inbox.

const _dump = 'Email Sam\nTaxes 45m\nCall the bank 4pm\nPaint the hall 14h';

void main() {
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  final memory = LocalThinkingMemory(
    AppDatabase(NativeDatabase.memory()),
    () async => const [],
  );
  final overrides = [
    ...timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: FakeOccurrenceRepository(
        demoDayRows(DateTime(2026, 10, 21)),
      ),
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
    thinkingTransportProvider.overrideWithValue(
      FakeThinkingTransport(state: ThinkingAvailability.unavailable),
    ),
    thinkingMemoryProvider.overrideWithValue(memory),
  ];
  Widget sheet() => Scaffold(
    body: ProposalHost(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BrainDumpBody(today: DateTime(2026, 10, 21)),
      ),
    ),
  );
  Future<void> type(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, _dump);
    await tester.pump();
  }

  goldenMatrix(
    'brain_dump',
    height: 700,
    widths: const {'compact', 'expanded'},
    overrides: overrides,
    build: (_) => sheet(),
    act: type,
  );
  goldenMatrix(
    'brain_dump_proposal',
    height: 1300,
    widths: const {'compact', 'expanded'},
    overrides: overrides,
    build: (_) => sheet(),
    act: (tester) async {
      await type(tester);
      await tester.runAsync(() async {
        await tester.tap(find.text('Plan it'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
    },
  );
}
