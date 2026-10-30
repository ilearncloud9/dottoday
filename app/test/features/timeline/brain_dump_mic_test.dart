import 'package:dottoday/data/speech/mic_settings.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/brain_dump_harness.dart';
import '../../support/fake_speech.dart';
import '../../support/proposal_harness.dart';

// Brain dump's mic (docs/09 M14.5, D6, ADR-0014) with a scripted
// recognizer: hidden without on-device speech, guesses appear live, a
// pause or "next" starts a line, Plan it stops listening first and still
// writes nothing before Accept, a refused microphone is a quiet line.

const _caption = 'Pause, or say "next", to start a new task.';

Future<(ProposalHarness, FakeSpeechRecognizer, List<int>)> _pump(
  WidgetTester tester, {
  SpeechAvailability state = SpeechAvailability.available,
  SpeechAvailability afterAsking = SpeechAvailability.available,
  bool rationale = false,
}) async {
  final fake = FakeSpeechRecognizer(state: state, afterAsking: afterAsking);
  final opened = <int>[];
  final h = await pumpBrainDump(
    tester,
    extra: [
      speechRecognizerProvider.overrideWithValue(fake),
      micNeedsRationaleProvider.overrideWithValue(rationale),
      micSettingsOpenerProvider.overrideWithValue(() async {
        opened.add(1);
        return true;
      }),
    ],
  );
  return (h, fake, opened);
}

String _text(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller!.text;

/// Lets the database and the flow land; never `pumpAndSettle`, which
/// waits forever on the breathing dot.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _listen(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Dictate'));
  await _settle(tester);
}

/// Time passes with nothing heard: the clock and the ticker.
Future<void> _quiet(WidgetTester tester, ProposalHarness h, Duration d) async {
  h.base.clock.advance(d);
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('no on-device speech: no mic, the plain hint', (tester) async {
    await _pump(tester, state: SpeechAvailability.unavailable);
    expect(find.byTooltip('Dictate'), findsNothing);
    expect(find.text('Everything on your mind, one thing per line'), findsOne);
    await unmountBrainDump(tester);
  });

  testWidgets('a pause starts a new line; words never repeat', (tester) async {
    final (h, fake, _) = await _pump(tester);
    expect(find.text('Type or tap the mic. One thing per line.'), findsOne);
    await _listen(tester);
    expect(fake.starts, hasLength(1));
    expect(find.text(_caption), findsOneWidget);
    expect(find.text('Speak your list'), findsOneWidget, reason: 'first use');
    fake.say('call the dentist');
    await tester.pump();
    expect(_text(tester), 'Call the dentist');
    await _quiet(tester, h, kDictationPause);
    expect(_text(tester), 'Call the dentist\n');
    fake.say('call the dentist buy milk');
    await tester.pump();
    expect(_text(tester), 'Call the dentist\nBuy milk');
    await tester.tap(find.byTooltip('Stop dictation'));
    await _settle(tester);
    expect(find.text(_caption), findsNothing);
    expect(_text(tester), 'Call the dentist\nBuy milk', reason: 'kept');
    await unmountBrainDump(tester);
  });

  // Found on devices (2026-10-30): iOS starts its transcript over after a
  // pause; the words after a line break must still land at once.
  testWidgets('a recognizer that starts over keeps landing lines', (
    tester,
  ) async {
    final (h, fake, _) = await _pump(tester);
    await _listen(tester);
    fake.say('call the dentist');
    await tester.pump();
    await _quiet(tester, h, kDictationPause);
    fake.say('buy');
    await tester.pump();
    expect(_text(tester), 'Call the dentist\nBuy');
    fake.say('buy milk next');
    await tester.pump();
    await _quiet(tester, h, kCommandSettle);
    fake.say('gym');
    await tester.pump();
    expect(_text(tester), 'Call the dentist\nBuy milk\nGym');
    await unmountBrainDump(tester);
  });

  testWidgets('"next" starts a new line and is dropped', (tester) async {
    final (h, fake, _) = await _pump(tester);
    await _listen(tester);
    fake.say('email Sam next');
    await tester.pump();
    await _quiet(tester, h, kCommandSettle);
    expect(_text(tester), 'Email Sam\n');
    fake.say('email Sam next see you next week');
    await tester.pump();
    await _quiet(tester, h, kCommandSettle);
    expect(_text(tester), 'Email Sam\nSee you next week');
    await unmountBrainDump(tester);
  });

  testWidgets('Plan it while listening stops first; nothing before Accept', (
    tester,
  ) async {
    final (h, fake, _) = await _pump(tester);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await _listen(tester);
        fake.say('email Sam');
        await tester.pump();
        await _quiet(tester, h, kDictationPause);
        fake.say('email Sam taxes 45m');
        await tester.pump();
        await tester.runAsync(() async {
          await tester.tap(find.text('Plan it'));
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await _settle(tester);
        expect(fake.listening, isFalse);
        expect(find.text('Email Sam'), findsOneWidget);
        expect(find.text('Taxes'), findsOneWidget);
      },
      leave: () => tester.tap(find.text('Discard')),
    );
    await unmountBrainDump(tester);
  });

  testWidgets('typing while listening stops it', (tester) async {
    final (_, fake, _) = await _pump(tester);
    await _listen(tester);
    await tester.enterText(find.byType(TextField).first, 'Typed');
    await _settle(tester);
    expect(fake.listening, isFalse);
    expect(_text(tester), 'Typed');
    await unmountBrainDump(tester);
  });

  testWidgets('the tip shows once, then never again', (tester) async {
    final (_, fake, _) = await _pump(tester);
    await _listen(tester);
    expect(find.text('Speak your list'), findsOneWidget);
    await tester.tap(find.byTooltip("Don't show again"));
    await tester.pump();
    expect(find.text('Speak your list'), findsNothing);
    await tester.tap(find.byTooltip('Stop dictation'));
    await _settle(tester);
    await _listen(tester);
    expect(fake.starts, hasLength(2));
    expect(find.text('Speak your list'), findsNothing);
    await unmountBrainDump(tester);
  });

  // Owner, 2026-10-30: where Android can recognize the language on the
  // device but hasn't its model, the mic shows; the first tap fetches it.
  testWidgets('language not downloaded: the mic fetches it, then listens', (
    tester,
  ) async {
    final (_, fake, _) = await _pump(
      tester,
      state: SpeechAvailability.downloadable,
    );
    expect(find.byTooltip('Dictate'), findsOneWidget);
    await _listen(tester);
    expect(fake.downloads, hasLength(1));
    expect(fake.starts, isEmpty);
    expect(find.text('Getting speech ready on this device…'), findsOneWidget);
    fake.state = SpeechAvailability.available;
    await tester.pump(const Duration(seconds: 3));
    expect(
      find.text('Speech is ready on this device. Tap the mic to start.'),
      findsOneWidget,
    );
    await _listen(tester);
    expect(fake.starts, hasLength(1));
    expect(find.text(_caption), findsOneWidget);
    await unmountBrainDump(tester);
  });

  testWidgets('microphone refused: a quiet line and Open settings', (
    tester,
  ) async {
    final (_, fake, opened) = await _pump(
      tester,
      state: SpeechAvailability.denied,
    );
    await _listen(tester);
    expect(fake.starts, isEmpty);
    expect(find.text('Microphone is off for Dottoday'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    expect(opened, [1]);
    await unmountBrainDump(tester);
  });

  testWidgets('Android: our words first, then the system asks', (tester) async {
    final (_, fake, _) = await _pump(
      tester,
      state: SpeechAvailability.needsPermission,
      rationale: true,
    );
    await tester.tap(find.byTooltip('Dictate'));
    await _settle(tester);
    expect(find.text('Use the microphone?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await _settle(tester);
    expect(fake.asked, 1);
    expect(fake.starts, hasLength(1));
    await unmountBrainDump(tester);
  });

  testWidgets('semantics: a toggle button; a11y guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    expect(
      tester.getSemantics(find.byTooltip('Dictate').first),
      isSemantics(label: 'Dictate', isButton: true, hasToggledState: true),
    );
    await _listen(tester);
    expect(
      tester.getSemantics(find.byTooltip('Stop dictation').first),
      isSemantics(label: 'Stop dictation', isButton: true, isToggled: true),
    );
    await expectA11yGuidelines(tester);
    handle.dispose();
    await unmountBrainDump(tester);
  });
}
