import 'dart:async';

import 'package:dottoday/app_lifecycle.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/no_device_calendar_gateway.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/notifications/pending_notification_gateways.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/refresh/daily_refresh.dart';
import 'package:dottoday/data/refresh/refresh_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/snapshot/bedtime_snapshot.dart';
import 'package:dottoday/data/snapshot/day_snapshot_writer.dart';
import 'package:dottoday/data/snapshot/snapshot_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/calendar/calendar_import.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/trash/trash_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/calendar_fakes.dart';
import 'support/fake_clock.dart';
import 'support/memory_log_sink.dart';
import 'support/timeline_fakes.dart';

class _Backup extends Mock implements BackupService {}

class _Trash extends Mock implements TrashService {}

class _Series extends Mock implements SeriesRepository {}

/// Counts reconciliations; can be told to throw.
final class _Gateway implements NotificationGateway {
  int resyncs = 0;
  bool fail = false;

  @override
  Future<Map<int, PlannedNotification>> pending() async {
    resyncs++;
    if (fail) throw StateError('plugin');
    return {};
  }

  @override
  Future<void> apply(NotificationDiff diff) async {}
}

void main() {
  late _Backup backup;
  late _Trash trash;
  late _Gateway gateway;
  late NotificationSync sync;
  late MemoryLogSink logs;
  late DaySnapshotWriter snapshots;
  late DailyRefresh refresh;

  setUpAll(tz_data.initializeTimeZones);

  setUp(() {
    backup = _Backup();
    trash = _Trash();
    gateway = _Gateway();
    final series = _Series();
    when(() => series.watchActive(any())).thenAnswer((_) => Stream.value([]));
    when(
      () => series.findNeedingMaterialisation(any(), any()),
    ).thenAnswer((_) async => []);
    final clock = FakeClock(DateTime.utc(2026, 10, 21));
    sync = NotificationSync(
      clock: clock,
      planner: NotificationPlanner(clock: clock),
      gateway: gateway,
      occurrences: FakeOccurrenceRepository(),
      series: series,
      settings: FakeSettingsRepository(testProfile()),
    );
    logs = MemoryLogSink();
    snapshots = DaySnapshotWriter(
      clock: clock,
      occurrences: FakeOccurrenceRepository(),
      profile: () async => testProfile(),
      sink: const UnwiredDaySnapshotSink(),
    );
    refresh = DailyRefresh(
      clock: clock,
      series: series,
      writes: FakeWriteUseCase(
        FakeSettingsRepository(testProfile()),
        FakeOccurrenceRepository(),
      ),
      notifications: sync,
      widgets: snapshots,
      logger: Logger(logs, clock),
    );
    when(
      () => backup.runDailyIfDue(any()),
    ).thenAnswer((_) async => const Ok(true));
    when(() => trash.purgeExpired(any())).thenAnswer((_) async => const Ok(0));
  });

  Future<void> pump(
    WidgetTester tester, {
    DeviceCalendarGateway calendars = const NoDeviceCalendarGateway(),
    CalendarImport? import,
  }) => tester.pumpWidget(
    ProviderScope(
      overrides: [
        deviceCalendarGatewayProvider.overrideWithValue(calendars),
        calendarSourceRepositoryProvider.overrideWithValue(
          FakeCalendarSourceRepository(),
        ),
        writeBackControllerProvider.overrideWith(IdleWriteBackController.new),
        calendarImporterProvider.overrideWithValue(
          import ?? FakeCalendarImport(),
        ),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(testProfile()),
        ),
        currentDeviceZoneProvider.overrideWith((ref) async => 'Europe/Berlin'),
        localProfileProvider.overrideWith((ref) async => testProfile()),
        backupServiceProvider.overrideWithValue(backup),
        trashServiceProvider.overrideWithValue(trash),
        notificationSyncProvider.overrideWithValue(sync),
        dailyRefreshProvider.overrideWithValue(refresh),
        bedtimeSnapshotProvider.overrideWithValue(
          BedtimeSnapshot(
            clock: FakeClock(DateTime.utc(2026, 10, 21)),
            writer: snapshots,
            logger: Logger(logs, FakeClock(DateTime.utc(2026))),
            // Bedtime is hours away; the lifecycle only arms it.
            timer: (_, _) => _IdleTimer(),
          ),
        ),
        loggerProvider.overrideWithValue(
          Logger(logs, FakeClock(DateTime.utc(2026))),
        ),
      ],
      child: const AppLifecycleScope(child: SizedBox()),
    ),
  );

  testWidgets('runs housekeeping after the first frame and on resume', (
    tester,
  ) async {
    await pump(tester);
    await tester.pumpAndSettle();
    verify(() => backup.runDailyIfDue(testUserId)).called(1);
    verify(() => trash.purgeExpired(testUserId)).called(1);
    expect(gateway.resyncs, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    verify(() => backup.runDailyIfDue(testUserId)).called(1);
    expect(gateway.resyncs, 2);
  });

  testWidgets('brings calendar events in on start and resume (M7.2)', (
    tester,
  ) async {
    final import = FakeCalendarImport();
    await pump(
      tester,
      calendars: FakeDeviceCalendarGateway(
        state: PermissionState.granted,
        list: sampleCalendars,
      ),
      import: import,
    );
    await tester.pumpAndSettle();
    expect(import.runs, hasLength(1));
    expect(import.runs.single.map((c) => c.calendar.id), contains('work'));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(import.runs, hasLength(2));
  });

  testWidgets('runs again every 6 hours while open (M5.2)', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 1);
    await tester.pump(const Duration(hours: 6));
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 2);
  });

  testWidgets('a failing step is logged and the rest still run', (
    tester,
  ) async {
    when(
      () => backup.runDailyIfDue(any()),
    ).thenAnswer((_) async => const Err<bool, AppFailure>(StorageFailure()));
    await pump(tester);
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 1);
    expect(
      logs.records.map((r) => r.event),
      contains('housekeeping.backup_failed'),
    );
  });

  testWidgets('an exception is logged, never thrown', (tester) async {
    gateway.fail = true;
    await pump(tester);
    await tester.pumpAndSettle();
    expect(logs.records.map((r) => r.event), contains('housekeeping.failed'));
  });
}

final class _IdleTimer implements Timer {
  @override
  void cancel() {}

  @override
  bool get isActive => false;

  @override
  int get tick => 0;
}
