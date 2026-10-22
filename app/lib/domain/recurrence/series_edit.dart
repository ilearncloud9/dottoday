import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/recurrence/recurrence_expander.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/recurrence/series_change.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:timezone/timezone.dart' as tz;

export 'series_change.dart';

/// Which instances of a repeating task an edit or delete reaches (docs/09
/// M3f.1, R-01): the one in hand, it and every later one, or all of them
/// from the first that hasn't happened yet. History never changes.
enum EditScope { thisOne, following, all }

/// Series and occurrence rows one scoped edit or delete writes; saving
/// the series re-materialises it in the same batch (docs/09 M2.3).
typedef SeriesWrite = ({List<Series> series, List<Occurrence> occurrences});

/// Applies edits and deletes to a repeating task by scope (docs/09 M3f.1,
/// R-01), as one batch so one Undo reverts it.
///
/// Field changes (title, colour, length …) update the series in place and
/// every later planned instance. A new time or rule splits the series at
/// the pivot: the old one ends just before it, a new one starts there, and
/// each later row the new rule still lands on moves over (keeping its id
/// and subtasks); planned rows it no longer covers are deleted; done or
/// skipped rows stay as they were.
final class SeriesEditor {
  const SeriesEditor({
    required Clock clock,
    required IdGenerator ids,
    RecurrenceExpander expander = const RecurrenceExpander(),
  }) : _clock = clock,
       _ids = ids,
       _expander = expander;

  final Clock _clock;
  final IdGenerator _ids;
  final RecurrenceExpander _expander;

  /// [change] to [target], an instance of [series], by [scope]; [rows]
  /// are the series' materialised rows.
  ///
  /// ```dart
  /// editor.edit(series: s, rows: rows, target: o, scope: EditScope.all,
  ///     change: const SeriesChange(title: 'Long run'));
  /// ```
  SeriesWrite edit({
    required Series series,
    required List<Occurrence> rows,
    required Occurrence target,
    required SeriesChange change,
    required EditScope scope,
  }) {
    final now = _clock.nowUtc();
    final zone = tz.getLocation(series.tzId);
    if (scope == EditScope.thisOne) {
      return (series: const [], occurrences: [_moved(change, target, zone)]);
    }
    final pivot = _pivot(series, rows, target, scope, zone);
    if (!change.moves) {
      return (
        series: [change.template(series).copyWith(updatedAt: now)],
        occurrences: [
          for (final o in _from(rows, pivot))
            if (o.status == OccurrenceStatus.planned || o.id == target.id)
              change.fields(o).copyWith(updatedAt: now),
        ],
      );
    }
    return _split(series, rows, target, change, pivot, zone, now);
  }

  /// Deletes [target] (thisOne), it and every later instance (following),
  /// or the series from now on (all). Done and skipped rows stay.
  SeriesWrite delete({
    required Series series,
    required List<Occurrence> rows,
    required Occurrence target,
    required EditScope scope,
  }) {
    final now = _clock.nowUtc();
    final zone = tz.getLocation(series.tzId);
    if (scope == EditScope.thisOne) {
      return (
        series: const [],
        occurrences: [target.copyWith(deletedAt: now, updatedAt: now)],
      );
    }
    final pivot = _pivot(series, rows, target, scope, zone);
    final ended = scope == EditScope.all
        ? series.copyWith(deletedAt: now, updatedAt: now)
        : _endBefore(series, pivot, now);
    return (
      series: [ended],
      occurrences: [
        for (final o in _from(rows, pivot))
          if (o.status == OccurrenceStatus.planned)
            o.copyWith(deletedAt: now, updatedAt: now),
      ],
    );
  }

  SeriesWrite _split(
    Series series,
    List<Occurrence> rows,
    Occurrence target,
    SeriesChange change,
    DateTime pivot,
    tz.Location zone,
    DateTime now,
  ) {
    final next = _successor(series, change, pivot, zone, now);
    final later = _from(rows, pivot).toList();
    final last = later.fold(pivot, (m, o) => _key(o).isAfter(m) ? _key(o) : m);
    final byDay = {
      for (final utc in _expander.expand(
        next,
        fromUtc: pivot,
        toUtc: last.add(const Duration(days: 2)),
      ))
        _day(zone, utc): utc,
    };
    final out = <Occurrence>[];
    for (final o in later) {
      final instance = byDay[_day(zone, _key(o))];
      final planned = o.status == OccurrenceStatus.planned;
      if (instance != null) {
        final moved = o.copyWith(
          seriesId: next.id,
          originalStartUtc: instance,
          startUtc: planned ? instance : o.startUtc,
          updatedAt: now,
        );
        out.add(planned ? change.fields(moved) : moved);
      } else if (planned) {
        out.add(o.copyWith(deletedAt: now, updatedAt: now));
      }
    }
    return (series: [_endBefore(series, pivot, now), next], occurrences: out);
  }

  /// The new series from [pivot]: the old template with [change], its own
  /// id, starting on the pivot's local date at the (new) time.
  Series _successor(
    Series s,
    SeriesChange change,
    DateTime pivot,
    tz.Location zone,
    DateTime now,
  ) {
    final wall = utcToWallClock(zone, pivot);
    final old = DateTime.parse(s.dtstartLocal);
    final minute = change.startMinute ?? old.hour * 60 + old.minute;
    final start = DateTime(
      wall.year,
      wall.month,
      wall.day,
      minute ~/ 60,
      minute % 60,
    );
    final rule = change.rule;
    return change
        .template(s)
        .copyWith(
          id: _ids.newId(),
          rrule: rule?.rruleFrom(start) ?? s.rrule,
          dtstartLocal: _local(start),
          untilUtc: _untilOf(rule?.end, s, zone),
          count: _countOf(rule?.end, s, pivot),
          materialisedThroughUtc: null,
          createdAt: now,
          updatedAt: now,
        );
  }

  /// A new end's date as UTC; no new end keeps the old one.
  static DateTime? _untilOf(RepeatEnd? end, Series s, tz.Location zone) =>
      switch (end) {
        EndsOn(:final until) => wallClockToUtc(
          zone,
          DateTime(until.year, until.month, until.day, 23, 59, 59),
        ),
        null => s.untilUtc,
        _ => null,
      };

  int? _countOf(RepeatEnd? end, Series s, DateTime pivot) => switch (end) {
    EndsAfter(:final count) => count,
    null => _remaining(s, pivot),
    _ => null,
  };

  /// [s] stopped just before [pivot]; archived if nothing came before it.
  Series _endBefore(Series s, DateTime pivot, DateTime now) {
    final any = _expander
        .expand(
          s.copyWith(untilUtc: null),
          fromUtc: DateTime.utc(1970),
          toUtc: pivot,
        )
        .isNotEmpty;
    if (!any) return s.copyWith(archivedAt: now, updatedAt: now);
    return s.copyWith(
      untilUtc: pivot.subtract(const Duration(seconds: 1)),
      count: null,
      updatedAt: now,
    );
  }

  /// A counted series keeps its total across the split.
  int? _remaining(Series s, DateTime pivot) {
    final count = s.count;
    if (count == null) return null;
    final before = _expander
        .expand(s, fromUtc: DateTime.utc(1970), toUtc: pivot)
        .length;
    return count - before > 0 ? count - before : 1;
  }

  /// Where a scope starts: the instance in hand (following), or the
  /// earliest planned instance from today on, if earlier (all).
  DateTime _pivot(
    Series series,
    List<Occurrence> rows,
    Occurrence target,
    EditScope scope,
    tz.Location zone,
  ) {
    final own = _key(target);
    if (scope != EditScope.all) return own;
    final today = utcToWallClock(zone, _clock.nowUtc());
    final midnight = wallClockToUtc(
      zone,
      DateTime(today.year, today.month, today.day),
    );
    final first = rows
        .where(
          (o) =>
              o.status == OccurrenceStatus.planned &&
              o.deletedAt == null &&
              !_key(o).isBefore(midnight),
        )
        .map(_key)
        .fold<DateTime?>(null, (m, k) => m == null || k.isBefore(m) ? k : m);
    return first != null && first.isBefore(own) ? first : own;
  }

  /// The instance in hand at its new time (thisOne).
  static Occurrence _moved(
    SeriesChange change,
    Occurrence o,
    tz.Location zone,
  ) {
    final minute = change.startMinute;
    final start = o.startUtc;
    if (minute == null || start == null) return change.fields(o, own: true);
    final wall = utcToWallClock(zone, start);
    return change
        .fields(o, own: true)
        .copyWith(
          startUtc: wallClockToUtc(
            zone,
            DateTime(
              wall.year,
              wall.month,
              wall.day,
              minute ~/ 60,
              minute % 60,
            ),
          ),
        );
  }

  static Iterable<Occurrence> _from(List<Occurrence> rows, DateTime pivot) =>
      rows.where((o) => o.deletedAt == null && !_key(o).isBefore(pivot));

  /// Which instance a row is: its original start, else its start.
  static DateTime _key(Occurrence o) => o.originalStartUtc ?? o.startUtc!;

  static DateTime _day(tz.Location zone, DateTime utc) {
    final w = utcToWallClock(zone, utc);
    return DateTime(w.year, w.month, w.day);
  }

  static String _local(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}T${two(d.hour)}:${two(d.minute)}:00';
  }
}
