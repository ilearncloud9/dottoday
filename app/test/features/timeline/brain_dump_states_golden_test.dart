// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_plan_section.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/fake_seen_tips.dart';
import '../../support/fake_speech.dart';
import '../../support/timeline_fakes.dart';

// Brain dump's other states (E-Phones-2, E-R2-37): earlier dumps on
// their card; dictation stopped by something else ("Dictation stopped.
// Tap the mic to go on.", the lines stay); the microphone refused
// ("Microphone is off for Dottoday" with Open settings, quiet); and the
// Mac and web Plan panel block with Dictate leading its row.

final _today = DateTime(2026, 10, 21);

/// Brain dump once two earlier dumps are kept on this device.
class _Seeded extends ConsumerStatefulWidget {
  const _Seeded();

  @override
  ConsumerState<_Seeded> createState() => _SeededState();
}

class _SeededState extends ConsumerState<_Seeded> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_seed());
  }

  Future<void> _seed() async {
    final memory = ref.read(thinkingMemoryProvider);
    await memory.rememberDump(
      BrainDump(
        // l10n-ignore: test data
        text:
            'Pack for trip, passport\nCharger\nBooks\nSnacks\nTickets\nKeys\nMap',
        atUtc: DateTime.utc(2026, 10, 16, 9),
      ),
    );
    await memory.rememberDump(
      BrainDump(
        // l10n-ignore: test data
        text: 'Groceries, dentist, call Mum\nBook flights\nTaxes\nGym\nRead',
        atUtc: DateTime.utc(2026, 10, 19, 9),
      ),
    );
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) =>
      _ready ? BrainDumpBody(today: _today) : const SizedBox.shrink();
}

/// Asks every time and is always refused, so each variant sees the ask.
final class _Refusing implements SpeechRecognizer {
  @override
  Future<SpeechAvailability> availability(String localeTag) async =>
      SpeechAvailability.needsPermission;

  @override
  Future<SpeechAvailability> requestPermission(String localeTag) async =>
      SpeechAvailability.denied;

  @override
  Stream<SpeechEvent> start(String localeTag) => const Stream.empty();

  @override
  Future<void> stop() async {}
}

void main() {
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  List<Override> overrides(SpeechRecognizer speech) => [
    ...timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: FakeOccurrenceRepository(demoDayRows(_today)),
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
    speechRecognizerProvider.overrideWithValue(speech),
    seenTipsProvider.overrideWith(() => FakeSeenTips({Tip.dictationLines})),
    appDatabaseProvider.overrideWith((ref) {
      final db = AppDatabase(NativeDatabase.memory());
      ref.onDispose(db.close);
      return db;
    }),
    thinkingMemoryProvider.overrideWith(
      (ref) => LocalThinkingMemory(ref.watch(appDatabaseProvider)),
    ),
  ];
  Widget frame(Widget child) => Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  Future<void> tapMic(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Dictate'));
    await settle(tester);
  }

  final stopped = FakeSpeechRecognizer();
  goldenMatrix(
    'brain_dump_earlier',
    height: 760,
    widths: const {'compact'},
    overrides: overrides(FakeSpeechRecognizer()),
    build: (_) => frame(const _Seeded()),
    act: settle,
  );
  goldenMatrix(
    'brain_dump_mic_stopped',
    height: 640,
    widths: const {'compact'},
    overrides: overrides(stopped),
    build: (_) => frame(BrainDumpBody(today: _today)),
    act: (tester) async {
      await tapMic(tester);
      stopped.say('email sam taxes');
      await tester.pump();
      stopped.end(
        const SpeechError(SpeechFailure(SpeechFailureKind.interrupted)),
      );
      await settle(tester);
    },
  );
  goldenMatrix(
    'brain_dump_mic_refused',
    height: 640,
    widths: const {'compact'},
    overrides: overrides(_Refusing()),
    build: (_) => frame(BrainDumpBody(today: _today)),
    act: (tester) async {
      await tapMic(tester);
      // Dottoday's reason first, then the system's question says no.
      await tester.tap(find.text('Continue'));
      await settle(tester);
    },
  );
  goldenMatrix(
    'plan_panel_dump_mic',
    height: 360,
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
    overrides: overrides(FakeSpeechRecognizer()),
    build: (_) =>
        frame(SizedBox(width: 240, child: BrainDumpPlanSection(today: _today))),
  );
}
