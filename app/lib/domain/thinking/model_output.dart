import 'dart:convert';

import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// Turns a model's text into proposals, treating it as untrusted input
/// (06 §7): JSON only (a Markdown fence around it is tolerated), control
/// characters out, titles trimmed to the column limit, lengths clamped to
/// the schema's checks, lists capped. Anything unusable gives null, and
/// the service falls back to rules.
///
/// ```dart
/// ModelOutput.breakdown('{"steps":[{"title":"Clear","minutes":5}]}', 7)
///     ?.single.durationMin; // 5
/// ```
abstract final class ModelOutput {
  /// The `title` column limit (docs/05).
  static const maxTitle = 200;

  /// Most dots one brain-dump may propose.
  static const maxDots = 50;

  static final _control = RegExp(r'[\u0000-\u001F\u007F]');
  static final _fence = RegExp(r'^```[a-zA-Z]*\s*|\s*```$');
  static final _clock = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$');

  /// Steps from `{"steps":[{"title":…,"minutes":…}]}`, at most [maxSteps].
  static List<ProposedStep>? breakdown(String? text, int maxSteps) {
    final items = _list(_object(text), 'steps');
    if (items == null) return null;
    final steps = <ProposedStep>[];
    for (final item in items) {
      if (steps.length == maxSteps) break;
      final title = _title(item);
      if (title == null) continue;
      steps.add(
        ProposedStep(title: title, durationMin: _minutes(item, 1, 1440)),
      );
    }
    return steps.isEmpty ? null : steps;
  }

  /// Dots from `{"dots":[{"title":…,"start":"HH:MM","minutes":…}]}`.
  static List<ProposedDot>? dots(String? text) {
    final items = _list(_object(text), 'dots');
    if (items == null) return null;
    final dots = <ProposedDot>[];
    for (final item in items) {
      if (dots.length == maxDots) break;
      final title = _title(item);
      if (title == null) continue;
      dots.add(
        ProposedDot(
          title: title,
          minuteOfDay: _start(item),
          durationMin: _minutes(item, 5, 1440),
        ),
      );
    }
    return dots.isEmpty ? null : dots;
  }

  /// Minutes from `{"minutes":…}`, 5–1440.
  static int? minutes(String? text) {
    final object = _object(text);
    return object == null ? null : _minutes(object, 5, 1440);
  }

  static Map<String, Object?>? _object(String? text) {
    if (text == null) return null;
    final body = text.trim().replaceAll(_fence, '');
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  static List<Object?>? _list(Map<String, Object?>? object, String key) {
    final value = object?[key];
    return value is List<Object?> ? value : null;
  }

  static String? _title(Object? item) {
    if (item is! Map<String, Object?>) return null;
    final raw = item['title'];
    if (raw is! String) return null;
    final clean = raw.replaceAll(_control, ' ').trim();
    if (clean.isEmpty) return null;
    return clean.length <= maxTitle ? clean : clean.substring(0, maxTitle);
  }

  static int? _minutes(Object? item, int min, int max) {
    if (item is! Map<String, Object?>) return null;
    final raw = item['minutes'];
    final value = raw is num && raw.isFinite ? raw.round() : null;
    if (value == null || value <= 0) return null;
    return value.clamp(min, max);
  }

  static int? _start(Object? item) {
    if (item is! Map<String, Object?>) return null;
    final raw = item['start'];
    if (raw is! String) return null;
    final match = _clock.firstMatch(raw.trim());
    if (match == null) return null;
    return int.parse(match[1]!) * 60 + int.parse(match[2]!);
  }
}
