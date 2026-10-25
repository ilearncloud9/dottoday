import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/entity_writers.dart';
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
       _profiles = DriftSettingsRepository(db);

  final AppDatabase _db;
  final Clock _clock;
  final Materialiser _materialiser;
  final AfterWriteEffects _effects;
  final Logger _logger;
  final SharedHlc _hlc;
  final DriftOccurrenceRepository _occurrences;
  final DriftSeriesRepository _series;
  final DriftSubtaskRepository _subtasks;
  final DriftSettingsRepository _profiles;

  @override
  Future<Result<void, AppFailure>> apply(WriteBatch batch) async {
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
    } on Exception catch (e, st) {
      _logger.error('write.failed', error: e, stackTrace: st);
      return const Err(StorageFailure());
    }
    _effects.schedule(batch.userId);
    return const Ok(null);
  }

  Future<void> _write(WriteBatch b) async {
    final hlc = await _hlc.clock();
    final now = _clock.nowUtc();
    Future<void> rows<E>(EntityWriter<E> writer, Iterable<E> items) =>
        writeRows(_db, writer, items, now: now, nextHlc: hlc.now);

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
