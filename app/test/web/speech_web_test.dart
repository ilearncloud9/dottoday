@TestOn('browser')
@Tags(['web'])
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/speech/web/speech_web.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

@JS('eval')
external JSAny? _eval(String code);

// The Web Speech API in its on-device mode only (docs/09 M14.4, ADR-0014):
// without `available()` and `processLocally` (Safari, Firefox, webkit-
// only Chrome) the mic is unavailable; a language pack still to download
// is unavailable too; a stubbed recognizer is started with
// processLocally and its results become partials and finals.

const _stub = '''
globalThis.__made = [];
globalThis.SpeechRecognition = class {
  constructor() { this.processLocally = false; __made.push(this); }
  start() {
    const r = (t, f) => { const x = [{transcript: t}]; x.isFinal = f; return x; };
    const results = [r('Call the dentist.', true), r('buy', false)];
    setTimeout(() => {
      this.onresult({results, resultIndex: 0});
      this.onend();
    }, 0);
  }
  stop() {}
};
SpeechRecognition.prototype.processLocally = false;
SpeechRecognition.available = async (o) =>
  o.processLocally && o.langs[0] === 'en-US' ? __answer : 'unavailable';
globalThis.__answer = 'available';
''';

void main() {
  final original = globalContext.getProperty<JSAny?>('SpeechRecognition'.toJS);
  tearDown(() => globalContext.setProperty('SpeechRecognition'.toJS, original));

  test("the browser's own API, if any, answers without throwing", () async {
    final a = await const WebSpeechRecognizer().availability('en-US');
    expect(SpeechAvailability.values, contains(a));
  });

  test('no API: unavailable', () async {
    globalContext.setProperty('SpeechRecognition'.toJS, null);
    expect(
      await const WebSpeechRecognizer().availability('en-US'),
      SpeechAvailability.unavailable,
    );
  });

  test(
    'a server-only API (no available/processLocally): unavailable',
    () async {
      _eval('globalThis.SpeechRecognition = class { start() {} };');
      expect(
        await const WebSpeechRecognizer().availability('en-US'),
        SpeechAvailability.unavailable,
      );
    },
  );

  test('on-device for the language: not unavailable', () async {
    _eval(_stub);
    final a = await const WebSpeechRecognizer().availability('en-US');
    expect(a, isNot(SpeechAvailability.unavailable));
    expect(
      await const WebSpeechRecognizer().availability('fr-FR'),
      SpeechAvailability.unavailable,
    );
  });

  test('a pack still to download: unavailable (ADR-0014)', () async {
    _eval('$_stub globalThis.__answer = "downloadable";');
    expect(
      await const WebSpeechRecognizer().availability('en-US'),
      SpeechAvailability.unavailable,
    );
  });

  test('start: processLocally on; results → final, partial, stopped', () async {
    _eval(_stub);
    final got = await const WebSpeechRecognizer().start('en-US').toList();
    expect(got.map((e) => e.runtimeType), [
      SpeechFinal,
      SpeechPartial,
      SpeechStopped,
    ]);
    expect((got.first as SpeechFinal).text, 'Call the dentist.');
    final local = _eval('__made[0].processLocally') as JSBoolean?;
    expect(local?.toDart, isTrue);
  });
}
