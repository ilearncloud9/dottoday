import 'package:dottoday/data/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = '0192f0a0-0000-7000-8000-000000000001';
const _now = 1760000000000;

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customInsert(
      'INSERT INTO profiles (id, created_at, updated_at) VALUES (?, ?, ?)',
      variables: [
        const Variable(_user),
        const Variable(_now),
        const Variable(_now),
      ],
    );
  });
  tearDown(() => db.close());

  Future<void> insertOccurrence(String id, Map<String, Object?> extra) {
    final cols = <String, Object?>{
      'id': id,
      'user_id': _user,
      'title': 'T',
      'tz_id': 'UTC',
      'duration_min': 30,
      'created_at': _now,
      'updated_at': _now,
      ...extra,
    };
    return db.customInsert(
      'INSERT INTO occurrences (${cols.keys.join(', ')}) '
      'VALUES (${List.filled(cols.length, '?').join(', ')})',
      variables: [for (final v in cols.values) Variable(v)],
    );
  }

  test('every table is STRICT', () async {
    final rows = await db
        .customSelect(
          "SELECT name, strict FROM pragma_table_list WHERE schema = 'main' "
          "AND type = 'table' AND name NOT LIKE 'sqlite_%' "
          // FTS5 virtual table and its shadow tables can't be STRICT.
          "AND name NOT LIKE 'search_index%'",
        )
        .get();
    expect(rows.map((r) => r.read<String>('name')).toSet(), {
      'profiles',
      'series',
      'calendar_accounts',
      'calendar_links',
      'occurrences',
      'subtasks',
      'routines',
      'reveal_hints',
      'conflicts',
      'change_log',
      'field_seen',
      'sync_cursors',
      'local_meta',
    });
    expect(rows.every((r) => r.read<int>('strict') == 1), isTrue);
  });

  test('foreign keys are enforced on open', () async {
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data.values.single, 1);
    await expectLater(
      insertOccurrence('o1', {'user_id': 'nobody'}),
      throwsA(isA<SqliteException>()),
    );
  });

  test('CHECKs mirror the server rules', () async {
    for (final bad in <Map<String, Object?>>[
      {'status': 'archived'},
      {'source': 'email'},
      {'duration_min': 4},
      {'title': '   '},
      {'alerts': 'not json'},
      {'energy': 4},
    ]) {
      await expectLater(
        insertOccurrence('bad', bad),
        throwsA(isA<SqliteException>()),
        reason: '$bad',
      );
    }
  });

  test('series instances need original_start_utc and are unique', () async {
    await db.customInsert(
      'INSERT INTO series (id, user_id, title, duration_min, rrule, '
      "dtstart_local, tz_id, created_at, updated_at) VALUES ('s1', ?, 'S', "
      "30, 'FREQ=DAILY', '2026-10-21T09:00:00', 'UTC', ?, ?)",
      variables: [
        const Variable(_user),
        const Variable(_now),
        const Variable(_now),
      ],
    );
    await expectLater(
      insertOccurrence('o0', {'series_id': 's1'}),
      throwsA(isA<SqliteException>()),
    );
    await insertOccurrence('o1', {'series_id': 's1', 'original_start_utc': 1});
    await expectLater(
      insertOccurrence('o2', {'series_id': 's1', 'original_start_utc': 1}),
      throwsA(isA<SqliteException>()),
    );
  });

  test('re-owning the profile cascades to user_id (M6.4)', () async {
    await insertOccurrence('o1', {});
    await db.customStatement(
      'INSERT INTO routines (id, user_id, title, created_at, updated_at) '
      "VALUES ('r1', '$_user', 'Morning', 0, 0)",
    );
    await db.customStatement(
      "UPDATE profiles SET id = 'server-user' WHERE id = '$_user'",
    );
    final row = await db.select(db.occurrences).getSingle();
    expect(row.userId, 'server-user');
    final routine = await db.select(db.routinesTable).getSingle();
    expect(routine.userId, 'server-user');
  });

  test('docs/05 indexes exist', () async {
    final names =
        (await db
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'index' "
                  "AND name NOT LIKE 'sqlite_%'",
                )
                .get())
            .map((r) => r.read<String>('name'))
            .toSet();
    expect(
      names,
      containsAll(<String>[
        'occurrences_user_start',
        'occurrences_series_original',
        'occurrences_user_deleted',
        'occurrences_user_updated',
        'subtasks_occurrence',
        'series_user',
        'calendar_links_user_event',
        'routines_user',
        'routines_user_updated',
      ]),
    );
  });

  test('day query uses occurrences_user_start', () async {
    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN SELECT * FROM occurrences '
          'WHERE user_id = ? AND start_utc >= ? AND start_utc < ?',
          variables: [
            const Variable(_user),
            const Variable(0),
            const Variable(1),
          ],
        )
        .get();
    expect(
      plan.map((r) => r.read<String>('detail')).join(),
      contains('occurrences_user_start'),
    );
  });

  test('reveal_hints: one row per hint, known ids, twice ever (M16)', () async {
    Future<void> insert(String id, String hint, {int shown = 0}) =>
        db.customInsert(
          'INSERT INTO reveal_hints (id, user_id, hint_id, shown_count, '
          'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
          variables: [
            Variable(id),
            const Variable(_user),
            Variable(hint),
            Variable(shown),
            const Variable(_now),
            const Variable(_now),
          ],
        );
    await insert('h1', 'unstick', shown: 2);
    await expectLater(insert('h2', 'unstick'), throwsA(anything));
    await expectLater(insert('h3', 'streaks'), throwsA(anything));
    await expectLater(insert('h4', 'routines', shown: 3), throwsA(anything));
  });
}
