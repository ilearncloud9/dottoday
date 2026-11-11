import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/repositories/drift_calendar_series_repository.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_reveal_hint_repository.dart';
import 'package:dottoday/data/repositories/drift_routine_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/sync/guest_sessions.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/entity_writers.dart';
import 'package:dottoday/data/writes/foreign_rows.dart';
import 'package:dottoday/data/writes/row_writer.dart';
import 'package:dottoday/data/writes/validate_batch.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';

/// [WriteUseCase] over the local Drift database (docs/04 §4).
final class DriftWriteUseCase implements WriteUseCase {
  DriftWriteUseCase({
    required AppDatabase db,
    required Clock clock,
    required Materialiser materialiser,
    required AfterWriteEffects effects,
    required Logger logger,
    SharedHlc? hlc,
  }) : _db = db,
       _clock = clock,
       _materialiser = materialiser,
       _effects = effects,
       _logger = logger,
       _hlc = hlc ?? SharedHlc(db, clock),
       _occurrences = DriftOccurrenceRepository(db),
       _series = DriftSeriesRepository(db),
       _subtasks = DriftSubtaskRepository(db),
       _routines = DriftRoutineRepository(db),
       _hints = DriftRevealHintRepository(db),
       _calendarSeries = DriftCalendarSeriesRepository(db),
       _profiles = DriftSettingsRepository(db);

  final AppDatabase _db;
  final Clock _clock;
  final Materialiser _materialiser;
  final AfterWriteEffects _effects;

  /// The effects [apply] schedules after a write; a caller of
  /// [applyWithoutEffects] schedules them once after its own transaction
  /// (the staged import, CR-160 B3/B5).
  AfterWriteEffects get effects => _effects;
  final Logger _logger;
  final SharedHlc _hlc;
  final DriftOccurrenceRepository _occurrences;
  final DriftSeriesRepository _series;
  final DriftSubtaskRepository _subtasks;
  final DriftRoutineRepository _routines;
  final DriftRevealHintRepository _hints;
  final DriftCalendarSeriesRepository _calendarSeries;
  final DriftSettingsRepository _profiles;

  @override
  Future<Result<void, AppFailure>> apply(WriteBatch batch) async {
    final result = await applyWithoutEffects(batch);
    if (result is Ok) _effects.schedule(batch.userId);
    return result;
  }

  /// [apply] without the after-write effects: the same validation, seal,
  /// shown-owner and Finding X checks, in its own savepoint when the caller
  /// holds a transaction. For a caller that writes several batches in one
  /// transaction (the staged import's commit, CR-160 Stage B3): effects
  /// scheduled inside it would run inside that transaction, so the caller
  /// schedules them once ([AfterWriteEffects.schedule]) after it commits.
  Future<Result<void, AppFailure>> applyWithoutEffects(WriteBatch batch) async {
    if (!batch.isSingleOwner) {
      throw ArgumentError.value(batch.userId, 'batch', 'mixes row owners');
    }
    if (batch.isEmpty) return const Ok(null);
    final WriteBatch valid;
    switch (validateBatch(batch)) {
      case Ok(:final value):
        valid = value;
      case Err(:final failure):
        return Err(failure);
    }
    try {
      await _db.transaction(() => _write(valid));
    } on _NotShown {
      _logger.warn('write.owner_not_shown');
      return const Err(StorageFailure());
    } on ForeignRowException {
      // A row of another account on this device: never taken over
      // (CR-160 Finding X). Rolled back whole.
      _logger.warn('write.foreign_row');
      return const Err(ForeignRowsFailure());
    } on OwnerSealedException {
      // The owner's account is being deleted (CR-160 policy §4): refused,
      // shown as the generic "couldn't save".
      _logger.warn('write.owner_sealed');
      return const Err(StorageFailure());
    } on Exception catch (e, st) {
      _logger.error('write.failed', error: e, stackTrace: st);
      return const Err(StorageFailure());
    }
    return const Ok(null);
  }

  Future<void> _write(WriteBatch b) async {
    // In this transaction, so a deletion sealed after it can't miss it and
    // one sealed before it refuses it (deletion_seal.dart).
    await checkNotSealed(_db, b.userId);
    if (b.onlyWhileShown && (await shownOwnerId(_db)) != b.userId) {
      throw const _NotShown();
    }
    final hlc = await _hlc.clock();
    final now = _clock.nowUtc();
    final session = await guestSessionFor(_db, b.userId);
    var wrote = false;
    Future<void> rows<E>(EntityWriter<E> writer, Iterable<E> items) async {
      final written = await writeRows(
        _db,
        writer,
        items,
        owner: b.userId,
        now: now,
        nextHlc: hlc.now,
        guestSession: session,
      );
      wrote = wrote || written;
    }

    final profile = b.profile;
    if (profile != null) await rows(profileWriter(_profiles), [profile]);
    final m = await _materialise(b);
    await rows(seriesWriter(b.userId, _series), m.series);
    await rows(occurrenceWriter(b.userId, _occurrences), [
      ...b.occurrences,
      ...m.occurrences,
    ]);
    await rows(subtaskWriter(b.userId, _subtasks, _occurrences), [
      ...b.subtasks,
      ...m.subtasks,
    ]);
    await rows(routineWriter(b.userId, _routines), b.routines);
    await rows(revealHintWriter(b.userId, _hints), b.revealHints);
    await rows(
      calendarSeriesWriter(b.userId, _calendarSeries),
      b.calendarSeries,
    );
    // Only a save that changed something moves the revision D1 compares.
    if (wrote) await bumpWriteRevision(_db, b.userId);
    await _hlc.save();
  }

  /// Plans missing occurrences for every saved series. Rows of the series in
  /// this batch count as existing, so an edited instance isn't duplicated.
  Future<_Materialised> _materialise(WriteBatch b) async {
    final out = _Materialised();
    for (final s in b.series) {
      final existing = {
        for (final o in await _occurrences.findBySeries(b.userId, s.id))
          o.id: o,
        for (final o in b.occurrences)
          if (o.seriesId == s.id) o.id: o,
      };
      final plan = _materialiser.plan(s, existing.values);
      out.series.add(
        s.copyWith(materialisedThroughUtc: plan.materialisedThroughUtc),
      );
      out.occurrences.addAll(plan.occurrences);
      out.subtasks.addAll(plan.subtasks);
    }
    return out;
  }
}

final class _Materialised {
  final series = <Series>[];
  final occurrences = <Occurrence>[];
  final subtasks = <Subtask>[];
}

/// The batch's owner stopped being shown before it could commit.
final class _NotShown implements Exception {
  const _NotShown();
}
