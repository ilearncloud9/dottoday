import 'package:dottoday/domain/speech/speech_recognizer.dart';

/// Off the web there is no Web Speech API: never available.
final class WebSpeechRecognizer implements SpeechRecognizer {
  const WebSpeechRecognizer();

  @override
  Future<SpeechAvailability> availability(String localeTag) async =>
      SpeechAvailability.unavailable;

  @override
  Future<SpeechAvailability> requestPermission(String localeTag) async =>
      SpeechAvailability.unavailable;

  @override
  Stream<SpeechEvent> start(String localeTag) => const Stream.empty();

  @override
  Future<void> stop() async {}
}
