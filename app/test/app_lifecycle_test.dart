import 'dart:async';

import 'package:dottoday/app_lifecycle.dart';
import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/no_device_calendar_gateway.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/intents/no_action_queue_store.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/notifications/pending_notification_gateways.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/refresh/daily_refresh.dart';
import 'package:dottoday/data/refresh/refresh_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/snapshot/bedtime_snapshot.dart';
import 'package:dottoday/data/snapshot/day_snapshot_writer.dart';
import 'package:dottoday/data/snapshot/snapshot_providers.dart';
import 'package:dottoday/data/system/system_events.dart';
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
  late FakeSystemEvents events;

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
    when(
      () => backup.nextDailyDueUtc(any()),
    ).thenAnswer((_) async => DateTime.utc(2026, 10, 23));
    events = FakeSystemEvents();
  });
  tearDown(() => events.close());

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
        actionQueueStoreProvider.overrideWithValue(const NoActionQueueStore()),
        bedtimeSnapshotProvider.overrideWithValue(
          BedtimeSnapshot(
            clock: FakeClock(DateTime.utc(2026, 10, 21)),
            writer: snapshots,
            logger: Logger(logs, FakeClock(DateTime.utc(2026))),
            // Wind Down is hours away; the lifecycle only arms it.
            timer: (_, _) => _IdleTimer(),
          ),
        ),
        loggerProvider.overrideWithValue(
          Logger(logs, FakeClock(DateTime.utc(2026))),
        ),
        // 02:00 in Berlin (testProfile): midnight is 22 h away.
        clockProvider.overrideWithValue(FakeClock(_now)),
        systemEventsProvider.overrideWithValue(events),
        // The Wake Up alarm's events (M17.3): none here.
        alarmGatewayProvider.overrideWithValue(FakeAlarmGateway()),
        wakeUpDayRepositoryProvider.overrideWithValue(
          FakeWakeUpDayRepository(),
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

  // No polling period (docs/04 §4 "Triggers"): it runs when something is due.
  testWidgets('runs again at local midnight, not before (M5.2)', (
    tester,
  ) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 1);
    await tester.pump(const Duration(hours: 21, minutes: 59, seconds: 59));
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 1, reason: 'nothing runs before it is due');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 2);
    verify(() => backup.runDailyIfDue(testUserId)).called(2);
  });

  testWidgets('runs when the daily backup is due, if that comes first', (
    tester,
  ) async {
    when(
      () => backup.nextDailyDueUtc(any()),
    ).thenAnswer((_) async => _now.add(const Duration(hours: 5)));
    await pump(tester);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(hours: 5));
    await tester.pumpAndSettle();
    verify(() => backup.runDailyIfDue(testUserId)).called(2);
  });

  testWidgets('a Mac wake or a clock change runs it at once', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 1);
    events.send(SystemEvent.wake);
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 2);
    events.send(SystemEvent.clock);
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 3);
  });

  testWidgets('events at once run it once more, never in parallel', (
    tester,
  ) async {
    await pump(tester);
    await tester.pumpAndSettle();
    events
      ..send(SystemEvent.wake)
      ..send(SystemEvent.clock)
      ..send(SystemEvent.wake);
    await tester.pumpAndSettle();
    expect(gateway.resyncs, 3, reason: 'start, the first event, one more');
  });

  testWidgets('a device calendar change imports once the burst settles', (
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
    final resyncs = gateway.resyncs;
    for (var i = 0; i < 5; i++) {
      events.send(SystemEvent.calendar);
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(import.runs, hasLength(1), reason: 'still settling');
    await tester.pump(CalendarActions.deviceChangeSettle);
    await tester.pumpAndSettle();
    expect(import.runs, hasLength(2));
    expect(gateway.resyncs, resyncs, reason: 'only the import runs');
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

final _now = DateTime.utc(2026, 10, 21);

/// The OS events, sent by the test.
final class FakeSystemEvents implements SystemEvents {
  final _out = StreamController<SystemEvent>.broadcast();

  void send(SystemEvent event) => _out.add(event);

  @override
  Stream<SystemEvent> get events => _out.stream;

  @override
  Future<void> close() => _out.close();
}

final class _IdleTimer implements Timer {
  @override
  void cancel() {}

  @override
  bool get isActive => false;

  @override
  int get tick => 0;
}
