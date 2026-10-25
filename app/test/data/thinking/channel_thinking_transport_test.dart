import 'package:dottoday/data/thinking/channel_thinking_transport.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Availability detection per platform (docs/09 M10.1): the words Swift
// (Foundation Models) and Kotlin (ML Kit GenAI FeatureStatus) send, and a
// platform with no handler (Windows/Linux, tests) reads as unavailable.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dottoday/thinking');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  final cases = {
    // iOS/macOS: SystemLanguageModel.availability.
    'Apple available': ('available', ThinkingAvailability.available),
    'Apple model not ready': (
      'downloadable',
      ThinkingAvailability.downloadable,
    ),
    'Apple not eligible / off': (
      'unavailable',
      ThinkingAvailability.unavailable,
    ),
    // Android: FeatureStatus AVAILABLE / DOWNLOADABLE / DOWNLOADING / UNAVAILABLE.
    'Android downloading': ('downloading', ThinkingAvailability.downloadable),
    'unknown word': ('maybe', ThinkingAvailability.unavailable),
  };
  for (final MapEntry(key: name, value: (word, expected)) in cases.entries) {
    test(name, () async {
      messenger.setMockMethodCallHandler(channel, (call) async => word);
      expect(await const ChannelThinkingTransport().availability(), expected);
    });
  }

  test('no handler: unavailable', () async {
    expect(
      await const ChannelThinkingTransport().availability(),
      ThinkingAvailability.unavailable,
    );
  });

  test('generate sends the wire prompt and returns the text', () async {
    MethodCall? sent;
    messenger.setMockMethodCallHandler(channel, (call) async {
      sent = call;
      return '{"minutes":30}';
    });
    final answer = await const ChannelThinkingTransport().generate(
      ThinkingPrompts.suggestDuration(
        const DurationRequest(title: 'Gym', language: 'fr'),
      ),
    );
    expect(answer, '{"minutes":30}');
    expect(sent!.method, 'generate');
    final args = sent!.arguments as Map<Object?, Object?>;
    expect(args['kind'], 'suggest_duration');
    expect(args['language'], 'fr');
    expect(args['schema'], isA<String>());
  });
}
