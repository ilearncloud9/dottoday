import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
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
import 'package:dottoday/domain/writes/write_use_case.dart';

/// [UndoService] keeping each token's "before" rows in memory.
///
/// A batch that saves series (repeat edits, M3f.1) also remembers every
/// occurrence those series had: saving a series materialises rows the
/// batch didn't list, and Undo must take those away too (docs/09 M4.9 —
/// found on a device). A batch's profile (the travel banner, M5.9) is
/// put back as it was too.
final class InMemoryUndoService implements UndoService {
  InMemoryUndoService({
    required WriteUseCase writes,
    required OccurrenceRepository occurrences,
    required SubtaskRepository subtasks,
    required SeriesRepository series,
    required SettingsRepository settings,
    required Clock clock,
    required IdGenerator ids,
  }) : _writes = writes,
       _settings = settings,
       _occurrences = occurrences,
       _subtasks = subtasks,
       _series = series,
       _clock = clock,
       _ids = ids;

  final WriteUseCase _writes;
  final OccurrenceRepository _occurrences;
  final SubtaskRepository _subtasks;
  final SeriesRepository _series;
  final SettingsRepository _settings;
  final Clock _clock;
  final IdGenerator _ids;
  final _pending = <String, _Before>{};
  UndoToken? _latest;

  @override
  UndoToken? get latest {
    final t = _latest;
    if (t == null || !_pending.containsKey(t.id)) return null;
    return _clock.nowUtc().isBefore(t.expiresAtUtc) ? t : null;
  }

  @override
  Future<Result<UndoToken, AppFailure>> applyUndoable(WriteBatch batch) async {
    final before = await _before(batch);
    final written = await _writes.apply(batch);
    if (written case Err(:final failure)) return Err(failure);
    _dropExpired();
    final token = UndoToken(
      id: _ids.newId(),
      expiresAtUtc: _clock.nowUtc().add(UndoService.window),
    );
    _pending[token.id] = before..expiresAtUtc = token.expiresAtUtc;
    _latest = token;
    return Ok(token);
  }

  @override
  Future<Result<void, AppFailure>> undo(UndoToken token) async {
    final before = _pending.remove(token.id);
    final now = _clock.nowUtc();
    if (before == null || !now.isBefore(before.expiresAtUtc)) {
      return const Err(UndoExpiredFailure());
    }
    final u = before.userId;
    // Rows the write created for its series (materialised): gone again.
    final created = [
      for (final id in before.series.keys)
        for (final o in await _occurrences.findBySeries(u, id))
          if (!before.occurrences.containsKey(o.id)) o.copyWith(deletedAt: now),
    ];
    return _writes.apply(
      WriteBatch(
        userId: u,
        profile: before.profile,
        series: [
          for (final MapEntry(:key, :value) in before.series.entries)
            ?(value ??
                (await _series.findById(u, key))?.copyWith(deletedAt: now)),
        ],
        occurrences: [
          for (final MapEntry(:key, :value) in before.occurrences.entries)
            ?(value ??
                (await _occurrences.findById(
                  u,
                  key,
                ))?.copyWith(deletedAt: now)),
          ...created,
        ],
        subtasks: [
          for (final MapEntry(:key, :value) in before.subtasks.entries)
            ?(value ??
                (await _subtasks.findById(u, key))?.copyWith(deletedAt: now)),
        ],
      ),
    );
  }

  /// The rows [batch] will change, as they are now (null = new).
  Future<_Before> _before(WriteBatch batch) async {
    final u = batch.userId;
    final occurrences = <String, Occurrence?>{
      for (final o in batch.occurrences)
        o.id: await _occurrences.findById(u, o.id),
    };
    final series = <String, Series?>{};
    for (final s in batch.series) {
      series[s.id] = await _series.findById(u, s.id);
      for (final o in await _occurrences.findBySeries(u, s.id)) {
        occurrences.putIfAbsent(o.id, () => o);
      }
    }
    return _Before(
      u,
      occurrences,
      {for (final s in batch.subtasks) s.id: await _subtasks.findById(u, s.id)},
      series,
      batch.profile == null ? null : await _settings.findLocalProfile(),
    );
  }

  void _dropExpired() {
    final now = _clock.nowUtc();
    _pending.removeWhere((_, b) => !now.isBefore(b.expiresAtUtc));
  }
}

/// Rows as they were before an undoable write; null = created by it.
final class _Before {
  _Before(
    this.userId,
    this.occurrences,
    this.subtasks,
    this.series,
    this.profile,
  );

  final String userId;
  final Map<String, Occurrence?> occurrences;
  final Map<String, Subtask?> subtasks;
  final Map<String, Series?> series;

  /// The profile as it was, when the batch wrote one.
  final Profile? profile;
  late DateTime expiresAtUtc;
}
