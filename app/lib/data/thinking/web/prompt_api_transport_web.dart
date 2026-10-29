// Chrome's built-in Prompt API (Gemini Nano in the browser, docs/09
// M10.1): `LanguageModel.availability()` / `create()` / `prompt()` with a
// JSON-Schema response constraint. Runs in the browser; no request leaves
// the device. Hand-written js_interop, as tab_live_dot_web.dart.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/thinking/channel_thinking_transport.dart';
import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';

/// Languages the Prompt API accepts for output today; others ask in
/// English and the model is told the user's language in the instructions.
const _outputLanguages = {'en', 'es', 'ja'};

extension type _LanguageModel._(JSObject _) implements JSObject {
  external JSPromise<JSString> availability([JSAny? options]);
  external JSPromise<_Session> create([JSAny? options]);
}

extension type _Session._(JSObject _) implements JSObject {
  external JSPromise<JSString> prompt(String input, [JSAny? options]);
  external void destroy();
}

/// [ThinkingTransport] over `globalThis.LanguageModel`; unavailable where
/// the browser has none (Safari, Firefox, older Chrome).
final class PromptApiTransport implements ThinkingTransport {
  const PromptApiTransport();

  static _LanguageModel? get _api {
    final api = globalContext.getProperty<JSAny?>('LanguageModel'.toJS);
    return api == null ? null : api as _LanguageModel;
  }

  @override
  Future<ThinkingAvailability> availability() async {
    final api = _api;
    // No API (Safari, Firefox, older Chrome): this browser can't run it.
    if (api == null) return parseAvailability('not_eligible');
    final value = await api.availability(_options('en')).toDart;
    return parseAvailability(value.toDart);
  }

  @override
  Future<String?> generate(ThinkingPrompt prompt) async {
    final api = _api;
    if (api == null) return null;
    final language = _languageOf(prompt);
    final options = _options(language)
      ..setProperty(
        'initialPrompts'.toJS,
        [
          {'role': 'system', 'content': prompt.instructions},
        ].jsify(),
      );
    final session = await api.create(options).toDart;
    try {
      final constraint = {'responseConstraint': prompt.schema};
      final answer = await session
          .prompt(prompt.prompt, constraint.jsify())
          .toDart;
      return answer.toDart;
    } finally {
      session.destroy();
    }
  }

  static JSObject _options(String language) =>
      {
            'expectedInputs': [
              {'type': 'text'},
            ],
            'expectedOutputs': [
              {
                'type': 'text',
                'languages': [language],
              },
            ],
          }.jsify()!
          as JSObject;

  static String _languageOf(ThinkingPrompt prompt) =>
      _outputLanguages.contains(prompt.language) ? prompt.language : 'en';
}
