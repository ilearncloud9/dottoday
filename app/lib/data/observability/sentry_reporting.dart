import 'dart:async';

import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/logging/log_sink.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Crash reporting (docs/04 §9, 06 §6, docs/09 M6.7). Everything reaches
// Sentry through the Logger, which already refuses content (PII): an error
// arrives as its type and the log event, never its message. The scrubber
// below is the second line: whatever else an SDK attaches is removed
// before an event leaves the device.

/// The category every breadcrumb of ours carries; anything else is dropped.
const sentryCategory = 'dottoday';

/// Starts Sentry when [Env.sentryDsn] is set; false otherwise. No default
/// PII, no screenshots or view hierarchy (they show task titles), no
/// automatic user-interaction or native breadcrumbs.
Future<bool> startSentry(Env env) async {
  final dsn = env.sentryDsn;
  if (dsn == null) return false;
  await SentryFlutter.init((o) {
    o
      ..dsn = dsn
      ..sendDefaultPii = false
      ..attachScreenshot = false
      ..attachViewHierarchy = false
      ..enableUserInteractionBreadcrumbs = false
      ..enableAutoNativeBreadcrumbs = false
      ..beforeSend = scrubEvent
      ..beforeBreadcrumb = scrubBreadcrumb;
  });
  return true;
}

/// Removes what could identify the person or hold their content: user,
/// request, server and device names, exception messages (types and stacks
/// stay), and breadcrumbs that aren't ours. Our own [LoggedError] keeps its
/// text: it is the log event and error type, nothing else.
SentryEvent? scrubEvent(SentryEvent event, Hint hint) {
  event
    ..user = null
    ..request = null
    ..serverName = null
    ..breadcrumbs = event.breadcrumbs
        ?.where((b) => b.category?.startsWith(sentryCategory) ?? false)
        .toList();
  event.contexts.device?.name = null;
  for (final e in event.exceptions ?? const <SentryException>[]) {
    if (e.type != '$LoggedError') e.value = null;
  }
  final message = event.message?.formatted ?? '';
  if (message.isNotEmpty && !message.startsWith(sentryCategory)) {
    event.message = null;
  }
  return event;
}

/// Keeps only breadcrumbs the Logger made.
Breadcrumb? scrubBreadcrumb(Breadcrumb? b, Hint hint) =>
    (b?.category?.startsWith(sentryCategory) ?? false) ? b : null;

/// What Sentry receives for a logged error: the event and the original
/// error's type. Never the error itself (its message may hold content).
final class LoggedError implements Exception {
  const LoggedError(this.event, this.errorType);

  final String event;
  final String? errorType;

  @override
  String toString() => '${errorType ?? 'Error'} at $event';
}

/// Sends log records to Sentry: every record as a breadcrumb (its fields
/// are already PII-free), errors also as events.
final class SentryLogSink implements LogSink {
  SentryLogSink([Hub? hub]) : _hub = hub ?? HubAdapter();

  final Hub _hub;

  @override
  void write(LogRecord record) {
    unawaited(
      _hub.addBreadcrumb(
        Breadcrumb(
          category: '$sentryCategory.${record.event}',
          level: _level(record.level),
          data: {...record.fields},
          timestamp: record.timeUtc,
        ),
      ),
    );
    if (record.level != LogLevel.error) return;
    unawaited(
      _hub.captureException(
        LoggedError(record.event, record.errorType),
        stackTrace: record.stackTrace,
      ),
    );
  }

  static SentryLevel _level(LogLevel l) => switch (l) {
    LogLevel.debug => SentryLevel.debug,
    LogLevel.info => SentryLevel.info,
    LogLevel.warn => SentryLevel.warning,
    LogLevel.error => SentryLevel.error,
  };
}
