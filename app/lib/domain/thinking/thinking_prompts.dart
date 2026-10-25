import 'dart:convert';

import 'package:dottoday/domain/thinking/thinking_backend.dart';

/// The request kinds on the wire (`dottoday/thinking`, the Prompt API) and
/// in the local log.
enum ThinkingKind {
  breakDown('break_down'),
  planFromText('plan_from_text'),
  suggestDuration('suggest_duration');

  const ThinkingKind(this.wire);

  final String wire;
}

/// One model call: the same words for every on-device model, so the three
/// platforms answer alike (R-13). Swift's guided generation reads [kind]
/// to pick its `@Generable` type; Kotlin and Chrome get [schema].
final class ThinkingPrompt {
  const ThinkingPrompt({
    required this.kind,
    required this.language,
    required this.instructions,
    required this.prompt,
    required this.schema,
  });

  final ThinkingKind kind;

  /// The language answers should be written in (BCP 47 primary subtag).
  final ThinkingLanguage language;
  final String instructions;
  final String prompt;

  /// JSON Schema of the expected answer (`ModelOutput` parses it).
  final Map<String, Object?> schema;

  Map<String, Object?> toWire() => {
    'kind': kind.wire,
    'language': language,
    'instructions': instructions,
    'prompt': prompt,
    'schema': jsonEncode(schema),
  };
}

/// Builds [ThinkingPrompt]s. The user's text is quoted as data; whatever
/// the model answers is still only a proposal the user reviews.
abstract final class ThinkingPrompts {
  static const _tone =
      'You help someone plan their day. Be concrete and kind. Never mention '
      'being late, failing or productivity. Answer only with JSON that '
      'matches the schema.';

  static ThinkingPrompt breakDown(BreakdownRequest r) => ThinkingPrompt(
    kind: ThinkingKind.breakDown,
    language: r.language,
    instructions:
        '$_tone Split a task into small physical steps, in order, each '
        'starting with a verb. Write the steps in the language "${r.language}".',
    prompt: [
      'Task: ${jsonEncode(r.title)}',
      if (r.durationMin != null) 'Planned length: ${r.durationMin} minutes.',
      'Give 2 to ${r.stepLimit} steps with minutes for each.',
    ].join('\n'),
    schema: {
      'type': 'object',
      'properties': {
        'steps': {
          'type': 'array',
          'maxItems': r.stepLimit,
          'items': {
            'type': 'object',
            'properties': {
              'title': {'type': 'string', 'maxLength': 80},
              'minutes': {'type': 'integer', 'minimum': 1, 'maximum': 240},
            },
            'required': ['title', 'minutes'],
          },
        },
      },
      'required': ['steps'],
    },
  );

  static ThinkingPrompt planFromText(TextPlanRequest r) => ThinkingPrompt(
    kind: ThinkingKind.planFromText,
    language: r.language,
    instructions:
        '$_tone Turn free text into separate tasks for one day. Keep the '
        "user's words for titles, in the language \"${r.language}\". Use "
        '24-hour HH:MM for a start only when the text names a time.',
    prompt: 'Text: ${jsonEncode(r.text)}',
    schema: {
      'type': 'object',
      'properties': {
        'dots': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'title': {'type': 'string', 'maxLength': 120},
              'start': {'type': 'string', 'pattern': r'^\d{2}:\d{2}$'},
              'minutes': {'type': 'integer', 'minimum': 5, 'maximum': 600},
            },
            'required': ['title'],
          },
        },
      },
      'required': ['dots'],
    },
  );

  static ThinkingPrompt suggestDuration(DurationRequest r) => ThinkingPrompt(
    kind: ThinkingKind.suggestDuration,
    language: r.language,
    instructions:
        '$_tone Estimate how many minutes a typical person needs for a task.',
    prompt: 'Task: ${jsonEncode(r.title)}',
    schema: {
      'type': 'object',
      'properties': {
        'minutes': {'type': 'integer', 'minimum': 5, 'maximum': 480},
      },
      'required': ['minutes'],
    },
  );
}
