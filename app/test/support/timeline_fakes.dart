import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/dev/demo_day.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';
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
  Future<Occurrence?> findById(String userId, String id) async => _rows[id];

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

/// Provider overrides for a timeline backed by in-memory fakes at [now].
List<Override> timelineOverrides({
  required DateTime now,
  FakeOccurrenceRepository? occurrences,
  Profile? profile,
}) {
  final p = profile ?? testProfile();
  return [
    clockProvider.overrideWithValue(FakeClock(now)),
    minuteTickProvider.overrideWith((ref) => Stream.value(now)),
    localProfileProvider.overrideWith((ref) async => p),
    settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository(p)),
    occurrenceRepositoryProvider.overrideWithValue(
      occurrences ?? FakeOccurrenceRepository(),
    ),
  ];
}
