import 'package:dottoday/data/speech/channel_speech_transport.dart';
import 'package:dottoday/data/speech/web_speech_recognizer.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'speech_providers.g.dart';

/// The platform's on-device recognizer (ADR-0014): the method channel on
/// iOS, macOS and Android, the Web Speech API (on-device mode) in Chrome.
@Riverpod(keepAlive: true)
SpeechRecognizer speechRecognizer(Ref ref) =>
    kIsWeb ? const WebSpeechRecognizer() : const ChannelSpeechRecognizer();

/// Whether dictation runs for [localeTag] here; the mic shows only when
/// this is not [SpeechAvailability.unavailable] (D2). Re-read on resume:
/// the microphone may have been switched on in Settings.
@Riverpod(keepAlive: true)
Future<SpeechAvailability> speechAvailability(Ref ref, String localeTag) async {
  try {
    return await ref.watch(speechRecognizerProvider).availability(localeTag);
  } on Object {
    return SpeechAvailability.unavailable;
  }
}
