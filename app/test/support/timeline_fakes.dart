import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/calendar_shift_providers.dart';
import 'package:dottoday/data/calendar/cloud_calendar_providers.dart';
import 'package:dottoday/data/calendar/no_device_calendar_gateway.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/dev/demo_day.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/feedback/diagnostics_reader.dart';
import 'package:dottoday/data/feedback/feedback_providers.dart';
import 'package:dottoday/data/live_activity/live_activity_dismissed.dart';
import 'package:dottoday/data/notifications/fln_exact_alarms.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/pending_notification_gateways.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/release/whats_new_seen.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:dottoday/data/security/app_lock_store.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/calendar/calendar_import.dart';
import 'package:dottoday/domain/calendar/calendar_source_repository.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/feedback/feedback_diagnostics.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/battery_optimization.dart';
import 'package:dottoday/domain/notifications/exact_alarms.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';
import 'package:dottoday/domain/repositories/wake_up_day_repository.dart';
import 'package:dottoday/domain/security/app_lock.dart';
import 'package:dottoday/domain/trash/trash_service.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/validation/entity_validators.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:timezone/timezone.dart' as tz;

import 'calendar_fakes.dart';
import 'calendar_series_fakes.dart';
import 'export_fakes.dart';
import 'fake_clock.dart';
import 'fake_notification_platform.dart';
import 'reveal_hint_fakes.dart';
import 'routine_fakes.dart';
import 'search_fakes.dart';

const testUserId = '01928c3e-0000-7000-8000-000000000001';

/// In-memory occurrences with the repository's overlap semantics.
final class FakeOccurrenceRepository implements OccurrenceRepository {
  FakeOccurrenceRepository([Iterable<Occurrence> rows = const []])
    : _rows = {for (final o in rows) o.id: o};

  final Map<String, Occurrence> _rows;
  final _changes = StreamController<void>.broadcast();

  List<Occurrence> get rows => _rows.values.toList();

  void put(Iterable<Occurrence> rows) {
    for (final o in rows) {
      _rows[o.id] = o;
    }
    _changes.add(null);
  }

  List<Occurrence> _range(DateTime from, DateTime to) =>
      _rows.values
          .where(
            (o) =>
                o.deletedAt == null &&
                o.startUtc != null &&
                o.startUtc!.isBefore(to) &&
                o.endUtc!.isAfter(from),
          )
          .toList()
        ..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));

  @override
  Stream<List<Occurrence>> watchRange(
    String userId,
    DateTime fromUtc,
    DateTime toUtc,
  ) async* {
    yield _range(fromUtc, toUtc);
    yield* _changes.stream.map((_) => _range(fromUtc, toUtc));
  }

  @override
  Stream<List<Occurrence>> watchInbox(String userId) async* {
    yield _inbox();
    yield* _changes.stream.map((_) => _inbox());
  }

  List<Occurrence> _inbox() => [
    for (final o in _rows.values)
      if (o.startUtc == null && o.deletedAt == null) o,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  @override
  Future<Occurrence?> findById(String userId, String id) async {
    // Owner-scoped like the real repository (06 §9).
    final row = _rows[id];
    return row?.userId == userId ? row : null;
  }

  @override
  Future<List<Occurrence>> findBySeries(String userId, String seriesId) async =>
      [
        for (final o in _rows.values)
          if (o.seriesId == seriesId) o,
      ];

  @override
  Future<void> upsertAll(Iterable<Occurrence> occurrences) async =>
      put(occurrences);
}

final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this.profile);

  Profile profile;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<Profile?> watchProfile(String userId) async* {
    yield profile;
    yield* _changes.stream.map((_) => profile);
  }

  @override
  Future<Profile?> findLocalProfile() async => profile;

  @override
  Future<void> upsert(Profile profile) async {
    this.profile = profile;
    _changes.add(null);
  }
}

/// Makes every write through the fakes fail while [failure] is set (a
/// full disk, M8.5b); clear it to let the next one land.
final class WriteFault {
  AppFailure? failure;
}

/// The write path over the fakes: validates settings like the real one
/// (refusing an invalid batch whole), then stores profile and occurrences.
final class FakeWriteUseCase implements WriteUseCase {
  FakeWriteUseCase(this.settings, this.occurrences, [this.fault, this.hints]);

  final FakeSettingsRepository settings;
  final FakeOccurrenceRepository occurrences;
  final WriteFault? fault;
  final FakeRevealHintRepository? hints;
  final applied = <WriteBatch>[];

  @override
  Future<Result<void, AppFailure>> apply(WriteBatch batch) async {
    if (fault?.failure case final f?) return Err(f);
    if (batch.profile case final p?) {
      if (validateSettings(p.settings) case Err(:final failure)) {
        return Err(failure);
      }
    }
    applied.add(batch);
    if (batch.profile case final p?) await settings.upsert(p);
    occurrences.put(batch.occurrences);
    await hints?.upsertAll(batch.revealHints);
    return const Ok(null);
  }
}

final class FakeSubtaskRepository implements SubtaskRepository {
  FakeSubtaskRepository([Iterable<Subtask> rows = const []]) : rows = [...rows];

  final List<Subtask> rows;
  final _changes = StreamController<void>.broadcast();

  /// Inserts or replaces [subtasks] by id and notifies watchers.
  void put(Iterable<Subtask> subtasks) {
    for (final s in subtasks) {
      rows
        ..removeWhere((r) => r.id == s.id)
        ..add(s);
    }
    _changes.add(null);
  }

  @override
  Future<List<Subtask>> findForOccurrences(
    String userId,
    Set<String> occurrenceIds,
  ) async => [
    for (final s in rows)
      if (occurrenceIds.contains(s.occurrenceId)) s,
  ];

  List<Subtask> _of(Set<String> ids) => [
    for (final s in rows)
      if (ids.contains(s.occurrenceId) && s.deletedAt == null) s,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  @override
  Stream<List<Subtask>> watchForOccurrences(
    String userId,
    Set<String> occurrenceIds,
  ) async* {
    yield _of(occurrenceIds);
    yield* _changes.stream.map((_) => _of(occurrenceIds));
  }

  @override
  Future<Subtask?> findById(String userId, String id) async =>
      rows.where((s) => s.id == id).firstOrNull;

  @override
  Future<void> upsertAll(Iterable<Subtask> subtasks) async => put(subtasks);
}

final class FakeSeriesRepository implements SeriesRepository {
  FakeSeriesRepository([Iterable<Series> series = const []])
    : _rows = {for (final s in series) s.id: s};

  final Map<String, Series> _rows;

  /// Every stored series, written ones included (M3f.1 scopes).
  List<Series> get series => _rows.values.toList();

  /// Stores [rows] as a write would (no materialisation).
  void put(Iterable<Series> rows) {
    for (final s in rows) {
      _rows[s.id] = s;
    }
  }

  @override
  Stream<List<Series>> watchActive(String userId) => Stream.value(series);

  @override
  Future<Series?> findById(String userId, String id) async => _rows[id];

  @override
  Future<List<Series>> findNeedingMaterialisation(
    String userId,
    DateTime horizonUtc,
  ) async => const [];

  @override
  Future<void> upsertAll(Iterable<Series> series) async {}
}

/// Applies batches straight to the fake repository; undo restores the
/// previous rows.
final class FakeUndoService implements UndoService {
  FakeUndoService(
    this.occurrences, [
    this.subtasks,
    this.series,
    this.settings,
    this.fault,
  ]);

  final FakeOccurrenceRepository occurrences;

  /// Fails [applyUndoable] while set.
  final WriteFault? fault;
  final FakeSubtaskRepository? subtasks;
  final FakeSeriesRepository? series;

  /// Takes a batch's repeating-calendar-event settings (docs/02 F5.7).
  FakeCalendarSeriesRepository? calendarSeries;

  /// Takes a batch's profile (the travel banner, M5.9).
  final FakeSettingsRepository? settings;
  final _profileBefore = <String, Profile>{};
  final _seriesBefore = <String, List<Series>>{};
  final _subtasksBefore = <String, List<Subtask>>{};
  final applied = <WriteBatch>[];
  final _before = <String, List<Occurrence>>{};
  final _batchIds = Map<WriteBatch, String>.identity();
  var _n = 0;

  @override
  Future<Result<UndoToken, AppFailure>> applyUndoable(WriteBatch batch) async {
    if (fault?.failure case final f?) return Err(f);
    redoable = _redoBatch = null;
    final id = 'undo-${_n++}';
    _before[id] = [
      for (final o in batch.occurrences)
        ?occurrences.rows.where((r) => r.id == o.id).firstOrNull,
    ];
    _subtasksBefore[id] = [
      for (final s in batch.subtasks)
        ?subtasks?.rows.where((r) => r.id == s.id).firstOrNull,
    ];
    _seriesBefore[id] = [for (final s in batch.series) ?series?._rows[s.id]];
    final settings = this.settings;
    if (batch.profile != null && settings != null) {
      _profileBefore[id] = settings.profile;
      await settings.upsert(batch.profile!);
    }
    applied.add(batch);
    _batchIds[batch] = id;
    series?.put(batch.series);
    occurrences.put(batch.occurrences);
    subtasks?.put(batch.subtasks);
    await calendarSeries?.upsertAll(batch.calendarSeries);
    return Ok(latest = UndoToken(id: id, expiresAtUtc: DateTime.utc(2100)));
  }

  @override
  UndoToken? latest;

  @override
  UndoToken? redoable;
  WriteBatch? _redoBatch;

  /// Like the real service: re-applying the undone batch, as a new token.
  @override
  Future<Result<UndoToken, AppFailure>> redo(UndoToken token) async {
    final batch = _redoBatch;
    if (token != redoable || batch == null) {
      return const Err(UndoExpiredFailure());
    }
    return applyUndoable(batch);
  }

  @override
  Future<Result<void, AppFailure>> undo(UndoToken token) async {
    _redoBatch = applied.where((b) => _batchIds[b] == token.id).firstOrNull;
    redoable = _redoBatch == null
        ? null
        : UndoToken(id: 'redo-${_n++}', expiresAtUtc: DateTime.utc(2100));
    final seriesBefore = _seriesBefore.remove(token.id) ?? const <Series>[];
    final made = applied
        .where((b) => _batchIds[b] == token.id)
        .expand((b) => b.series)
        .where((s) => seriesBefore.every((o) => o.id != s.id));
    series?.put([
      ...seriesBefore,
      for (final s in made) s.copyWith(deletedAt: DateTime.utc(2026)),
    ]);
    final before = _before.remove(token.id) ?? const [];
    final batch = applied.firstWhere(
      (b) => b.occurrences.isNotEmpty && _batchIds[b] == token.id,
      orElse: () => const WriteBatch(userId: testUserId),
    );
    // Like the real service: rows the batch created are soft-deleted.
    final known = {for (final o in before) o.id};
    occurrences.put([
      ...before,
      for (final o in batch.occurrences)
        if (!known.contains(o.id)) o.copyWith(deletedAt: DateTime.utc(2100)),
    ]);
    subtasks?.put(_subtasksBefore.remove(token.id) ?? const []);
    if (_profileBefore.remove(token.id) case final p?) {
      await settings?.upsert(p);
    }
    return const Ok(null);
  }
}

Profile testProfile({String tzId = 'Europe/Berlin', Settings? settings}) =>
    Profile(
      id: testUserId,
      tzId: tzId,
      settings: settings ?? const Settings(use24h: true),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

/// The debug demo day for [date] in Berlin, with today's standup
/// materialised by hand (the fake repository has no write path).
List<Occurrence> demoDayRows(DateTime date, {DateTime? now}) {
  final berlin = tz.getLocation('Europe/Berlin');
  final at = now ?? DateTime.utc(2026, 10, 21, 11);
  final batch = buildDemoDay(
    userId: testUserId,
    location: berlin,
    date: date,
    nowUtc: at,
  );
  final s = batch.series.single;
  final standup = Occurrence(
    id: '${s.id.substring(0, 30)}aaaaaa',
    userId: testUserId,
    seriesId: s.id,
    title: s.title,
    colorKey: s.colorKey,
    iconKey: s.iconKey,
    startUtc: tz.TZDateTime(berlin, date.year, date.month, date.day, 8).toUtc(),
    tzId: s.tzId,
    durationMin: s.durationMin,
    createdAt: at,
    updatedAt: at,
  );
  return [...batch.occurrences, standup];
}

/// A week of demo days, Sun 18 – Sat 24 Oct 2026 (the Week board, M3e.3):
/// each day keeps some of the demo day's timed tasks so the loads differ;
/// days before the 21st are done.
List<Occurrence> demoWeekRows() => [
  for (var i = 0; i < 7; i++)
    ...() {
      final date = DateTime(2026, 10, 18 + i);
      final timed = [
        for (final o in demoDayRows(date))
          if (o.startUtc != null) o,
      ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
      return [
        for (final o in timed.take(3 + (i * 3) % 7))
          o.copyWith(
            status: i < 3 ? OccurrenceStatus.done : OccurrenceStatus.planned,
          ),
      ];
    }(),
];

/// The demo day's subtasks (three on "Deep work", one done).
List<Subtask> demoDaySubtasks(DateTime date) => buildDemoDay(
  userId: testUserId,
  location: tz.getLocation('Europe/Berlin'),
  date: date,
  nowUtc: DateTime.utc(2026, 10, 21, 11),
).subtasks;

/// Provider overrides for a timeline backed by in-memory fakes at [now].
List<Override> timelineOverrides({
  required DateTime now,
  FakeOccurrenceRepository? occurrences,
  FakeSubtaskRepository? subtasks,
  List<Series> series = const [],
  Profile? profile,
  Stream<DateTime>? minuteTicks,
  List<String> recentSearches = const [],
  NotificationPermission notificationPermission =
      const UnwiredNotificationPermission(),
  ExactAlarms exactAlarms = const AlwaysExactAlarms(),
  AlarmCapabilities wakeUpAlarm = const AlarmCapabilities(AlarmTier.alarm),
  FakeAlarmGateway? alarmGateway,
  FakeWakeUpDayRepository? wakeUpDays,
  String? deviceZone,
  LearningMetaState learningMeta = const LearningMetaState(),
  DeviceCalendarGateway calendarGateway = const NoDeviceCalendarGateway(),
  CalendarSourceRepository? calendarSources,
  CalendarImport? calendarImport,
  CalendarImport? cloudCalendarImport,
  IdleWriteBackController Function()? writeBack,
  Set<String> readOnlyCalendarIds = const {},
  BackupService? backups,
  FileGateway? files,
  ExportService? exports,
  String whatsNewSeen = '0.1.0',
  DiagnosticsReader diagnostics = const FakeDiagnosticsReader(),
  WriteFault? writeFault,
  List<Routine> routines = const [],
  FakeRevealHintRepository? revealHints,
  FakeCalendarSeriesRepository? calendarSeries,
}) {
  final p = profile ?? testProfile();
  final repo = occurrences ?? FakeOccurrenceRepository();
  final subs = subtasks ?? FakeSubtaskRepository();
  final seriesRepo = FakeSeriesRepository(series);
  final settingsRepo = FakeSettingsRepository(p);
  final hintRepo = revealHints ?? FakeRevealHintRepository();
  final importedRepo = (calendarSeries ?? FakeCalendarSeriesRepository())
    ..occurrences = repo;
  final undo = FakeUndoService(
    repo,
    subs,
    seriesRepo,
    settingsRepo,
    writeFault,
  );
  return [
    writeUseCaseProvider.overrideWithValue(
      FakeWriteUseCase(settingsRepo, repo, writeFault, hintRepo),
    ),
    subtaskRepositoryProvider.overrideWithValue(subs),
    seriesRepositoryProvider.overrideWithValue(seriesRepo),
    routineRepositoryProvider.overrideWithValue(
      FakeRoutineRepository(routines),
    ),
    // The widget hint's trigger (M16): never dismissed, no database.
    liveActivityDismissedProvider.overrideWith(_NoLiveActivityDismissal.new),
    // Minimal mode's hint records (docs/14 §6).
    revealHintRepositoryProvider.overrideWithValue(hintRepo),
    wakeUpDayRepositoryProvider.overrideWithValue(
      wakeUpDays ?? FakeWakeUpDayRepository(),
    ),
    undoServiceProvider.overrideWithValue(undo..calendarSeries = importedRepo),
    calendarSeriesRepositoryProvider.overrideWithValue(importedRepo),
    trashServiceProvider.overrideWithValue(FakeTrashService(repo, undo)),
    clockProvider.overrideWithValue(FakeClock(now)),
    minuteTickProvider.overrideWith((ref) => minuteTicks ?? Stream.value(now)),
    localProfileProvider.overrideWith((ref) async => p),
    // Where the device is; the profile's own zone unless a test travels.
    currentDeviceZoneProvider.overrideWith((ref) async => deviceZone ?? p.tzId),
    settingsRepositoryProvider.overrideWithValue(settingsRepo),
    occurrenceRepositoryProvider.overrideWithValue(repo),
    searchRepositoryProvider.overrideWithValue(FakeSearchRepository(repo)),
    recentSearchesProvider.overrideWith(
      () => FakeRecentSearches(recentSearches),
    ),
    // No OS plugin under `flutter test` (M5.1).
    notificationPermissionProvider.overrideWithValue(notificationPermission),
    exactAlarmsProvider.overrideWithValue(exactAlarms),
    // The full-screen-intent channel has no handler here (docs/15 W1a).
    alarmGatewayProvider.overrideWithValue(
      alarmGateway ?? FakeAlarmGateway(wakeUpAlarm),
    ),
    // No platform channel in widget tests (its reply would arrive outside
    // fake time): battery optimisation and DND read as off (M6.5.8).
    batteryOptimizationProvider.overrideWithValue(
      const NoBatteryOptimization(),
    ),
    appLockSettingProvider.overrideWith(FakeAppLockSetting.new),
    // No database or package info here (M8.2): up to date, counts fixed.
    appVersionNameProvider.overrideWith((ref) async => '0.1.0'),
    whatsNewSeenProvider.overrideWith(() => FakeWhatsNewSeen(whatsNewSeen)),
    learningMetaProvider.overrideWith(() => FakeLearningMeta(learningMeta)),
    diagnosticsReaderProvider.overrideWithValue(diagnostics),
    notificationGatewayProvider.overrideWithValue(
      const UnwiredNotificationGateway(),
    ),
    // The OS scheduler under the gateway: no plugin under `flutter test`;
    // the health panel reads its muted sound channels (docs/12 §4).
    notificationPlatformProvider.overrideWith(
      (ref) async => FakeNotificationPlatform(),
    ),
    // No calendar plugin under `flutter test` (M7.1).
    deviceCalendarGatewayProvider.overrideWithValue(calendarGateway),
    calendarSourceRepositoryProvider.overrideWithValue(
      calendarSources ?? FakeCalendarSourceRepository(),
    ),
    calendarImporterProvider.overrideWithValue(
      calendarImport ?? FakeCalendarImport(),
    ),
    cloudCalendarImporterProvider.overrideWithValue(
      cloudCalendarImport ?? FakeCalendarImport(),
    ),
    // Imported events a shift never carries (M7.6); no database here.
    readOnlyCalendarIdsProvider.overrideWith(
      (ref) => Stream.value(readOnlyCalendarIds),
    ),
    // No backups file, share sheet or file picker in tests (M8.1).
    backupServiceProvider.overrideWithValue(backups ?? FakeBackupService()),
    fileGatewayProvider.overrideWithValue(files ?? FakeFileGateway()),
    exportServiceProvider.overrideWithValue(exports ?? FakeExportService()),
    // A factory: each container needs its own notifier.
    writeBackControllerProvider.overrideWith(
      writeBack ?? IdleWriteBackController.new,
    ),
  ];
}

/// Trash over the fake repository: soft-deletes through [undo], so Undo
/// brings the rows back (docs/05 `trash`).
final class FakeTrashService implements TrashService {
  FakeTrashService(this.occurrences, this.undo);

  final FakeOccurrenceRepository occurrences;
  final FakeUndoService undo;

  @override
  Future<Result<UndoToken, AppFailure>> trashOccurrences(
    String userId,
    Set<String> ids,
  ) => undo.applyUndoable(
    WriteBatch(
      userId: userId,
      occurrences: [
        for (final o in occurrences.rows)
          if (ids.contains(o.id)) o.copyWith(deletedAt: DateTime.utc(2026)),
      ],
    ),
  );

  @override
  Stream<List<Occurrence>> watchTrash(String userId) => occurrences
      .watchInbox(userId)
      .map(
        (_) => [
          for (final o in occurrences.rows)
            if (o.deletedAt != null && o.userId == userId) o,
        ],
      );

  @override
  Future<Result<void, AppFailure>> restoreOccurrences(
    String userId,
    Set<String> ids,
  ) async {
    occurrences.put([
      for (final o in occurrences.rows)
        if (ids.contains(o.id)) o.copyWith(deletedAt: null),
    ]);
    return const Ok(null);
  }

  @override
  Future<Result<int, AppFailure>> purgeExpired(String userId) async =>
      const Ok(0);
}

/// The app lock, off and in memory (M5.8).
/// What's new as last seen; [seen] starts at the running version.
/// A user past Today's learning caption on [day], as the reference
/// renders show an established user (docs/10 §7; the caption has its own
/// golden, docs/13 §11).
LearningMetaState captionPutAway(DateTime day) =>
    LearningMetaState(captionDay: day);

/// Past the reality reveal and its one-time highlight
/// (`B-ios-reality-thread`).
const realityRevealedMeta = LearningMetaState(
  realityRevealed: true,
  realityHighlighted: true,
);

/// [LearningMeta] in memory: [initial] instead of `local_meta`.
final class FakeLearningMeta extends LearningMeta {
  FakeLearningMeta([this.initial = const LearningMetaState()]);

  final LearningMetaState initial;

  @override
  Future<LearningMetaState> build() async => initial;

  @override
  Future<void> persist(String key, String value) async {}
}

final class FakeWhatsNewSeen extends WhatsNewSeen {
  FakeWhatsNewSeen([this.initial = '0.1.0']);

  final String initial;

  @override
  Future<String> build() async => initial;

  @override
  Future<void> markSeen(String version) async {
    await future;
    state = AsyncData(version);
  }
}

/// Fixed diagnostics counts and node id.
final class FakeDiagnosticsReader implements DiagnosticsReader {
  const FakeDiagnosticsReader();

  @override
  Future<({DiagnosticCounts counts, String? deviceId})> read() async => (
    counts: const DiagnosticCounts(tasks: 12, inbox: 3, done: 4, repeats: 2),
    deviceId: '0a1b2c3d4e5f6071',
  );
}

final class FakeAppLockSetting extends AppLockSetting {
  @override
  Future<AppLockSettings> build() async => const AppLockSettings();

  @override
  Future<bool> save(AppLockSettings settings, {required String reason}) async {
    state = AsyncData(settings);
    return true;
  }
}

/// No Live Activity was ever dismissed (M16), without the database.
final class _NoLiveActivityDismissal extends LiveActivityDismissed {
  @override
  Future<bool> build() async => false;
}

/// [AlarmGateway] answering [capabilities] (docs/15 W1a); records fixes.
final class FakeAlarmGateway implements AlarmGateway {
  FakeAlarmGateway([
    this._capabilities = const AlarmCapabilities(AlarmTier.alarm),
  ]);

  final AlarmCapabilities _capabilities;
  final fixed = <AlarmBlocker>[];

  /// The last set handed to [sync]; every one counts as armed.
  List<WakeUpAlarm> armed = const [];

  /// False: the channel isn't there (a background engine), so [sync]
  /// answers null.
  var reachable = true;

  /// False: a device with no alarm path, which arms nothing.
  var arms = true;
  final tests = <WakeUpAlarm>[];
  var disarmed = 0;
  var authorizationRequests = 0;

  @override
  Future<AlarmCapabilities> capabilities() async => _capabilities;

  @override
  Future<void> fix(AlarmBlocker blocker) async => fixed.add(blocker);

  @override
  Future<void> requestAuthorization() async => authorizationRequests++;

  /// The started days the last [sync] called checks off for.
  Set<String> started = const {};

  @override
  Future<Set<DateTime>?> sync(
    List<WakeUpAlarm> alarms, {
    Set<String> startedDays = const {},
  }) async {
    if (!reachable) return null;
    armed = alarms;
    started = startedDays;
    return {
      if (arms)
        for (final a in alarms) a.fireAtUtc,
    };
  }

  @override
  Future<void> disarmAll() async {
    armed = const [];
    disarmed++;
  }

  @override
  Future<bool> test(WakeUpAlarm alarm) async {
    tests.add(alarm);
    return true;
  }

  /// Handed out once by [drainEvents].
  List<AlarmEvent> events = [];

  @override
  Future<List<AlarmEvent>> drainEvents() async {
    final out = events;
    events = [];
    return out;
  }
}

/// This device's mornings in memory (docs/15 §3).
final class FakeWakeUpDayRepository implements WakeUpDayRepository {
  FakeWakeUpDayRepository([Iterable<WakeUpDay> days = const []])
    : _days = {for (final d in days) d.date: d};

  final Map<String, WakeUpDay> _days;
  final _changes = StreamController<void>.broadcast();

  WakeUpDay? operator [](String date) => _days[date];

  @override
  Stream<WakeUpDay?> watch(String date) async* {
    yield _days[date];
    await for (final _ in _changes.stream) {
      yield _days[date];
    }
  }

  @override
  Future<WakeUpDay?> lastAlarm() async {
    final days = [
      for (final d in _days.values)
        if (d.rangAtUtc != null || d.stoppedAtUtc != null) d,
    ]..sort((a, b) => b.date.compareTo(a.date));
    return days.firstOrNull;
  }

  @override
  Future<void> applyEvents(List<AlarmEvent> events) async {
    for (final e in events) {
      final date = e.date;
      if (date == null) continue;
      _days[date] = applyAlarmEvent(_days[date] ?? WakeUpDay(date: date), e);
    }
    _changes.add(null);
  }

  @override
  Future<void> markCardShown(String date, DateTime atUtc) async {
    final d = _days[date] ?? WakeUpDay(date: date);
    _days[date] = d.copyWith(cardShownAtUtc: d.cardShownAtUtc ?? atUtc);
    _changes.add(null);
  }

  @override
  Future<void> markStarted(String date, DateTime atUtc) async {
    final d = _days[date] ?? WakeUpDay(date: date);
    _days[date] = d.copyWith(startedAtUtc: d.startedAtUtc ?? atUtc);
    _changes.add(null);
  }
}
