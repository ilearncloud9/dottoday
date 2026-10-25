import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/refresh/daily_refresh.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/sync/background_sync.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'refresh_providers.g.dart';

@Riverpod(keepAlive: true)
DailyRefresh dailyRefresh(Ref ref) => DailyRefresh(
  clock: ref.watch(clockProvider),
  series: ref.watch(seriesRepositoryProvider),
  writes: ref.watch(writeUseCaseProvider),
  notifications: ref.watch(notificationSyncProvider),
  widgets: ref.watch(daySnapshotWriterProvider),
  logger: ref.watch(loggerProvider),
  sync: ref.watch(backgroundSyncProvider),
);

/// The background job's one-shot sync (M6.5.6). Null in the app, which
/// syncs through `EngineSyncService`; `backgroundRefreshDispatcher`
/// overrides it.
@Riverpod(keepAlive: true)
BackgroundSync? backgroundSync(Ref ref) => null;
