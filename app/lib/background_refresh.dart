import 'dart:ui';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/auth/supabase_start.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/refresh/refresh_providers.dart';
import 'package:dottoday/data/sync/background_sync.dart';
import 'package:dottoday/data/sync/supabase_sync_gateway.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';

/// The OS task name for the daily refresh (also in iOS's Info.plist
/// `BGTaskSchedulerPermittedIdentifiers` and AppDelegate.swift).
const backgroundRefreshTask = 'dottoday.refresh';

/// Android's one-off re-arm after a clock or zone change
/// (`TimeChangeReceiver.kt`, M6.5.5). The dispatcher runs the same refresh
/// for every task name.
const rearmTask = 'dottoday.rearm';

/// Asks iOS (BGAppRefresh) and Android (WorkManager) to run the daily
/// refresh about once a day, also when Dottoday isn't open (docs/07,
/// docs/09 M5.2). macOS and the web refresh on start, resume and a timer.
Future<void> scheduleBackgroundRefresh() async {
  if (kIsWeb) return;
  final supported = {TargetPlatform.iOS, TargetPlatform.android};
  if (!supported.contains(defaultTargetPlatform)) return;
  final workmanager = Workmanager();
  await workmanager.initialize(backgroundRefreshDispatcher);
  await workmanager.registerPeriodicTask(
    backgroundRefreshTask,
    backgroundRefreshTask,
    frequency: const Duration(hours: 24),
    // Not at once: the app has just refreshed on start, and a worker opening
    // the database during start-up only contends for it (M5.4 CI).
    initialDelay: const Duration(hours: 12),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

/// The background isolate's entry point: a small composition root with
/// the same database and providers as the app, then one [DailyRefresh] —
/// which here also syncs once when signed in (M6.5.6).
@pragma('vm:entry-point')
void backgroundRefreshDispatcher() {
  Workmanager().executeTask((task, _) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    tz_data.initializeTimeZones();
    // No widget tree here, so no Localizations to load date symbols for
    // notification and widget text.
    await initializeDateFormatting();
    final logger = Logger(const DeveloperLogSink(), const SystemClock());
    // Restores the session from the Keychain/Keystore vault, as the app
    // does; null (no config, or it can't start) keeps the job local.
    final client = await startSupabase(Env.fromEnvironment(), logger);
    final container = ProviderContainer(
      overrides: [
        loggerProvider.overrideWithValue(logger),
        supabaseClientProvider.overrideWithValue(client),
        backgroundSyncProvider.overrideWith(
          (ref) => client == null ? null : _oneShotSync(ref, client, logger),
        ),
      ],
    );
    try {
      final profile = await container.read(localProfileProvider.future);
      // Actions surfaces queued since the app last ran (M9.2).
      await container.read(actionQueueDrainerProvider).drain();
      return await container.read(dailyRefreshProvider).run(profile.id);
    } on Object catch (e, st) {
      logger.error('refresh.background_failed', error: e, stackTrace: st);
      return false;
    } finally {
      container.dispose();
      if (client != null) await Supabase.instance.dispose();
    }
  });
}

BackgroundSync _oneShotSync(Ref ref, SupabaseClient client, Logger logger) =>
    BackgroundSync(
      engine: SyncEngine(
        db: ref.watch(appDatabaseProvider),
        gateway: SupabaseSyncGateway(client),
        hlc: ref.watch(sharedHlcProvider),
        clock: ref.watch(clockProvider),
        clockOffset: () => ref.read(serverClockProvider)?.offset,
      ),
      accountId: () => client.auth.currentUser?.id,
      logger: logger,
    );
