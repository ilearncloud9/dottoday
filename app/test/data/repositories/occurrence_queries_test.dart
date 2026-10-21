import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';

final _day = DateTime.utc(2026, 10, 21);
final _next = DateTime.utc(2026, 10, 22);

Occurrence _at(String id, DateTime? start, {int minutes = 60}) =>
    occurrenceFixture().copyWith(id: id, startUtc: start, durationMin: minutes);

void main() {
  late AppDatabase db;
  late DriftOccurrenceRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftOccurrenceRepository(db);
    await DriftSettingsRepository(db).upsert(profileFixture());
  });
  tearDown(() => db.close());

  Future<List<String>> dayIds() async =>
      (await repo.watchRange(userId, _day, _next).first)
          .map((o) => o.id)
          .toList();

  test('range = blocks overlapping the window, ordered by start', () async {
    await repo.upsertAll([
      _at('late', _day.add(const Duration(hours: 22))),
      _at('early', _day.add(const Duration(hours: 1))),
      // Crosses midnight into the day: shown.
      _at('overnight', _day.subtract(const Duration(hours: 1)), minutes: 120),
      // Ends exactly at the window start: not shown.
      _at('yesterday', _day.subtract(const Duration(hours: 1))),
      // A full-day block that started 23:59 the day before: shown.
      _at('long', _day.subtract(const Duration(minutes: 1)), minutes: 1440),
      // Starts exactly at the window end: not shown.
      _at('tomorrow', _next),
      _at('inbox', null),
      _at(
        'deleted',
        _day.add(const Duration(hours: 3)),
      ).copyWith(deletedAt: t1),
    ]);
    expect(await dayIds(), ['overnight', 'long', 'early', 'late']);
  });

  test('equal starts are ordered by id (stable timeline)', () async {
    final start = _day.add(const Duration(hours: 9));
    await repo.upsertAll([_at('b', start), _at('a', start)]);
    expect(await dayIds(), ['a', 'b']);
  });

  test('inbox = live unscheduled items by sort order', () async {
    await repo.upsertAll([
      _at('x', null).copyWith(sortOrder: 2),
      _at('y', null).copyWith(sortOrder: 1),
      _at('z', null).copyWith(sortOrder: 0, deletedAt: t1),
      _at('scheduled', _day),
    ]);
    final inbox = await repo.watchInbox(userId).first;
    expect(inbox.map((o) => o.id), ['y', 'x']);
  });

  test('day stream re-emits after a write, including moves out', () async {
    final o = _at('o', _day.add(const Duration(hours: 9)));
    await repo.upsertAll([o]);
    final emissions = repo.watchRange(userId, _day, _next).take(3).toList();
    await pumpEventQueue();
    await repo.upsertAll([o.copyWith(title: 'Moved later')]);
    await pumpEventQueue();
    await repo.upsertAll([o.copyWith(startUtc: _next)]);
    final ids = (await emissions).map((l) => l.map((o) => o.title).toList());
    expect(ids, [
      ['Dentist'],
      ['Moved later'],
      <String>[],
    ]);
  });
}
