import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/owner_app.dart';
import '../../support/shared_action_queue.dart';
import '../../support/timeline_fakes.dart';
import '../writes/write_harness.dart';

// CR-160 Finding X: an import or a backup restore re-owns every row in the
// file to the importing owner. A row id another local owner already holds
// must never change hands: the whole import or restore is refused before
// any live change, and every owner's rows stay as they were.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';

/// One row of every exported table, owned by [owner].
({Series series, Occurrence task, Subtask step, Routine routine}) _rows(
  String owner,
) {
  final task = occurrenceFixture().copyWith(
    id: '01928c3e-0000-7000-8000-0000000003a1',
    userId: owner,
    seriesId: null,
    title: 'Mine',
  );
  return (
    series: seriesFixture().copyWith(
      id: '01928c3e-0000-7000-8000-0000000003b1',
      userId: owner,
    ),
    task: task,
    step: subtaskFixture().copyWith(
      id: '01928c3e-0000-7000-8000-0000000003c1',
      userId: owner,
      occurrenceId: task.id,
    ),
    routine: routineFixture().copyWith(
      id: '01928c3e-0000-7000-8000-0000000003d1',
      userId: owner,
    ),
  );
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late AppDatabase db;
  late OwnerApp app;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    app = OwnerApp(
      db,
      FakeNotificationPlatform(),
      FakeSink(),
      FakeAlarmGateway(),
      SharedActionQueue(),
    );
  });
  tearDown(() async {
    await app.idle();
    app.container.dispose();
    await db.close();
  });

  BackupService backups() => app.container.read(backupServiceProvider);

  Future<void> write(String owner) async {
    final r = _rows(owner);
    final result = await app.container
        .read(writeUseCaseProvider)
        .apply(
          WriteBatch(
            userId: owner,
            series: [r.series],
            occurrences: [r.task],
            subtasks: [r.step],
            routines: [r.routine],
          ),
        );
    expect(result, isA<Ok<void, AppFailure>>());
    await app.idle();
  }

  /// Who holds each of the four ids now, by table.
  Future<Map<String, String?>> holders() async {
    final r = _rows(_a);
    Future<String?> owner(String table, String id) async =>
        (await db
                .customSelect(
                  'SELECT user_id FROM $table WHERE id = ?',
                  variables: [Variable<String>(id)],
                )
                .getSingleOrNull())
            ?.read<String>('user_id');
    return {
      'series': await owner('series', r.series.id),
      'occurrences': await owner('occurrences', r.task.id),
      'subtasks': await owner('subtasks', r.step.id),
      'routines': await owner('routines', r.routine.id),
    };
  }

  Future<String> fileOf(String owner) async => encodeExportJson(
    (await db.transaction(() => readUserData(db, owner, ownerAppNow)))!,
  );

  test("B imports A's file while A's copy is here: refused, A's rows stay "
      "A's, and A's next pull isn't blocked", () async {
    await app.shown();
    await app.signIn(_a);
    await write(_a);
    final file = await fileOf(_a);
    await app.owners.signOut();
    await app.signIn(_b);

    final before = await backups().list();
    final result = await backups().importJson(_b, file);
    expect(
      (await backups().list()).length,
      before.length,
      reason: 'refused before its safety backup',
    );

    expect(await holders(), {
      'series': _a,
      'occurrences': _a,
      'subtasks': _a,
      'routines': _a,
    });
    expect(result, isA<Err<void, AppFailure>>());
    // A → B → A: A's rows pulled again are A's own, not "another owner's".
    await app.signIn(_a);
    await db.transaction(
      () => checkPulledRow(db, 'occurrences', _a, {
        'id': _rows(_a).task.id,
        'user_id': _a,
      }),
    );
  });

  test('an old guest backup cannot reclaim rows promoted into A', () async {
    final guest = await app.shown();
    await write(guest);
    expect(
      await backups().create(guest, BackupReason.daily),
      isA<Ok<BackupInfo, AppFailure>>(),
    );
    expect(await app.signInAs(_a), OwnerChange.guestChoiceNeeded);
    await recordGuestChoice(db, _a, GuestChoice.bringIn);
    await app.signInAs(_a);
    expect((await holders()).values.toSet(), {_a}, reason: 'promoted');

    await app.owners.signOut();
    expect(await app.shown(), guest, reason: 'the same guest profile');
    final old = (await backups().list()).single;
    final result = await backups().restore(guest, old.id);
    expect((await backups().list()).map((b) => b.id), [
      old.id,
    ], reason: 'refused before its safety backup');

    expect(await holders(), {
      'series': _a,
      'occurrences': _a,
      'subtasks': _a,
      'routines': _a,
    });
    expect(result, isA<Err<void, AppFailure>>());
  });

  test("a guest backup taken after the promotion holds none of A's rows "
      'and still restores (legitimate guest recovery kept)', () async {
    final guest = await app.shown();
    await write(guest);
    expect(await app.signInAs(_a), OwnerChange.guestChoiceNeeded);
    await recordGuestChoice(db, _a, GuestChoice.bringIn);
    await app.signInAs(_a);
    await app.owners.signOut();
    expect(await app.shown(), guest);
    final note = occurrenceFixture().copyWith(
      id: '01928c3e-0000-7000-8000-0000000003a9',
      userId: guest,
      title: 'Guest after',
    );
    await app.container
        .read(writeUseCaseProvider)
        .apply(WriteBatch(userId: guest, occurrences: [note]));
    final after = (await backups().create(
      guest,
      BackupReason.daily,
    )).when(ok: (b) => b.id, err: (f) => fail(f.code));
    expect(await backups().restore(guest, after), isA<Ok<void, AppFailure>>());
    expect((await holders()).values.toSet(), {_a}, reason: "A's untouched");
  });
}
