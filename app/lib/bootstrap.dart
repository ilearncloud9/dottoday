import 'dart:async';

import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/background_refresh.dart';
import 'package:dottoday/core/app/app_restart.dart';
import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/logging/error_handlers.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/core/router/native_deep_links.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/theme/icon_licenses.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/auth/supabase_start.dart';
import 'package:dottoday/data/notifications/sound_licenses.dart';
import 'package:dottoday/data/observability/sentry_reporting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

/// Composition root: error handlers, config, then the app.
///
/// Throws [EnvConfigError] before the first frame if the compile-time env
/// defines are missing or invalid (docs/09 M0.3, ADR-0005).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sinks = FanOutLogSink([const DeveloperLogSink()]);
  final logger = Logger(sinks, const SystemClock());
  installErrorHandlers(logger);
  registerIconLicenses();
  registerSoundLicenses();
  // IANA zone data for TZDateTime arithmetic and tz_id validation (docs/05).
  tz_data.initializeTimeZones();
  // Date symbols for every locale: notification and widget text is
  // formatted outside the widget tree (M5.1, M5.4).
  await initializeDateFormatting();

  final env = Env.fromEnvironment();

  // Crash reports (M6.7) through the same PII-checked Logger. Sentry's own
  // error handlers are replaced by ours again, so every error takes the
  // one path: type and event, never the message.
  if (await startSentry(env)) {
    sinks.add(SentryLogSink());
    installErrorHandlers(logger);
  }

  _scheduleBackgroundRefresh(logger);
  // Android draws under transparent system bars (07 Android, M5.6); screens
  // keep their content out of them with SafeArea.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  }

  // Accounts and sync (M6.1); null keeps the app on this device.
  final supabase = await startSupabase(env, logger);
  // One inbox across restarts: a sign-in link may arrive before the
  // account service exists.
  final callbacks = AuthCallbackInbox();

  // The root scope is AppRestart's UncontrolledProviderScope (M3f.9), which
  // the lint doesn't see through.
  // ignore: riverpod_lint/missing_provider_scope
  runApp(
    AppRestart(
      create: () {
        late final GoRouter router;
        router = buildRouter(
          appScreens,
          onAuthCallback: callbacks.deliver,
          // After the frame that shows Today, so the sheet has a navigator.
          onAdd: () => WidgetsBinding.instance.addPostFrameCallback(
            (_) => openQuickAdd(router),
          ),
        );
        _listenForNativeLinks(router, logger);
        return ProviderContainer(
          retry: noProviderRetry,
          overrides: [
            envProvider.overrideWithValue(env),
            loggerProvider.overrideWithValue(logger),
            routerProvider.overrideWithValue(router),
            supabaseClientProvider.overrideWithValue(supabase),
            authCallbackInboxProvider.overrideWithValue(callbacks),
          ],
        );
      },
      child: const DottodayApp(),
    ),
  );
}

/// Registers the OS daily refresh (M5.2); a failure only means the next
/// start or resume refreshes instead.
void _scheduleBackgroundRefresh(Logger logger) => unawaited(
  scheduleBackgroundRefresh().catchError(
    (Object e, StackTrace s) =>
        logger.warn('refresh.schedule_failed', error: e, stackTrace: s),
  ),
);

/// Apple platforms hand launch links over a bridge (M5.0); a restart
/// re-targets it at the new router.
void _listenForNativeLinks(GoRouter router, Logger logger) {
  const bridged = {TargetPlatform.iOS, TargetPlatform.macOS};
  if (kIsWeb || !bridged.contains(defaultTargetPlatform)) return;
  unawaited(
    listenForNativeDeepLinks(router).catchError(
      (Object e, StackTrace s) =>
          logger.error('deep_link.bridge_failed', error: e, stackTrace: s),
    ),
  );
}

/// Root retry policy: never auto-retry. Riverpod 3 retries failed providers
/// by default (a null `retry` falls back to that default), which would hide
/// failures and repeat side effects; providers that want retries opt in with
/// their own `retry:` (docs/09 M0.11).
@visibleForTesting
Duration? noProviderRetry(int retryCount, Object error) => null;
