import 'dart:convert';
import 'dart:developer' as developer;

/// Severity of a [LogRecord].
enum LogLevel {
  debug(500),
  info(800),
  warn(900),
  error(1000);

  const LogLevel(this.value);

  /// `package:logging`-compatible numeric level for `dart:developer`.
  final int value;
}

/// A validated, PII-free structured log entry.
final class LogRecord {
  const LogRecord({
    required this.level,
    required this.event,
    required this.timeUtc,
    this.fields = const {},
    this.errorType,
    this.stackTrace,
  });

  final LogLevel level;

  /// Dotted lowercase event key, e.g. `sync.push.ok`.
  final String event;
  final DateTime timeUtc;

  /// Already-sanitised values (see `Logger`).
  final Map<String, Object> fields;

  /// Runtime type of the error only — never its message, which may hold PII.
  final String? errorType;
  final StackTrace? stackTrace;

  Map<String, Object?> toJson() => {
        'level': level.name,
        'event': event,
        'time': timeUtc.toIso8601String(),
        if (fields.isNotEmpty) 'fields': fields,
        if (errorType != null) 'errorType': errorType,
      };
}

/// Destination for log records (console now; Sentry breadcrumbs in M6.7).
abstract interface class LogSink {
  void write(LogRecord record);
}

/// Writes JSON lines to `dart:developer` (DevTools / IDE console).
final class DeveloperLogSink implements LogSink {
  const DeveloperLogSink();

  @override
  void write(LogRecord record) {
    developer.log(
      jsonEncode(record.toJson()),
      name: 'dottoday',
      level: record.level.value,
      time: record.timeUtc,
      stackTrace: record.stackTrace,
    );
  }
}
