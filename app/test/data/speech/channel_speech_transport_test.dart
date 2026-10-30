import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/speech/channel_speech_transport.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// `dottoday/speech` (docs/09 M14.4): availability words, start/stop over
// the method channel, events from the event channel mapped to typed
// events and failures; a platform with no handler reads as unavailable.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const methods = MethodChannel('dottoday/speech');
  const events = 'dottoday/speech/events';
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  tearDown(() {
    messenger.setMockMethodCallHandler(methods, null);
    messenger.setMockStreamHandler(const EventChannel(events), null);
    calls.clear();
  });

  void answer(Object? Function(MethodCall) reply) =>
      messenger.setMockMethodCallHandler(methods, (call) async {
        calls.add(call);
        return reply(call);
      });

  for (final (word, expected) in [
    ('available', SpeechAvailability.available),
    ('needs_permission', SpeechAvailability.needsPermission),
    ('denied', SpeechAvailability.denied),
    ('downloadable', SpeechAvailability.downloadable),
    ('downloading', SpeechAvailability.downloading),
    ('unavailable', SpeechAvailability.unavailable),
    ('maybe', SpeechAvailability.unavailable),
  ]) {
    test('availability "$word"', () async {
      answer((_) => word);
      expect(
        await const ChannelSpeechRecognizer().availability('en-US'),
        expected,
      );
      expect(calls.single.arguments, {'locale': 'en-US'});
    });
  }

  test('no handler: unavailable, so the mic hides (D2)', () async {
    expect(
      await const ChannelSpeechRecognizer().availability('en'),
      SpeechAvailability.unavailable,
    );
  });

  test('download asks Android and reads the answer', () async {
    answer((_) => 'downloading');
    expect(
      await const ChannelSpeechRecognizer().download('en-US'),
      SpeechAvailability.downloading,
    );
    expect(calls.single.method, 'download');
    expect(calls.single.arguments, {'locale': 'en-US'});
  });

  test('requestPermission asks and reads the answer', () async {
    answer((_) => 'available');
    expect(
      await const ChannelSpeechRecognizer().requestPermission('de'),
      SpeechAvailability.available,
    );
    expect(calls.single.method, 'requestPermission');
  });

  test('start: partials, a final, then stopped ends the stream', () async {
    answer((_) => null);
    messenger.setMockStreamHandler(
      const EventChannel(events),
      MockStreamHandler.inline(
        onListen: (_, sink) {
          sink
            ..success({'type': 'partial', 'text': 'call'})
            ..success({'type': 'partial', 'text': 'call the dentist'})
            ..success({'type': 'bogus'})
            ..success({'type': 'final', 'text': 'Call the dentist.'})
            ..success({'type': 'stopped'});
        },
      ),
    );
    final got = await const ChannelSpeechRecognizer().start('en').toList();
    expect(got.map((e) => e.runtimeType), [
      SpeechPartial,
      SpeechPartial,
      SpeechFinal,
      SpeechStopped,
    ]);
    expect((got[1] as SpeechPartial).text, 'call the dentist');
    expect(calls.first.method, 'start');
    expect(calls.first.arguments, {'locale': 'en'});
  });

  for (final (code, failure) in [
    ('permission', const PermissionFailure(AppPermission.microphone)),
    ('unavailable', const SpeechFailure(SpeechFailureKind.unavailable)),
    ('interrupted', const SpeechFailure(SpeechFailureKind.interrupted)),
    ('anything', const SpeechFailure(SpeechFailureKind.recognizer)),
  ]) {
    test('error "$code" → ${failure.code}', () async {
      answer((_) => null);
      messenger.setMockStreamHandler(
        const EventChannel(events),
        MockStreamHandler.inline(
          onListen: (_, sink) => sink.success({'type': 'error', 'code': code}),
        ),
      );
      final got = await const ChannelSpeechRecognizer().start('en').toList();
      expect((got.single as SpeechError).failure.code, failure.code);
    });
  }

  test('start refused by the platform: one error, the stream ends', () async {
    answer((call) {
      if (call.method == 'start') {
        throw PlatformException(code: 'permission');
      }
      return null;
    });
    messenger.setMockStreamHandler(
      const EventChannel(events),
      MockStreamHandler.inline(onListen: (_, _) {}),
    );
    final got = await const ChannelSpeechRecognizer().start('en').toList();
    expect((got.single as SpeechError).failure, isA<PermissionFailure>());
  });

  test('cancelling the stream stops the recognizer', () async {
    answer((_) => null);
    messenger.setMockStreamHandler(
      const EventChannel(events),
      MockStreamHandler.inline(onListen: (_, _) {}),
    );
    final sub = const ChannelSpeechRecognizer().start('en').listen((_) {});
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(calls.map((c) => c.method), ['start', 'stop']);
  });
}
