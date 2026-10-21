import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/dev/demo_day.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:timezone/timezone.dart' as tz;

import 'fake_clock.dart';

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
  Stream<List<Occurrence>> watchInbox(String userId) => Stream.value([
    for (final o in _rows.values)
      if (o.startUtc == null && o.deletedAt == null) o,
  ]);

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

  @override
  Stream<Profile?> watchProfile(String userId) => Stream.value(profile);

  @override
  Future<Profile?> findLocalProfile() async => profile;

  @override
  Future<void> upsert(Profile profile) async => this.profile = profile;
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
  FakeSeriesRepository([this.series = const []]);

  final List<Series> series;

  @override
  Stream<List<Series>> watchActive(String userId) => Stream.value(series);

  @override
  Future<Series?> findById(String userId, String id) async =>
      series.where((s) => s.id == id).firstOrNull;

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
  FakeUndoService(this.occurrences, [this.subtasks]);

  final FakeOccurrenceRepository occurrences;
  final FakeSubtaskRepository? subtasks;
  final _subtasksBefore = <String, List<Subtask>>{};
  final applied = <WriteBatch>[];
  final _before = <String, List<Occurrence>>{};
  var _n = 0;

  @override
  Future<Result<UndoToken, AppFailure>> applyUndoable(WriteBatch batch) async {
    final id = 'undo-${_n++}';
    _before[id] = [
      for (final o in batch.occurrences)
        ?occurrences.rows.where((r) => r.id == o.id).firstOrNull,
    ];
    _subtasksBefore[id] = [
      for (final s in batch.subtasks)
        ?subtasks?.rows.where((r) => r.id == s.id).firstOrNull,
    ];
    applied.add(batch);
    occurrences.put(batch.occurrences);
    subtasks?.put(batch.subtasks);
    return Ok(UndoToken(id: id, expiresAtUtc: DateTime.utc(2100)));
  }

  @override
  Future<Result<void, AppFailure>> undo(UndoToken token) async {
    occurrences.put(_before.remove(token.id) ?? const []);
    subtasks?.put(_subtasksBefore.remove(token.id) ?? const []);
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
}) {
  final p = profile ?? testProfile();
  final repo = occurrences ?? FakeOccurrenceRepository();
  final subs = subtasks ?? FakeSubtaskRepository();
  return [
    subtaskRepositoryProvider.overrideWithValue(subs),
    seriesRepositoryProvider.overrideWithValue(FakeSeriesRepository(series)),
    undoServiceProvider.overrideWithValue(FakeUndoService(repo, subs)),
    clockProvider.overrideWithValue(FakeClock(now)),
    minuteTickProvider.overrideWith((ref) => minuteTicks ?? Stream.value(now)),
    localProfileProvider.overrideWith((ref) async => p),
    settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository(p)),
    occurrenceRepositoryProvider.overrideWithValue(repo),
  ];
}
