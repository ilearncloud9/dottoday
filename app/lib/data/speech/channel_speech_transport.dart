import 'dart:async';

import 'package:dottoday/data/speech/speech_wire.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:flutter/services.dart';

/// [SpeechRecognizer] over `dottoday/speech` (ADR-0014, docs/09 M14.4):
/// `SpeechBridge.swift` on iOS and macOS (`SFSpeechRecognizer`, on-device
/// required) and `SpeechBridge.kt` on Android 12+ (the on-device
/// recognizer only). Events arrive on `dottoday/speech/events`. A
/// platform without the handler reads as unavailable, so the mic hides.
final class ChannelSpeechRecognizer implements SpeechRecognizer {
  const ChannelSpeechRecognizer([
    this._methods = const MethodChannel('dottoday/speech'),
    this._events = const EventChannel('dottoday/speech/events'),
  ]);

  final MethodChannel _methods;
  final EventChannel _events;

  @override
  Future<SpeechAvailability> availability(String localeTag) =>
      _ask('availability', localeTag);

  @override
  Future<SpeechAvailability> requestPermission(String localeTag) =>
      _ask('requestPermission', localeTag);

  @override
  Future<SpeechAvailability> download(String localeTag) =>
      _ask('download', localeTag);

  Future<SpeechAvailability> _ask(String method, String localeTag) async {
    try {
      return parseSpeechAvailability(
        await _methods.invokeMethod<String>(method, {'locale': localeTag}),
      );
    } on MissingPluginException {
      return SpeechAvailability.unavailable;
    } on PlatformException {
      return SpeechAvailability.unavailable;
    }
  }

  @override
  Stream<SpeechEvent> start(String localeTag) {
    late final StreamController<SpeechEvent> out;
    StreamSubscription<Object?>? events;
    Future<void> finish(SpeechEvent last) async {
      if (out.isClosed) return;
      out.add(last);
      await events?.cancel();
      await out.close();
    }

    out = StreamController<SpeechEvent>(
      onListen: () {
        events = _events.receiveBroadcastStream().listen(
          (raw) {
            final event = parseSpeechEvent(raw);
            if (event == null) return;
            if (event is SpeechStopped || event is SpeechError) {
              unawaited(finish(event));
            } else if (!out.isClosed) {
              out.add(event);
            }
          },
          // A broken channel ends the session; its message isn't kept.
          onError: (Object _) =>
              unawaited(finish(SpeechError(speechFailureOf(null)))),
        );
        unawaited(
          _methods
              .invokeMethod<void>('start', {'locale': localeTag})
              .catchError(
                (Object e) => finish(
                  SpeechError(
                    speechFailureOf(e is PlatformException ? e.code : null),
                  ),
                ),
              ),
        );
      },
      onCancel: () async {
        await events?.cancel();
        await stop();
      },
    );
    return out.stream;
  }

  @override
  Future<void> stop() async {
    try {
      await _methods.invokeMethod<void>('stop');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
