import 'dart:ui';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/refresh/refresh_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';

/// The OS task name for the daily refresh (also in iOS's Info.plist
/// `BGTaskSchedulerPermittedIdentifiers` and AppDelegate.swift).
const backgroundRefreshTask = 'dottoday.refresh';

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
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

/// The background isolate's entry point: a small composition root with
/// the same database and providers as the app, then one [DailyRefresh].
@pragma('vm:entry-point')
void backgroundRefreshDispatcher() {
  Workmanager().executeTask((task, _) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    tz_data.initializeTimeZones();
    final logger = Logger(const DeveloperLogSink(), const SystemClock());
    final container = ProviderContainer(
      overrides: [loggerProvider.overrideWithValue(logger)],
    );
    try {
      final profile = await container.read(localProfileProvider.future);
      return await container.read(dailyRefreshProvider).run(profile.id);
    } on Object catch (e, st) {
      logger.error('refresh.background_failed', error: e, stackTrace: st);
      return false;
    } finally {
      container.dispose();
    }
  });
}
