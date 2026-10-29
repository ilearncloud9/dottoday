@TestOn('browser')
@Tags(['web'])
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/thinking/web/prompt_api_transport_web.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:flutter_test/flutter_test.dart';

@JS('eval')
external JSAny? _eval(String code);

// Chrome's Prompt API in a real browser (docs/09 M10.1): no
// `LanguageModel` reads as unavailable; a stubbed one is asked with the
// system instructions, the language and the JSON-Schema constraint, and
// its session is destroyed after.
void main() {
  // Recent Chromium ships the real API; keep it to restore after stubs.
  final original = globalContext.getProperty<JSAny?>('LanguageModel'.toJS);
  tearDown(() => globalContext.setProperty('LanguageModel'.toJS, original));

  test("the browser's own API, if any, answers without throwing", () async {
    final state = await const PromptApiTransport().availability();
    expect(ThinkingAvailability.values, contains(state));
  });

  test('no LanguageModel: unavailable, no answer', () async {
    globalContext.setProperty('LanguageModel'.toJS, null);
    const t = PromptApiTransport();
    expect(await t.availability(), ThinkingAvailability.notEligible);
    expect(
      await t.generate(
        ThinkingPrompts.suggestDuration(
          const DurationRequest(title: 'x', language: 'en'),
        ),
      ),
      isNull,
    );
  });

  test('availability words map like the native ones', () async {
    for (final (word, expected) in [
      ('available', ThinkingAvailability.available),
      ('downloadable', ThinkingAvailability.downloadable),
      ('downloading', ThinkingAvailability.downloading),
      ('unavailable', ThinkingAvailability.notEligible),
    ]) {
      _eval(
        'globalThis.LanguageModel = '
        '{availability: async () => "$word", create: async () => null};',
      );
      expect(await const PromptApiTransport().availability(), expected);
    }
  });

  test('generate passes instructions, language and schema', () async {
    _eval('''
      globalThis.__calls = {};
      globalThis.LanguageModel = {
        availability: async () => "available",
        create: async (o) => {
          __calls.create = o;
          return {
            prompt: async (text, opts) => {
              __calls.text = text;
              __calls.schema = opts.responseConstraint;
              return '{"minutes":30}';
            },
            destroy: () => { __calls.destroyed = true; },
          };
        },
      };
    ''');
    final answer = await const PromptApiTransport().generate(
      ThinkingPrompts.suggestDuration(
        const DurationRequest(title: 'Gym', language: 'es'),
      ),
    );
    expect(answer, '{"minutes":30}');
    final calls = (_eval('JSON.stringify(__calls)')! as JSString).toDart;
    expect(calls, contains('"role":"system"'));
    expect(calls, contains('"languages":["es"]'));
    expect(calls, contains('"required":["minutes"]'));
    expect(calls, contains('Task: \\"Gym\\"'));
    expect(calls, contains('"destroyed":true'));
  });
}
