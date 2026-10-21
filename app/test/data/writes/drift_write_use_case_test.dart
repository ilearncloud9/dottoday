import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/sync/hlc.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import 'write_harness.dart';

final _now = DateTime.utc(2026, 10, 21, 6);

void main() {
  late WriteHarness h;

  setUpAll(tz_data.initializeTimeZones);

  setUp(() async {
    h = WriteHarness(_now);
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
  });
  tearDown(() => h.dispose());

  Future<Result<void, AppFailure>> write(WriteBatch b) => h.writes.apply(b);

  test('insert stamps, marks dirty and logs every field', () async {
    final o = occurrenceFixture();
    expect(
      await write(WriteBatch(userId: userId, occurrences: [o])),
      isA<Ok<void, AppFailure>>(),
    );

    final row = await h.db.select(h.db.occurrences).getSingle();
    expect((row.dirty, row.version), (true, 1));
    expect(row.updatedAt, _now.millisecondsSinceEpoch);
    final log = (await h.changeLog()).where((c) => c.entity == 'occurrences');
    final fields = log.map((c) => c.field).toSet();
    expect(fields, containsAll(['title', 'start_utc', 'duration_min']));
    expect(fields, isNot(contains('id')));
    expect(fields, isNot(contains('updated_at')));
    expect(log.map((c) => c.hlc).toSet(), hasLength(1));
  });

  test('update logs only the changed field; no-op writes nothing', () async {
    final o = occurrenceFixture();
    await write(WriteBatch(userId: userId, occurrences: [o]));
    final before = (await h.changeLog()).length;

    await write(WriteBatch(userId: userId, occurrences: [o]));
    expect((await h.changeLog()).length, before);

    h.clock.advance(const Duration(minutes: 1));
    await write(
      WriteBatch(
        userId: userId,
        occurrences: [o.copyWith(title: 'Moved')],
      ),
    );
    final log = await h.changeLog();
    expect(log.skip(before).map((c) => (c.field, c.value)), [
      ('title', '"Moved"'),
    ]);
    final row = await h.db.select(h.db.occurrences).getSingle();
    expect(row.version, 2);
    expect(Hlc.tryParse(log.last.hlc)! > Hlc.tryParse(log.first.hlc)!, isTrue);
  });

  test('invalid row → ValidationFailure, nothing written', () async {
    final result = await write(
      WriteBatch(
        userId: userId,
        occurrences: [
          occurrenceFixture(),
          occurrenceFixture().copyWith(id: 'bad', durationMin: 1),
        ],
      ),
    );
    expect(
      result.when(ok: (_) => null, err: (f) => f.code),
      'validation.duration.outOfRange',
    );
    expect(await h.db.select(h.db.occurrences).get(), isEmpty);
  });

  test('database error → StorageFailure, whole batch rolled back', () async {
    final orphan = subtaskFixture().copyWith(occurrenceId: 'missing');
    final result = await write(
      WriteBatch(
        userId: userId,
        occurrences: [occurrenceFixture()],
        subtasks: [orphan],
      ),
    );
    expect(result, const Err<void, AppFailure>(StorageFailure()));
    expect(await h.db.select(h.db.occurrences).get(), isEmpty);
    expect((await h.changeLog()).where((c) => c.entity != 'profiles'), isEmpty);
    expect(h.logs.records.map((r) => r.event), contains('write.failed'));
  });

  test('titles are normalised before storage', () async {
    await write(
      WriteBatch(
        userId: userId,
        occurrences: [occurrenceFixture().copyWith(title: '  Dentist  ')],
      ),
    );
    expect((await h.db.select(h.db.occurrences).getSingle()).title, 'Dentist');
  });

  test('rows of another owner are a programming error', () {
    expect(
      () => write(
        WriteBatch(
          userId: userId,
          occurrences: [occurrenceFixture().copyWith(userId: 'other')],
        ),
      ),
      throwsArgumentError,
    );
  });

  test('HLC order survives a restart', () async {
    await write(WriteBatch(userId: userId, occurrences: [occurrenceFixture()]));
    final first = Hlc.tryParse((await h.changeLog()).last.hlc)!;

    // Same database, new process: wall clock went backwards.
    final again = WriteHarness(
      _now.subtract(const Duration(hours: 1)),
      db: h.db,
    );
    await again.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [occurrenceFixture().copyWith(title: 'Later')],
      ),
    );
    await again.effects.idle;
    final second = Hlc.tryParse((await h.changeLog()).last.hlc)!;
    expect(second > first, isTrue);
    expect(second.node, first.node);
  });
}
