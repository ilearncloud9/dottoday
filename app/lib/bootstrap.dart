import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/logging/error_handlers.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root: error handlers, config, then the app.
///
/// Throws [EnvConfigError] before the first frame if the compile-time env
/// defines are missing or invalid (docs/09 M0.3, ADR-0005).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger(const DeveloperLogSink(), const SystemClock());
  installErrorHandlers(logger);

  final env = Env.fromEnvironment();

  runApp(
    ProviderScope(
      retry: noProviderRetry,
      overrides: [
        envProvider.overrideWithValue(env),
        loggerProvider.overrideWithValue(logger),
        routerProvider.overrideWithValue(buildRouter(appScreens)),
      ],
      child: const DottodayApp(),
    ),
  );
}

/// Root retry policy: never auto-retry. Riverpod 3 retries failed providers
/// by default (a null `retry` falls back to that default), which would hide
/// failures and repeat side effects; providers that want retries opt in with
/// their own `retry:` (docs/09 M0.11).
@visibleForTesting
Duration? noProviderRetry(int retryCount, Object error) => null;
