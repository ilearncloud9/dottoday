import 'package:dottoday/data/speech/mic_settings.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/brain_dump_harness.dart';
import '../../support/fake_speech.dart';

// End to end with a scripted recognizer (docs/09 M14.7): three things
// spoken — a pause, then "next" — become three lines, Plan it proposes
// them, Accept writes exactly three tasks in one batch, over the real
// database and write path. The recognizer is the only fake: on a device
// it would be the OS's, which CI can't drive (08 §6.1 E).

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('spoken → 3 lines → Plan it → Accept writes 3', (tester) async {
    final fake = FakeSpeechRecognizer();
    final h = await pumpBrainDump(
      tester,
      extra: [
        speechRecognizerProvider.overrideWithValue(fake),
        micNeedsRationaleProvider.overrideWithValue(false),
      ],
    );
    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> quiet(Duration d) async {
      h.base.clock.advance(d);
      await tester.pump(const Duration(milliseconds: 200));
    }

    await tester.tap(find.byTooltip('Dictate'));
    await settle();
    fake.say('email Sam');
    await tester.pump();
    await quiet(kDictationPause);
    fake.say('email Sam taxes 45 minutes next');
    await tester.pump();
    await quiet(kCommandSettle);
    fake.say('email Sam taxes 45 minutes next call the bank 4pm');
    await tester.pump();
    await tester.tap(find.byTooltip('Stop dictation'));
    await settle();
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(
      field.controller!.text,
      'Email Sam\nTaxes 45 minutes\nCall the bank 4pm',
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Plan it'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settleBrainDump(tester);
    expect(h.writes.batches, isEmpty, reason: 'nothing before Accept');
    final accept = find.text('Add to day');
    await tester.ensureVisible(accept);
    await tester.runAsync(() async {
      await tester.tap(accept);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settleBrainDump(tester);
    expect(h.writes.batches, hasLength(1));
    expect(h.writes.batches.single.occurrences.map((o) => o.title).toSet(), {
      'Email Sam',
      'Taxes',
      'Call the bank',
    });
    await unmountBrainDump(tester);
  });
}
