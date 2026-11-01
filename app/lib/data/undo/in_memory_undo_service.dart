import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/repositories/calendar_series_repository.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/routine_repository.dart';
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
///
/// Redo (M8.6b) is the same mechanism run backwards: an undo is itself
/// written as a recorded batch, and the rows it overwrote become the one
/// redo entry; a redo is recorded again as a fresh undo token.
final class InMemoryUndoService implements UndoService {
  InMemoryUndoService({
    required WriteUseCase writes,
    required OccurrenceRepository occurrences,
    required SubtaskRepository subtasks,
    required SeriesRepository series,
    required RoutineRepository routines,
    required CalendarSeriesRepository calendarSeries,
    required SettingsRepository settings,
    required Clock clock,
    required IdGenerator ids,
  }) : _writes = writes,
       _settings = settings,
       _occurrences = occurrences,
       _subtasks = subtasks,
       _series = series,
       _routines = routines,
       _calendarSeries = calendarSeries,
       _clock = clock,
       _ids = ids;

  final WriteUseCase _writes;
  final OccurrenceRepository _occurrences;
  final SubtaskRepository _subtasks;
  final SeriesRepository _series;
  final RoutineRepository _routines;
  final CalendarSeriesRepository _calendarSeries;
  final SettingsRepository _settings;
  final Clock _clock;
  final IdGenerator _ids;
  final _pending = <String, _Before>{};
  UndoToken? _latest;
  ({UndoToken token, _Before before})? _redo;

  @override
  UndoToken? get latest {
    final t = _latest;
    if (t == null || !_pending.containsKey(t.id)) return null;
    return _clock.nowUtc().isBefore(t.expiresAtUtc) ? t : null;
  }

  @override
  UndoToken? get redoable {
    final r = _redo;
    if (r == null) return null;
    return _clock.nowUtc().isBefore(r.token.expiresAtUtc) ? r.token : null;
  }

  @override
  Future<Result<UndoToken, AppFailure>> applyUndoable(WriteBatch batch) async {
    final kept = await _keepForUndo(batch);
    // A new change ends the redo chain, as in every editor.
    if (kept is Ok) _redo = null;
    return kept;
  }

  @override
  Future<Result<void, AppFailure>> undo(UndoToken token) async {
    final before = _pending.remove(token.id);
    if (before == null || !_clock.nowUtc().isBefore(before.expiresAtUtc)) {
      return const Err(UndoExpiredFailure());
    }
    final revert = await _restoring(before);
    final (written, after) = await _record(revert);
    if (written case Err(:final failure)) return Err(failure);
    final redo = _token();
    _redo = (token: redo, before: after..expiresAtUtc = redo.expiresAtUtc);
    return const Ok(null);
  }

  @override
  Future<Result<UndoToken, AppFailure>> redo(UndoToken token) async {
    final r = _redo;
    if (r == null || r.token != token || redoable == null) {
      return const Err(UndoExpiredFailure());
    }
    _redo = null;
    return _keepForUndo(await _restoring(r.before));
  }

  /// Writes [batch] and keeps its "before" rows under a new undo token.
  Future<Result<UndoToken, AppFailure>> _keepForUndo(WriteBatch batch) async {
    final (written, before) = await _record(batch);
    if (written case Err(:final failure)) return Err(failure);
    _dropExpired();
    final token = _token();
    _pending[token.id] = before..expiresAtUtc = token.expiresAtUtc;
    _latest = token;
    return Ok(token);
  }

  /// Writes [batch] through the write path, with the rows it changed as
  /// they were just before.
  Future<(Result<void, AppFailure>, _Before)> _record(WriteBatch batch) async {
    final before = await _before(batch);
    return (await _writes.apply(batch), before);
  }

  UndoToken _token() => UndoToken(
    id: _ids.newId(),
    expiresAtUtc: _clock.nowUtc().add(UndoService.window),
  );

  /// The batch that puts [before]'s rows back: changed rows get their
  /// previous version, created rows go to Trash.
  Future<WriteBatch> _restoring(_Before before) async {
    final now = _clock.nowUtc();
    final u = before.userId;
    // Rows the write created for its series (materialised): gone again.
    final created = [
      for (final id in before.series.keys)
        for (final o in await _occurrences.findBySeries(u, id))
          if (!before.occurrences.containsKey(o.id)) o.copyWith(deletedAt: now),
    ];
    return WriteBatch(
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
              (await _occurrences.findById(u, key))?.copyWith(deletedAt: now)),
        ...created,
      ],
      subtasks: [
        for (final MapEntry(:key, :value) in before.subtasks.entries)
          ?(value ??
              (await _subtasks.findById(u, key))?.copyWith(deletedAt: now)),
      ],
      routines: [
        for (final MapEntry(:key, :value) in before.routines.entries)
          ?(value ??
              (await _routines.findById(u, key))?.copyWith(deletedAt: now)),
      ],
      // A series row has no Trash: one the write created goes back to
      // setting nothing, which imports exactly as no row does.
      calendarSeries: [
        for (final MapEntry(:key, :value) in before.calendarSeries.entries)
          ?(value ?? (await _calendarSeries.findById(u, key))?.cleared()),
      ],
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
      {for (final r in batch.routines) r.id: await _routines.findById(u, r.id)},
      {
        for (final s in batch.calendarSeries)
          s.id: await _calendarSeries.findById(u, s.id),
      },
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
    this.routines,
    this.calendarSeries,
  );

  final String userId;
  final Map<String, Occurrence?> occurrences;
  final Map<String, Subtask?> subtasks;
  final Map<String, Series?> series;

  /// The profile as it was, when the batch wrote one.
  final Profile? profile;
  final Map<String, Routine?> routines;
  final Map<String, CalendarSeries?> calendarSeries;
  late DateTime expiresAtUtc;
}
