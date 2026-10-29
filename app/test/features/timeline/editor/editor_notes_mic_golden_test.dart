@Tags(['golden'])
library;

import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/features/timeline/editor/editor_notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../../support/dot_golden.dart';
import '../../../support/fake_speech.dart';

// The editor's NOTES with the mic (docs/09 M14.6, derived — 11 §B7, 10 §3
// `MicButton`): idle (all cells incl. 2.0 text and RTL) and listening.
// Reduced motion holds the listening dot still.

void main() {
  setUpAll(loadAppFonts);
  final fake = FakeSpeechRecognizer();
  Widget notes() => Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: EditorNotes(
            notes: 'Bring the signed form.',
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  final overrides = [speechRecognizerProvider.overrideWithValue(fake)];
  goldenMatrix(
    'editor_notes_mic_idle',
    height: 320,
    a11yVariants: true,
    overrides: overrides,
    build: (_) => notes(),
  );
  goldenMatrix(
    'editor_notes_mic_listening',
    height: 320,
    overrides: overrides,
    build: (_) => notes(),
    act: (tester) async {
      await tester.tap(find.byTooltip('Dictate'));
      await tester.pump();
      fake.say('and the receipt');
      await tester.pump();
    },
  );
}
