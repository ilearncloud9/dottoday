import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/speech/dictation_controller.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fake_speech.dart';

// The one dictation (docs/09 M14.5): events become field text for its
// owner; starting for another field stops the first; an error ends it
// with a typed failure; stopFor ignores fields that aren't listening.

void main() {
  late FakeSpeechRecognizer fake;
  late ProviderContainer c;
  setUp(() {
    fake = FakeSpeechRecognizer();
    c = ProviderContainer(
      overrides: [
        speechRecognizerProvider.overrideWithValue(fake),
        clockProvider.overrideWithValue(FakeClock(DateTime.utc(2026, 10, 29))),
      ],
    );
  });
  tearDown(() => c.dispose());

  DictationController ctl() => c.read(dictationControllerProvider.notifier);
  DictationState st() => c.read(dictationControllerProvider);

  Future<void> start(Object owner, {String text = ''}) => ctl().start(
    owner: owner,
    text: text,
    cursor: text.length,
    mode: DictationMode.plain,
    localeTag: 'en-US',
  );

  test('partials and finals become the owner field text', () async {
    await start('notes', text: 'Bring');
    expect(st().listeningFor('notes'), isTrue);
    expect(fake.starts, ['en-US']);
    fake.say('the forms');
    await pumpEventQueue();
    expect(st().dictation!.text, 'Bring the forms');
    fake.settle('the forms.');
    await pumpEventQueue();
    expect(st().dictation!.text, 'Bring the forms.');
    fake.end();
    await pumpEventQueue();
    expect(st().phase, DictationPhase.idle);
    expect(st().dictation!.text, 'Bring the forms.', reason: 'kept');
  });

  test('another field takes over: the first stops', () async {
    await start('a');
    await start('b');
    expect(fake.stops, greaterThanOrEqualTo(1));
    expect(st().listeningFor('b'), isTrue);
    await ctl().stopFor('a');
    expect(st().listeningFor('b'), isTrue, reason: 'not a');
  });

  test('an error ends the session with its failure', () async {
    await start('a');
    fake.end(const SpeechError(SpeechFailure(SpeechFailureKind.interrupted)));
    await pumpEventQueue();
    expect(st().phase, DictationPhase.idle);
    expect(st().failure, isA<SpeechFailure>());
  });

  // Timers run in testWidgets' fake time (no fake_async dependency).
  testWidgets('fetch: asks for the model, then says when it is ready', (
    tester,
  ) async {
    fake.state = SpeechAvailability.downloadable;
    unawaited(ctl().prepareLanguage('a', 'en-US'));
    await tester.pump();
    expect(fake.downloads, ['en-US']);
    expect(st().phase, DictationPhase.fetching);
    await tester.pump(const Duration(seconds: 5));
    expect(st().phase, DictationPhase.fetching, reason: 'still coming');
    fake.state = SpeechAvailability.available;
    await tester.pump(const Duration(seconds: 3));
    expect(st().phase, DictationPhase.idle);
    expect(st().ready, isTrue);
  });

  testWidgets('fetch: a declined download gives up quietly', (tester) async {
    fake.state = SpeechAvailability.downloadable;
    unawaited(ctl().prepareLanguage('a', 'en-US'));
    await tester.pump();
    fake.state = SpeechAvailability.downloadable;
    await tester.pump(const Duration(seconds: 10));
    expect(st().phase, DictationPhase.idle);
    expect(st().ready, isFalse);
    expect(st().failure, isNull);
  });

  test('preparing / notStarted for the permission flow', () async {
    ctl().preparing('a');
    expect(st().phase, DictationPhase.starting);
    ctl().notStarted(
      'a',
      failure: const PermissionFailure(AppPermission.microphone),
    );
    expect(st().phase, DictationPhase.idle);
    expect(st().failure, isA<PermissionFailure>());
  });
}
