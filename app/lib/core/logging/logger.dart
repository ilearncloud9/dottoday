import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/logging/log_sink.dart';
import 'package:dottoday/core/logging/log_values.dart';

export 'log_sink.dart';
export 'log_values.dart';

/// Structured logger that cannot carry task content (CLAUDE.md §4,
/// docs/06 §8: titles/notes are PII — log IDs only).
///
/// * `event` is a dotted lowercase key, never prose.
/// * Field values: `num`, `bool`, `Enum`, `Duration`, `DateTime`, [LogId]
///   or [Redacted]. Raw strings are rejected; use [LogId] or [redact].
/// * Field keys that name content (`title`, `notes`, …) are rejected.
/// * Errors are logged by runtime type + stack only.
///
/// In debug/test builds a violation throws [ArgumentError]; in release it is
/// sanitised (event replaced, field redacted/dropped) so nothing leaks.
///
/// ```dart
/// log.info('sync.push.ok', fields: {'occurrenceId': LogId(id), 'count': 3});
/// log.info('title: x'); // ArgumentError in debug
/// ```
final class Logger {
  Logger(this._sink, this._clock, {bool? strict})
    : _strict = strict ?? _assertsEnabled;

  final LogSink _sink;
  final Clock _clock;
  final bool _strict;

  /// Reduces [value] to its length so content never reaches a log.
  static Redacted redact(String value) => Redacted(value.length);

  void debug(String event, {Map<String, Object> fields = const {}}) =>
      _log(LogLevel.debug, event, fields, null, null);

  void info(String event, {Map<String, Object> fields = const {}}) =>
      _log(LogLevel.info, event, fields, null, null);

  void warn(
    String event, {
    Map<String, Object> fields = const {},
    Object? error,
    StackTrace? stackTrace,
  }) => _log(LogLevel.warn, event, fields, error, stackTrace);

  void error(
    String event, {
    Map<String, Object> fields = const {},
    Object? error,
    StackTrace? stackTrace,
  }) => _log(LogLevel.error, event, fields, error, stackTrace);

  void _log(
    LogLevel level,
    String event,
    Map<String, Object> fields,
    Object? error,
    StackTrace? stackTrace,
  ) {
    _sink.write(
      LogRecord(
        level: level,
        event: _checkEvent(event),
        timeUtc: _clock.nowUtc(),
        fields: _checkFields(fields),
        errorType: error?.runtimeType.toString(),
        stackTrace: stackTrace,
      ),
    );
  }

  String _checkEvent(String event) {
    if (isValidLogEvent(event)) return event;
    _violation(
      'Log event must be a dotted lowercase key (got length '
      '${event.length}); put data in typed fields.',
    );
    return 'log.invalid_event';
  }

  Map<String, Object> _checkFields(Map<String, Object> fields) {
    final out = <String, Object>{};
    for (final MapEntry(:key, :value) in fields.entries) {
      if (!isSafeLogFieldKey(key)) {
        _violation('Log field key "$key" may name content (PII).');
        continue;
      }
      out[key] = _checkValue(key, value);
    }
    return out;
  }

  Object _checkValue(String key, Object value) {
    return switch (value) {
      num() || bool() => value,
      Enum() => value.name,
      Duration() => value.inMilliseconds,
      DateTime() => value.toUtc().toIso8601String(),
      Redacted() => value.toString(),
      LogId() when value.isValid => value.value,
      _ => _rejectValue(key, value),
    };
  }

  Object _rejectValue(String key, Object value) {
    _violation(
      'Log field "$key" has a ${value.runtimeType} value; '
      'use LogId, Logger.redact or a non-string type.',
    );
    return value is String ? redact(value).toString() : '<redacted>';
  }

  void _violation(String message) {
    if (_strict) throw ArgumentError(message);
  }
}

final _event = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$');
final _key = RegExp(r'^[a-z][a-zA-Z0-9]*$');
const _contentWords = [
  'title',
  'note',
  'name',
  'body',
  'text',
  'email',
  'subtask',
  'description',
  'location',
];

/// Whether [event] is a dotted lowercase key like `sync.push.ok`.
bool isValidLogEvent(String event) => _event.hasMatch(event);

/// Whether [key] is camelCase and does not name content.
bool isSafeLogFieldKey(String key) {
  if (!_key.hasMatch(key)) return false;
  final lower = key.toLowerCase();
  return !_contentWords.any(lower.contains);
}

bool get _assertsEnabled {
  var enabled = false;
  assert(enabled = true, 'only evaluated with asserts on');
  return enabled;
}
