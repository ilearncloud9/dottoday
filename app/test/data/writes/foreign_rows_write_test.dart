import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/writes/foreign_rows.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/calendar_template_fixtures.dart';
import 'write_harness.dart';

// CR-160 Finding X at the write path itself: whatever calls it (an edit, an
// import, a restore, a future staged import), a batch naming a row id that
// another owner on this device holds is refused whole, and that owner's row
// keeps its owner and content. Checked against the row's actual owner, not
// an owner-filtered lookup.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';
const _accountA = '01928c3e-0000-7000-8000-0000000004a1';
const _accountB = '01928c3e-0000-7000-8000-0000000004b1';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late WriteHarness h;
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 11, 10, 6));
    for (final owner in [_a, _b]) {
      await h.writes.apply(
        WriteBatch(
          userId: owner,
          profile: profileFixture().copyWith(id: owner),
        ),
      );
    }
    for (final (id, owner) in [(_accountA, _a), (_accountB, _b)]) {
      await h.db.customStatement(
        'INSERT INTO calendar_accounts (id, user_id, provider, label, '
        'external_account_id, created_at, updated_at) VALUES (?, ?, '
        "'apple_device', 'Work', 'work', 0, 0)",
        [id, owner],
      );
    }
  });
  tearDown(() => h.dispose());

  final task = occurrenceFixture().copyWith(
    id: '01928c3e-0000-7000-8000-0000000004c1',
    seriesId: null,
  );

  /// A's row of each table, and B's batch naming the same id.
  final cases = <String, (WriteBatch, WriteBatch)>{
    'series': (
      WriteBatch(
        userId: _a,
        series: [
          seriesFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000004d1',
            userId: _a,
          ),
        ],
      ),
      WriteBatch(
        userId: _b,
        series: [
          seriesFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000004d1',
            userId: _b,
            title: 'Taken',
          ),
        ],
      ),
    ),
    'occurrences': (
      WriteBatch(
        userId: _a,
        occurrences: [task.copyWith(userId: _a)],
      ),
      WriteBatch(
        userId: _b,
        occurrences: [task.copyWith(userId: _b, title: 'Taken')],
      ),
    ),
    'subtasks': (
      WriteBatch(
        userId: _a,
        occurrences: [task.copyWith(userId: _a)],
        subtasks: [
          subtaskFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000004e1',
            userId: _a,
            occurrenceId: task.id,
          ),
        ],
      ),
      WriteBatch(
        userId: _b,
        occurrences: [
          task.copyWith(id: '01928c3e-0000-7000-8000-0000000004c2', userId: _b),
        ],
        subtasks: [
          subtaskFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000004e1',
            userId: _b,
            occurrenceId: '01928c3e-0000-7000-8000-0000000004c2',
            title: 'Taken',
          ),
        ],
      ),
    ),
    'routines': (
      WriteBatch(
        userId: _a,
        routines: [
          routineFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000004f1',
            userId: _a,
          ),
        ],
      ),
      WriteBatch(
        userId: _b,
        routines: [
          routineFixture().copyWith(
            id: '01928c3e-0000-7000-8000-0000000004f1',
            userId: _b,
          ),
        ],
      ),
    ),
    'reveal_hints': (
      WriteBatch(
        userId: _a,
        revealHints: [revealHintFixture(_a, HintId.unstick)],
      ),
      WriteBatch(
        userId: _b,
        revealHints: [
          revealHintFixture(
            _b,
            HintId.unstick,
          ).copyWith(id: revealHintFixture(_a, HintId.unstick).id),
        ],
      ),
    ),
    'calendar_series': (
      WriteBatch(
        userId: _a,
        calendarSeries: [
          fullSeries(id: 'cs-1', userId: _a, accountId: _accountA),
        ],
      ),
      WriteBatch(
        userId: _b,
        calendarSeries: [
          fullSeries(id: 'cs-1', userId: _b, accountId: _accountB),
        ],
      ),
    ),
  };

  Future<String?> ownerOf(String table, String id) async =>
      (await h.db
              .customSelect(
                'SELECT user_id FROM $table WHERE id = ?',
                variables: [Variable<String>(id)],
              )
              .getSingleOrNull())
          ?.read<String>('user_id');

  for (final MapEntry(key: table, value: (mine, theirs)) in cases.entries) {
    test(
      "$table: B's write naming A's id is refused, A's row unchanged",
      () async {
        expect(await h.writes.apply(mine), isA<Ok<void, AppFailure>>());
        final id = await h.db
            .customSelect(
              'SELECT id FROM $table WHERE user_id = ?',
              variables: [const Variable<String>(_a)],
            )
            .getSingle()
            .then((r) => r.read<String>('id'));
        final before = await h.db
            .customSelect(
              'SELECT * FROM $table WHERE id = ?',
              variables: [Variable<String>(id)],
            )
            .getSingle();
        final revision = await writeRevision(h.db, _b);
        final logged = await h.changeLog();

        expect(
          await h.writes.apply(theirs),
          isA<Err<void, AppFailure>>().having(
            (e) => e.failure,
            'failure',
            isA<ForeignRowsFailure>(),
          ),
        );
        expect(await ownerOf(table, id), _a);
        final after = await h.db
            .customSelect(
              'SELECT * FROM $table WHERE id = ?',
              variables: [Variable<String>(id)],
            )
            .getSingle();
        expect(after.data, before.data, reason: 'content untouched too');
        expect(await writeRevision(h.db, _b), revision, reason: 'rolled back');
        expect(await h.changeLog(), logged, reason: 'nothing queued');
      },
    );
  }

  test('a batch with one foreign row writes none of its own rows', () async {
    await h.writes.apply(
      WriteBatch(
        userId: _a,
        occurrences: [task.copyWith(userId: _a)],
      ),
    );
    final mine = task.copyWith(
      id: '01928c3e-0000-7000-8000-0000000004c9',
      userId: _b,
    );
    final result = await h.writes.apply(
      WriteBatch(
        userId: _b,
        occurrences: [
          mine,
          task.copyWith(userId: _b),
        ],
      ),
    );
    expect(result, isA<Err<void, AppFailure>>());
    expect(await ownerOf('occurrences', mine.id), isNull);
  });

  test('checkNoForeignRows reads the real owner, in chunks', () async {
    await h.writes.apply(
      WriteBatch(
        userId: _a,
        occurrences: [task.copyWith(userId: _a)],
      ),
    );
    final many = [for (var i = 0; i < 1200; i++) 'free-$i', task.id];
    await expectLater(
      checkNoForeignRows(h.db, 'occurrences', _b, many),
      throwsA(isA<ForeignRowException>()),
    );
    await checkNoForeignRows(h.db, 'occurrences', _a, many);
    await expectLater(
      checkNoForeignRows(h.db, 'profiles', _b, [_a]),
      throwsA(isA<ForeignRowException>()),
    );
  });
}
