import 'package:dottoday/core/logging/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;

/// Where an uncaught error was reported from.
enum ErrorSource { flutter, platform }

/// Strips Riverpod 3's [ProviderException] wrappers so logs show the real
/// error type and its original stack (docs/09 M0.11).
(Object, StackTrace?) unwrapProviderException(
  Object error,
  StackTrace? stackTrace,
) {
  var (e, s) = (error, stackTrace);
  while (e is ProviderException) {
    (e, s) = (e.exception, e.stackTrace);
  }
  return (e, s);
}

/// Routes uncaught framework and async errors to [logger].
///
/// Install first in `bootstrap()`, before anything that can throw. The
/// logger records type + stack only (no messages: PII, CLAUDE.md §4). In
/// debug the default console output is kept so developers still see the
/// full message locally; release builds never print it.
void installErrorHandlers(Logger logger) {
  FlutterError.onError = (details) {
    _report(logger, ErrorSource.flutter, details.exception, details.stack);
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _report(logger, ErrorSource.platform, error, stackTrace);
    // false = let the engine print it too (debug only).
    return !kDebugMode;
  };
}

void _report(
  Logger logger,
  ErrorSource source,
  Object error,
  StackTrace? stackTrace,
) {
  final (e, s) = unwrapProviderException(error, stackTrace);
  logger.error(
    'app.uncaught_error',
    fields: {'source': source},
    error: e,
    stackTrace: s,
  );
}
