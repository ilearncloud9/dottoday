import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/recurrence/recurrence_expander.dart';

/// Rows to insert for one series, plus the new high-water mark to store in
/// `series.materialised_through_utc` (docs/05 `series` rules).
final class MaterialisationPlan {
  const MaterialisationPlan({
    required this.occurrences,
    required this.subtasks,
    required this.materialisedThroughUtc,
  });

  final List<Occurrence> occurrences;
  final List<Subtask> subtasks;
  final DateTime materialisedThroughUtc;

  bool get isEmpty => occurrences.isEmpty;
}

/// Turns a series into real occurrence rows 90 days ahead (ADR-0004).
///
/// Idempotent: an instance whose original start already has a row for this
/// series — edited, completed, skipped or soft-deleted — is never created
/// again, so running it on every app open and daily in the background is
/// safe. Each new occurrence gets its own subtasks copied from the
/// template, so ticking one day's checklist never touches another (R-09).
final class Materialiser {
  const Materialiser({
    required Clock clock,
    required IdGenerator ids,
    RecurrenceExpander expander = const RecurrenceExpander(),
  })  : _clock = clock,
        _ids = ids,
        _expander = expander;

  /// How far ahead occurrences exist as rows (docs/05).
  static const horizon = Duration(days: 90);

  // Starts a day back so today's earlier instances appear in every zone.
  static const _lookBack = Duration(days: 1);

  final Clock _clock;
  final IdGenerator _ids;
  final RecurrenceExpander _expander;

  /// Plans the rows missing for [series] in `[now - 1 day, now + 90 days)`.
  ///
  /// [existing] must include every row of this series in that window,
  /// including soft-deleted ones (tombstones act as exceptions). Archived or
  /// deleted series materialise nothing.
  MaterialisationPlan plan(Series series, Iterable<Occurrence> existing) {
    final now = _clock.nowUtc();
    final through = now.add(horizon);
    if (series.archivedAt != null || series.deletedAt != null) {
      return MaterialisationPlan(
        occurrences: const [],
        subtasks: const [],
        materialisedThroughUtc: series.materialisedThroughUtc ?? now,
      );
    }
    final taken = {
      for (final o in existing)
        if (o case Occurrence(:final seriesId, originalStartUtc: final start?)
            when seriesId == series.id)
          start,
    };
    final starts = _expander.expand(
      series,
      fromUtc: now.subtract(_lookBack),
      toUtc: through,
      exceptionsUtc: taken,
    );
    final occurrences = [for (final s in starts) _occurrence(series, s, now)];
    return MaterialisationPlan(
      occurrences: occurrences,
      subtasks: [
        for (final o in occurrences) ..._subtasks(series, o.id, now),
      ],
      materialisedThroughUtc: through,
    );
  }

  Occurrence _occurrence(Series s, DateTime startUtc, DateTime now) {
    return Occurrence(
      id: _ids.newId(),
      userId: s.userId,
      seriesId: s.id,
      originalStartUtc: startUtc,
      title: s.title,
      notes: s.notes,
      colorKey: s.colorKey,
      iconKey: s.iconKey,
      startUtc: startUtc,
      tzId: s.tzId,
      durationMin: s.durationMin,
      pinned: s.pinned,
      travelBufferMin: s.travelBufferMin,
      energy: s.energy,
      // null = inherit the series alerts (docs/05 `occurrences.alerts`).
      createdAt: now,
      updatedAt: now,
    );
  }

  Iterable<Subtask> _subtasks(Series s, String occurrenceId, DateTime now) {
    return s.subtaskTemplate.map(
      (item) => Subtask(
        id: _ids.newId(),
        userId: s.userId,
        occurrenceId: occurrenceId,
        title: item.title,
        sortOrder: item.sortOrder,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
