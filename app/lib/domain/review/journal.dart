import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:timezone/timezone.dart' as tz;

// The thread journal (11 D3, docs/09 M12.3): every past day as a B5
// snapshot, read-only and derived on read from the local tasks (owner,
// 2026-10-25: no new table, no migration). Pure.

/// How far back the journal reads: the year strip's twelve months.
const journalMonths = 12;

/// One past day.
final class JournalDay {
  const JournalDay({required this.date, required this.snapshot});

  /// Local date (y/m/d).
  final DateTime date;
  final DaySnapshot snapshot;
}

/// Every day before [today] (local) back to the first of the month
/// [journalMonths] − 1 months earlier that had something planned, newest
/// first, each as [DaySnapshot.ofDay] under [settings]' day shape.
///
/// ```dart
/// journalDays(rows, zone: berlin, settings: s, today: d).first.date;
/// ```
List<JournalDay> journalDays(
  Iterable<Occurrence> rows, {
  required tz.Location zone,
  required Settings settings,
  required DateTime today,
}) {
  final first = journalStart(today);
  final byDate = <DateTime, List<Occurrence>>{};
  for (final o in rows) {
    final start = o.startUtc;
    if (start == null || o.deletedAt != null) continue;
    final local = tz.TZDateTime.from(start, zone);
    final date = DateTime(local.year, local.month, local.day);
    if (date.isBefore(first) || !date.isBefore(today)) continue;
    (byDate[date] ??= []).add(o);
  }
  final days = [
    for (final MapEntry(key: date, value: blocks) in byDate.entries)
      JournalDay(
        date: date,
        snapshot: DaySnapshot.ofDay(
          blocks: blocks,
          shape: DayShape.on(
            zone,
            date,
            settings.boundaryFor(Weekday.values[date.weekday - 1]),
          ),
        ),
      ),
  ]..removeWhere((d) => d.snapshot.dots.isEmpty);
  return days..sort((a, b) => b.date.compareTo(a.date));
}

/// The first day the journal reads for [today]: the first of the month
/// eleven months back.
DateTime journalStart(DateTime today) =>
    DateTime(today.year, today.month - (journalMonths - 1));

/// The days of [days] with a task whose title holds [query] (any case),
/// newest first — the first is "when did I last…". A blank query matches
/// nothing.
///
/// ```dart
/// searchJournal(days, 'run').first.date; // the last run
/// ```
List<JournalDay> searchJournal(List<JournalDay> days, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return [
    for (final d in days)
      if (d.snapshot.dots.any((x) => x.title.toLowerCase().contains(q))) d,
  ];
}

/// One month of the year strip: its first day and each day's share done
/// (null: nothing planned, or not yet past).
final class StripMonth {
  const StripMonth({required this.month, required this.shares});

  final DateTime month;
  final List<double?> shares;
}

/// The year strip (11 D3): twelve months ending with [today]'s, oldest
/// first, one completion share per day as the month grid draws it.
List<StripMonth> yearStrip(List<JournalDay> days, DateTime today) {
  final byDate = {for (final d in days) d.date: d.snapshot};
  final first = journalStart(today);
  return [
    for (var m = 0; m < journalMonths; m++)
      () {
        final month = DateTime(first.year, first.month + m);
        final length = DateTime(month.year, month.month + 1, 0).day;
        return StripMonth(
          month: month,
          shares: [
            for (var d = 1; d <= length; d++)
              switch (byDate[DateTime(month.year, month.month, d)]) {
                final s? when s.dayTotal > 0 => s.dayDone / s.dayTotal,
                _ => null,
              },
          ],
        );
      }(),
  ];
}
