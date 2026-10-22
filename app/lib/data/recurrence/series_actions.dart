import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

// Scoped writes for repeating tasks (docs/09 M3f.1, R-01): each is one
// batch, so one Undo puts the series and its rows back.

SeriesEditor _editor(ProviderContainer ref, IdGenerator ids) =>
    SeriesEditor(clock: ref.read(clockProvider), ids: ids);

Future<List<Occurrence>> _rows(ProviderContainer ref, Series s) =>
    ref.read(occurrenceRepositoryProvider).findBySeries(s.userId, s.id);

Future<Result<UndoToken, AppFailure>> _write(
  ProviderContainer ref,
  String userId,
  SeriesWrite w,
) => ref
    .read(undoServiceProvider)
    .applyUndoable(
      WriteBatch(userId: userId, series: w.series, occurrences: w.occurrences),
    );

/// [change] to [target] (an instance of [series]) by [scope].
Future<Result<UndoToken, AppFailure>> editSeries(
  ProviderContainer ref, {
  required Series series,
  required Occurrence target,
  required SeriesChange change,
  required EditScope scope,
  IdGenerator ids = const UuidV7Generator(),
}) async {
  final w = _editor(ref, ids).edit(
    series: series,
    rows: await _rows(ref, series),
    target: target,
    change: change,
    scope: scope,
  );
  return _write(ref, series.userId, w);
}

/// Deletes [target] (an instance of [series]) by [scope].
Future<Result<UndoToken, AppFailure>> deleteSeries(
  ProviderContainer ref, {
  required Series series,
  required Occurrence target,
  required EditScope scope,
  IdGenerator ids = const UuidV7Generator(),
}) async {
  final w = _editor(ref, ids).delete(
    series: series,
    rows: await _rows(ref, series),
    target: target,
    scope: scope,
  );
  return _write(ref, series.userId, w);
}

/// A one-off [o] starts repeating by [rule]: a new series from it, with
/// [o] as its first instance (the rest are materialised on save).
Future<Result<UndoToken, AppFailure>> startRepeating(
  ProviderContainer ref, {
  required Occurrence o,
  required RepeatRule rule,
  IdGenerator ids = const UuidV7Generator(),
}) {
  final now = ref.read(clockProvider).nowUtc();
  final series = _seriesFrom(o, rule, ids.newId(), now);
  final first = o.copyWith(
    seriesId: series.id,
    originalStartUtc: o.startUtc,
    updatedAt: now,
  );
  return _write(ref, o.userId, (series: [series], occurrences: [first]));
}

/// "Never" on a repeating task: it ends after [target], which stays.
Future<Result<UndoToken, AppFailure>> stopRepeating(
  ProviderContainer ref, {
  required Series series,
  required Occurrence target,
  IdGenerator ids = const UuidV7Generator(),
}) async {
  final rows = await _rows(ref, series);
  final key = target.originalStartUtc ?? target.startUtc!;
  final later =
      rows
          .where((o) => (o.originalStartUtc ?? o.startUtc!).isAfter(key))
          .toList()
        ..sort(
          (a, b) => (a.originalStartUtc ?? a.startUtc!).compareTo(
            b.originalStartUtc ?? b.startUtc!,
          ),
        );
  final now = ref.read(clockProvider).nowUtc();
  final w = later.isEmpty
      ? (
          series: [series.copyWith(untilUtc: key, count: null, updatedAt: now)],
          occurrences: <Occurrence>[],
        )
      : _editor(ref, ids).delete(
          series: series,
          rows: rows,
          target: later.first,
          scope: EditScope.following,
        );
  return _write(ref, series.userId, w);
}

/// A series that repeats [o] by [rule] from [o]'s start.
Series _seriesFrom(Occurrence o, RepeatRule rule, String id, DateTime now) {
  final zone = tz.getLocation(o.tzId);
  final wall = utcToWallClock(zone, o.startUtc!);
  final day = DateTime(wall.year, wall.month, wall.day);
  return Series(
    id: id,
    userId: o.userId,
    title: o.title,
    notes: o.notes,
    colorKey: o.colorKey,
    iconKey: o.iconKey,
    durationMin: o.durationMin,
    rrule: rule.rruleFrom(day),
    dtstartLocal: _local(wall),
    tzId: o.tzId,
    count: switch (rule.end) {
      EndsAfter(:final count) => count,
      _ => null,
    },
    untilUtc: switch (rule.end) {
      EndsOn(:final until) => wallClockToUtc(
        zone,
        DateTime(until.year, until.month, until.day, 23, 59, 59),
      ),
      _ => null,
    },
    pinned: o.pinned,
    travelBufferMin: o.travelBufferMin,
    createdAt: now,
    updatedAt: now,
  );
}

String _local(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}T${two(d.hour)}:${two(d.minute)}:00';
}
