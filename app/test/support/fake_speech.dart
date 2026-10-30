import 'dart:async';

import 'package:dottoday/domain/speech/speech_recognizer.dart';

/// A scripted on-device recognizer (docs/09 M14.4–M14.6): [availability]
/// as set, [requestPermission] answering [afterAsking], and [say] / [end]
/// pushing events into the running session.
final class FakeSpeechRecognizer implements SpeechRecognizer {
  FakeSpeechRecognizer({
    this.state = SpeechAvailability.available,
    this.afterAsking = SpeechAvailability.available,
  });

  SpeechAvailability state;
  final SpeechAvailability afterAsking;
  final starts = <String>[];
  final downloads = <String>[];
  int stops = 0;
  int asked = 0;
  StreamController<SpeechEvent>? _session;

  bool _cancelled = false;

  /// A session is running: started, not ended, not cancelled.
  bool get listening => _session != null && !_session!.isClosed && !_cancelled;

  @override
  Future<SpeechAvailability> availability(String localeTag) async => state;

  @override
  Future<SpeechAvailability> requestPermission(String localeTag) async {
    asked++;
    return state = afterAsking;
  }

  /// Android fetching the language's model: [state] moves to
  /// [SpeechAvailability.downloading]; a test sets it on from there.
  @override
  Future<SpeechAvailability> download(String localeTag) async {
    downloads.add(localeTag);
    return state = SpeechAvailability.downloading;
  }

  @override
  Stream<SpeechEvent> start(String localeTag) {
    starts.add(localeTag);
    unawaited(_session?.close());
    _cancelled = false;
    _session = StreamController<SpeechEvent>(
      onCancel: () {
        stops++;
        _cancelled = true;
      },
    );
    return _session!.stream;
  }

  @override
  Future<void> stop() async => stops++;

  /// The recognizer's guess for the utterance so far.
  void say(String partial) => _session?.add(SpeechPartial(partial));

  /// The utterance is final.
  void settle(String text) => _session?.add(SpeechFinal(text));

  /// The session ends with [event] (stopped by default).
  void end([SpeechEvent event = const SpeechStopped()]) {
    _session?.add(event);
    unawaited(_session?.close());
  }
}
