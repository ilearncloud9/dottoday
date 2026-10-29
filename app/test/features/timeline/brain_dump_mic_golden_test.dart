// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/fake_seen_tips.dart';
import '../../support/fake_speech.dart';
import '../../support/timeline_fakes.dart';

// Brain dump with the mic (docs/09 M14.5, derived — 11 §B7, 10 §3
// `MicButton`): idle (the mic in the box's bottom-end corner, the
// mic-aware hint), listening (the dot, words arriving, the caption) and
// the first-use tip. Light/dark × three widths, 1×/2×, 2.0 text, RTL.
// Reduced motion holds the listening dot still for the picture.

void main() {
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  final fake = FakeSpeechRecognizer();
  List<Override> overrides({required bool tipSeen}) => [
    ...timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: FakeOccurrenceRepository(
        demoDayRows(DateTime(2026, 10, 21)),
      ),
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
    speechRecognizerProvider.overrideWithValue(fake),
    seenTipsProvider.overrideWith(
      () => FakeSeenTips(tipSeen ? {Tip.dictationLines} : const {}),
    ),
    appDatabaseProvider.overrideWith((ref) {
      final db = AppDatabase(NativeDatabase.memory());
      ref.onDispose(db.close);
      return db;
    }),
    thinkingMemoryProvider.overrideWith(
      (ref) => LocalThinkingMemory(ref.watch(appDatabaseProvider)),
    ),
  ];
  Widget sheet() => Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BrainDumpBody(today: DateTime(2026, 10, 21)),
        ),
      ),
    ),
  );
  Future<void> listen(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Dictate'));
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
    fake.say('call the dentist buy milk');
    await tester.pump();
  }

  goldenMatrix(
    'brain_dump_mic_idle',
    height: 640,
    a11yVariants: true,
    overrides: overrides(tipSeen: true),
    build: (_) => sheet(),
  );
  goldenMatrix(
    'brain_dump_mic_listening',
    height: 640,
    a11yVariants: true,
    overrides: overrides(tipSeen: true),
    build: (_) => sheet(),
    act: listen,
  );
  goldenMatrix(
    'brain_dump_mic_tip',
    height: 760,
    a11yVariants: true,
    overrides: overrides(tipSeen: false),
    build: (_) => sheet(),
    act: listen,
  );
}
