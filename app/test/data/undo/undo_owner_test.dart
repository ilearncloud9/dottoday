import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/repositories/drift_calendar_series_repository.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_routine_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/undo/in_memory_undo_service.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_ids.dart';
import '../../support/shown_owner.dart';
import '../writes/write_harness.dart';

T _ok<T>(Result<T, AppFailure> r) =>
    r.when(ok: (v) => v, err: (f) => fail('unexpected ${f.code}'));

// An undo or redo recorded for one owner does nothing once another owner
// is shown (CR-160 I5): it would write, and queue, the previous owner's
// rows into the next one's session.

void main() {
  late WriteHarness h;
  late DriftOccurrenceRepository occurrences;
  final task = occurrenceFixture();

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    occurrences = DriftOccurrenceRepository(h.db);
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [task],
      ),
    );
    await addProfile(h.db, ownerB);
    await showOwner(h.db, userId);
  });
  tearDown(() => h.dispose());

  InMemoryUndoService service() => InMemoryUndoService(
    writes: h.writes,
    occurrences: occurrences,
    subtasks: DriftSubtaskRepository(h.db),
    series: DriftSeriesRepository(h.db),
    routines: DriftRoutineRepository(h.db),
    calendarSeries: DriftCalendarSeriesRepository(h.db),
    settings: DriftSettingsRepository(h.db),
    clock: h.clock,
    ids: FakeIds('undo'),
  );

  WriteBatch move() => WriteBatch(
    userId: userId,
    occurrences: [task.copyWith(startUtc: t1)],
  );

  Future<DateTime?> startOf() async =>
      (await occurrences.findById(userId, task.id))!.startUtc;

  Future<int> queued() async => (await h.changeLog()).length;

  test('a stale undo token does nothing after a switch', () async {
    final undo = service();
    final token = _ok(await undo.applyUndoable(move()));
    await showOwner(h.db, ownerB);
    final before = await queued();
    expect(await undo.undo(token), isA<Err<void, AppFailure>>());
    expect(await startOf(), t1, reason: 'the move stays');
    expect(await queued(), before, reason: 'nothing queued');
    // Back to the owner: the token was spent, so still nothing.
    await showOwner(h.db, userId);
    expect(await undo.undo(token), isA<Err<void, AppFailure>>());
  });

  test('a stale redo token does nothing after a switch', () async {
    final undo = service();
    _ok(await undo.applyUndoable(move()));
    _ok(await undo.undo(undo.latest!));
    final redo = undo.redoable!;
    await showOwner(h.db, ownerB);
    expect(await undo.redo(redo), isA<Err<UndoToken, AppFailure>>());
    expect(await startOf(), t0);
  });

  test('the same owner still undoes', () async {
    final undo = service();
    final token = _ok(await undo.applyUndoable(move()));
    _ok(await undo.undo(token));
    expect(await startOf(), t0);
  });

  test('the provider is empty after a switch; the old one forgets', () async {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(h.db),
        writeUseCaseProvider.overrideWithValue(h.writes),
        clockProvider.overrideWithValue(h.clock),
      ],
    );
    addTearDown(c.dispose);
    final old = c.read(undoServiceProvider);
    final token = _ok(await old.applyUndoable(move()));
    expect(c.read(undoServiceProvider).latest, token);
    await showOwner(h.db, ownerB);
    c.read(ownerEpochProvider.notifier).next();
    final now = c.read(undoServiceProvider);
    expect(identical(now, old), isFalse);
    expect((now.latest, now.redoable), (null, null));
    expect(old.latest, isNull, reason: 'a stale holder sees nothing');
    expect(await now.undo(token), isA<Err<void, AppFailure>>());
    expect(await old.undo(token), isA<Err<void, AppFailure>>());
    expect(await startOf(), t1);
  });
}
