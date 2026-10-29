// The Web Speech API in its on-device mode only (ADR-0014, D1/D2):
// `SpeechRecognition.available({langs, processLocally: true})` and an
// instance with `processLocally = true`, which fails with
// `language-not-supported` rather than sending audio to a server. A
// browser without both (Safari, Firefox, older Chrome with only the
// server-backed `webkitSpeechRecognition`) reads as unavailable.
// Hand-written js_interop, as prompt_api_transport_web.dart.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/speech/speech_wire.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';

/// [SpeechRecognizer] over `globalThis.SpeechRecognition`, on-device only.
final class WebSpeechRecognizer implements SpeechRecognizer {
  const WebSpeechRecognizer();

  static JSObject? _active;

  /// The browsers that ship on-device Web Speech (ADR-0014). Elsewhere —
  /// headless Chromium, Brave, Opera, plain Chromium — `available()` with
  /// `processLocally` can crash the tab (found in CI's headless Chromium,
  /// M14 PR), so it is never called there and the mic stays hidden (D2).
  static const _onDeviceBrowsers = {'Google Chrome', 'Microsoft Edge'};

  static bool get _trustedBrowser {
    final data = globalContext
        .getProperty<JSObject>('navigator'.toJS)
        .getProperty<JSObject?>('userAgentData'.toJS);
    final brands = data?.getProperty<JSArray<JSObject>?>('brands'.toJS);
    if (brands == null) return false;
    return brands.toDart.any(
      (b) => _onDeviceBrowsers.contains(
        b.getProperty<JSString?>('brand'.toJS)?.toDart,
      ),
    );
  }

  /// The constructor, only when it can promise on-device recognition.
  static JSFunction? get _api {
    if (!_trustedBrowser) return null;
    final ctor = globalContext.getProperty<JSAny?>('SpeechRecognition'.toJS);
    if (ctor == null || !ctor.isA<JSFunction>()) return null;
    final api = ctor as JSFunction;
    final available = api.getProperty<JSAny?>('available'.toJS);
    final proto = api.getProperty<JSAny?>('prototype'.toJS);
    final local =
        proto != null &&
        (proto as JSObject).has('processLocally') &&
        available != null;
    return local ? api : null;
  }

  @override
  Future<SpeechAvailability> availability(String localeTag) async {
    final api = _api;
    if (api == null) return SpeechAvailability.unavailable;
    try {
      final options = {
        'langs': [localeTag],
        'processLocally': true,
      }.jsify();
      final answer = await api
          .callMethod<JSPromise<JSString>>('available'.toJS, options)
          .toDart;
      // "downloadable"/"downloading": no pack fetch the user didn't ask
      // for (ADR-0014); the mic stays hidden until it is installed.
      if (answer.toDart != 'available') return SpeechAvailability.unavailable;
    } on Object {
      return SpeechAvailability.unavailable;
    }
    return _microphone();
  }

  /// The browser's microphone permission, where it can say.
  static Future<SpeechAvailability> _microphone() async {
    try {
      final permissions = globalContext
          .getProperty<JSObject>('navigator'.toJS)
          .getProperty<JSObject?>('permissions'.toJS);
      if (permissions == null) return SpeechAvailability.available;
      final status = await permissions
          .callMethod<JSPromise<JSObject>>(
            'query'.toJS,
            {'name': 'microphone'}.jsify(),
          )
          .toDart;
      return switch (status.getProperty<JSString>('state'.toJS).toDart) {
        'denied' => SpeechAvailability.denied,
        'prompt' => SpeechAvailability.needsPermission,
        _ => SpeechAvailability.available,
      };
    } on Object {
      return SpeechAvailability.available;
    }
  }

  /// The browser asks for the microphone when listening starts.
  @override
  Future<SpeechAvailability> requestPermission(String localeTag) async =>
      _api == null
      ? SpeechAvailability.unavailable
      : SpeechAvailability.available;

  @override
  Stream<SpeechEvent> start(String localeTag) {
    final api = _api;
    if (api == null) {
      return Stream.value(SpeechError(speechFailureOf('unavailable')));
    }
    final out = StreamController<SpeechEvent>();
    final rec = api.callAsConstructor<JSObject>()
      ..setProperty('lang'.toJS, localeTag.toJS)
      ..setProperty('processLocally'.toJS, true.toJS)
      ..setProperty('continuous'.toJS, true.toJS)
      ..setProperty('interimResults'.toJS, true.toJS);
    void emit(SpeechEvent e) {
      if (!out.isClosed) out.add(e);
    }

    rec
      ..setProperty('onresult'.toJS, ((JSObject e) => _results(e, emit)).toJS)
      ..setProperty(
        'onerror'.toJS,
        ((JSObject e) {
          final code = e.getProperty<JSString?>('error'.toJS)?.toDart;
          // Silence and our own abort are not failures.
          if (code == 'no-speech' || code == 'aborted') return;
          emit(SpeechError(speechFailureOf(_errorCode(code))));
          unawaited(out.close());
        }).toJS,
      )
      ..setProperty(
        'onend'.toJS,
        (() {
          emit(const SpeechStopped());
          unawaited(out.close());
          if (identical(_active, rec)) _active = null;
        }).toJS,
      );
    _active = rec;
    rec.callMethod<JSAny?>('start'.toJS);
    return out.stream;
  }

  /// Interim words → one partial; each newly final result → a final.
  static void _results(JSObject e, void Function(SpeechEvent) emit) {
    final results = e.getProperty<JSObject>('results'.toJS);
    final length = results.getProperty<JSNumber>('length'.toJS).toDartInt;
    final from = e.getProperty<JSNumber>('resultIndex'.toJS).toDartInt;
    final interim = StringBuffer();
    for (var i = from; i < length; i++) {
      final result = results.getProperty<JSObject>(i.toJS);
      final best = result.getProperty<JSObject>(0.toJS);
      final text = best.getProperty<JSString>('transcript'.toJS).toDart;
      if (result.getProperty<JSBoolean>('isFinal'.toJS).toDart) {
        emit(SpeechFinal(text));
      } else {
        interim.write(text);
      }
    }
    if (interim.isNotEmpty) emit(SpeechPartial(interim.toString()));
  }

  static String _errorCode(String? webError) => switch (webError) {
    'not-allowed' || 'service-not-allowed' => 'permission',
    'language-not-supported' => 'unavailable',
    'audio-capture' => 'interrupted',
    _ => 'recognizer',
  };

  @override
  Future<void> stop() async => _active?.callMethod<JSAny?>('stop'.toJS);
}
