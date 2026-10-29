import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:dottoday/features/timeline/editor/editor_notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/a11y.dart';
import '../../../support/fake_clock.dart';
import '../../../support/fake_speech.dart';
import '../../../support/test_app.dart';

// Notes dictation (docs/09 M14.6, D6): like the keyboard's mic — words go
// in at the cursor, no command words, no pause lines; the draft hears
// about them; focus moving away stops listening; no mic without
// on-device speech.

typedef _Harness = ({
  FakeSpeechRecognizer fake,
  FakeClock clock,
  List<String?> changes,
});

Future<_Harness> _pump(
  WidgetTester tester, {
  String? notes,
  SpeechAvailability state = SpeechAvailability.available,
  ThemeMode mode = ThemeMode.light,
}) async {
  final fake = FakeSpeechRecognizer(state: state);
  final clock = FakeClock(DateTime.utc(2026, 10, 29, 9));
  final changes = <String?>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        speechRecognizerProvider.overrideWithValue(fake),
        clockProvider.overrideWithValue(clock),
      ],
      child: testApp(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    EditorNotes(notes: notes, onChanged: changes.add),
                    const TextField(key: ValueKey('other')),
                  ],
                ),
              ),
            ),
          ),
        ),
        themeMode: mode,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (fake: fake, clock: clock, changes: changes);
}

TextEditingController _notes(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller!;

void main() {
  testWidgets('no on-device speech: no mic, the help as before', (
    tester,
  ) async {
    await _pump(tester, state: SpeechAvailability.unavailable);
    expect(find.byTooltip('Dictate'), findsNothing);
  });

  testWidgets('words go in at the cursor; the draft hears them', (
    tester,
  ) async {
    final h = await _pump(tester, notes: 'Bring the form');
    _notes(tester).selection = const TextSelection.collapsed(offset: 5);
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pump();
    h.fake.say('and sign');
    await tester.pump();
    expect(_notes(tester).text, 'Bring and sign the form');
    expect(_notes(tester).selection.baseOffset, 'Bring and sign'.length);
    expect(h.changes.last, 'Bring and sign the form');
  });

  testWidgets('no pause lines and no command words', (tester) async {
    final h = await _pump(tester);
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pump();
    h.fake.say('ask about the next step');
    await tester.pump();
    h.clock.advance(kDictationPause * 3);
    await tester.pump(const Duration(milliseconds: 500));
    expect(_notes(tester).text, 'ask about the next step');
    expect(find.textContaining('Pause, or say'), findsNothing);
  });

  testWidgets('focus moving away stops listening', (tester) async {
    final h = await _pump(tester);
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pump();
    expect(h.fake.listening, isTrue);
    await tester.tap(find.byKey(const ValueKey('other')));
    await tester.pump();
    expect(h.fake.listening, isFalse);
    expect(find.byTooltip('Dictate'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('a11y ${mode.name}, listening', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, mode: mode);
      await tester.tap(find.byTooltip('Dictate'));
      await tester.pump();
      await expectA11yGuidelines(tester);
      handle.dispose();
    });
  }
}
