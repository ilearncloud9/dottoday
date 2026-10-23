import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/refresh/daily_refresh.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'refresh_providers.g.dart';

@Riverpod(keepAlive: true)
DailyRefresh dailyRefresh(Ref ref) => DailyRefresh(
  clock: ref.watch(clockProvider),
  series: ref.watch(seriesRepositoryProvider),
  writes: ref.watch(writeUseCaseProvider),
  notifications: ref.watch(notificationSyncProvider),
  widgets: ref.watch(widgetSnapshotWriterProvider),
  logger: ref.watch(loggerProvider),
);
