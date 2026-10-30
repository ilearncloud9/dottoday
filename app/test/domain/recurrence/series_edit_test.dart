import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/domain/recurrence/recurrence_expander.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fake_clock.dart';
import '../../support/fake_ids.dart';
import '../fixtures.dart';

// Edit and delete scopes against the expander and materialiser (docs/09
// M3f.1, R-01). A daily 07:00 run in Berlin (UTC+2 until 25 Oct) from Mon
// 19 Oct; now is Wed 21 Oct 12:00 local; the 19th and 20th are done.

final _now = DateTime.utc(2026, 10, 21, 10);

Series _series({String rrule = 'FREQ=DAILY', int? count}) =>
    seriesFixture().copyWith(
      rrule: rrule,
      dtstartLocal: '2026-10-19T07:00',
      count: count,
      alerts: const [],
      subtaskTemplate: const [],
    );

/// Rows as the app holds them: materialised from the 19th, past ones done.
List<Occurrence> _rows(Series s) {
  final plan = Materialiser(
    clock: FakeClock(DateTime.utc(2026, 10, 19, 12)),
  ).plan(s, const []);
  return [
    for (final o in plan.occurrences)
      o.startUtc!.isBefore(DateTime.utc(2026, 10, 21))
          ? o.copyWith(status: OccurrenceStatus.done)
          : o,
  ];
}

/// The October day of [o]'s instance, or 0 for any later month.
int _oct(Occurrence o) =>
    o.originalStartUtc!.month == 10 ? o.originalStartUtc!.day : 0;

Occurrence _on(List<Occurrence> rows, int day) =>
    rows.firstWhere((o) => o.originalStartUtc!.day == day);

SeriesEditor _editor() =>
    SeriesEditor(clock: FakeClock(_now), ids: FakeIds('new'));

/// [rows] with [write]'s rows in place.
List<Occurrence> _merge(List<Occurrence> rows, SeriesWrite write) {
  final byId = {for (final o in rows) o.id: o};
  for (final o in write.occurrences) {
    byId[o.id] = o;
  }
  return byId.values.toList();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('this one: only the instance in hand, at its new time', () {
    final s = _series();
    final rows = _rows(s);
    final w = _editor().edit(
      series: s,
      rows: rows,
      target: _on(rows, 23),
      scope: EditScope.thisOne,
      change: const SeriesChange(title: 'Long run', startMinute: 8 * 60),
    );
    expect(w.series, isEmpty);
    expect(w.occurrences.single.id, _on(rows, 23).id);
    expect(w.occurrences.single.title, 'Long run');
    expect(w.occurrences.single.startUtc, DateTime.utc(2026, 10, 23, 6));
  });

  test('following, fields only: the series and later planned rows', () {
    final s = _series();
    final rows = _rows(s);
    final w = _editor().edit(
      series: s,
      rows: rows,
      target: _on(rows, 23),
      scope: EditScope.following,
      change: const SeriesChange(title: 'Long run'),
    );
    expect(w.series.single.title, 'Long run');
    expect(w.series.single.id, s.id);
    final days = {for (final o in w.occurrences) _oct(o)};
    expect(days, containsAll([23, 24, 30]));
    expect(days, isNot(contains(22)));
    expect(w.occurrences.every((o) => o.title == 'Long run'), isTrue);
  });

  test('a sound for all: the series takes it, later rows inherit '
      '(docs/12 §3)', () {
    final s = _series();
    final rows = [for (final o in _rows(s)) o.copyWith(soundId: 'play.frog')];
    final opened = _on(rows, 23);
    final change = SeriesChange.between(
      opened,
      opened.copyWith(soundId: 'clear.lift'),
      tz.getLocation(opened.tzId),
    );
    expect(change.soundId, (to: 'clear.lift'));
    final w = _editor().edit(
      series: s,
      rows: rows,
      target: opened,
      scope: EditScope.following,
      change: change,
    );
    expect(w.series.single.soundId, 'clear.lift');
    expect(w.occurrences.map((o) => o.soundId), everyElement(isNull));
    // Back to Default: (to: null) clears the series' sound.
    final cleared = SeriesChange.between(
      opened,
      opened.copyWith(soundId: null),
      tz.getLocation(opened.tzId),
    );
    expect(cleared.soundId, (to: null));
    expect(cleared.template(s.copyWith(soundId: 'bell')).soundId, isNull);
    // "This one" keeps it on the row.
    expect(change.fields(opened, own: true).soundId, 'clear.lift');
  });

  test('all, fields only: from the first planned instance today on', () {
    final s = _series();
    final rows = _rows(s);
    final w = _editor().edit(
      series: s,
      rows: rows,
      target: _on(rows, 25),
      scope: EditScope.all,
      change: const SeriesChange(colorKey: 'mint'),
    );
    final days = {for (final o in w.occurrences) _oct(o)};
    expect(days, containsAll([21, 22, 25]));
    expect(days.intersection({19, 20}), isEmpty, reason: 'history stays');
  });

  test('following, new time: split; rows move with their ids, no doubles', () {
    final s = _series();
    final rows = _rows(s);
    final target = _on(rows, 23);
    final w = _editor().edit(
      series: s,
      rows: rows,
      target: target,
      scope: EditScope.following,
      change: const SeriesChange(startMinute: 8 * 60),
    );
    final (old, next) = (w.series.first, w.series.last);
    expect(old.id, s.id);
    expect(old.untilUtc, DateTime.utc(2026, 10, 23, 4, 59, 59));
    expect(next.id, isNot(s.id));
    expect(next.dtstartLocal, '2026-10-23T08:00:00');
    final moved = w.occurrences.firstWhere((o) => o.id == target.id);
    expect(moved.seriesId, next.id);
    expect(moved.startUtc, DateTime.utc(2026, 10, 23, 6));
    // After DST ends (26 Oct, UTC+1) 08:00 local is 07:00Z.
    final later = w.occurrences.firstWhere((o) => o.startUtc!.day == 27);
    expect(later.startUtc, DateTime.utc(2026, 10, 27, 7));
    // Saving re-materialises: nothing new inside the moved rows' range.
    final plan = Materialiser(
      clock: FakeClock(_now),
    ).plan(next, _merge(rows, w));
    final lastMoved = w.occurrences
        .map((o) => o.originalStartUtc!)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    expect(
      plan.occurrences.every((o) => o.startUtc!.isAfter(lastMoved)),
      isTrue,
    );
    // The old series now stops before the 23rd.
    final oldStarts = const RecurrenceExpander().expand(
      old,
      fromUtc: DateTime.utc(2026, 10, 19),
      toUtc: DateTime.utc(2026, 11, 30),
    );
    expect(oldStarts.map((u) => u.day), [19, 20, 21, 22]);
  });

  test(
    'following, new rule: rows off the rule are deleted, done ones kept',
    () {
      final s = _series();
      final rows = _rows(s);
      // Saturday 24th was ticked off ahead of time.
      final ticked = _on(rows, 24).copyWith(status: OccurrenceStatus.done);
      final all = [for (final o in rows) o.id == ticked.id ? ticked : o];
      final w = _editor().edit(
        series: s,
        rows: all,
        target: _on(all, 23),
        scope: EditScope.following,
        change: const SeriesChange(rule: RepeatRule.weekdays()),
      );
      final next = w.series.last;
      expect(next.rrule, 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR');
      final sunday = w.occurrences.firstWhere((o) => o.id == _on(all, 25).id);
      expect(sunday.deletedAt, isNotNull);
      expect(w.occurrences.where((o) => o.id == ticked.id), isEmpty);
      final monday = w.occurrences.firstWhere((o) => o.id == _on(all, 26).id);
      expect((monday.seriesId, monday.deletedAt), (next.id, null));
    },
  );

  test('a counted series keeps its total across the split', () {
    final s = _series(count: 10);
    final rows = _rows(s);
    final w = _editor().edit(
      series: s,
      rows: rows,
      target: _on(rows, 23),
      scope: EditScope.following,
      change: const SeriesChange(startMinute: 9 * 60),
    );
    expect(w.series.first.count, isNull);
    expect(w.series.last.count, 10 - 4);
  });

  test('editing from the very first instance archives the old series', () {
    final s = _series();
    final rows = _rows(s);
    final w = _editor().edit(
      series: s,
      rows: rows,
      target: _on(rows, 19),
      scope: EditScope.following,
      change: const SeriesChange(startMinute: 9 * 60),
    );
    expect(w.series.first.archivedAt, _now);
  });

  test('delete this one / following / all', () {
    final s = _series();
    final rows = _rows(s);
    final e = _editor();
    final one = e.delete(
      series: s,
      rows: rows,
      target: _on(rows, 23),
      scope: EditScope.thisOne,
    );
    expect(one.occurrences.single.deletedAt, _now);

    final following = e.delete(
      series: s,
      rows: rows,
      target: _on(rows, 23),
      scope: EditScope.following,
    );
    expect(following.series.single.untilUtc, isNotNull);
    final gone = {for (final o in following.occurrences) _oct(o)};
    expect(gone.contains(22), isFalse);
    expect(gone.containsAll({23, 24}), isTrue);

    final all = e.delete(
      series: s,
      rows: rows,
      target: _on(rows, 23),
      scope: EditScope.all,
    );
    expect(all.series.single.deletedAt, _now);
    final allGone = {for (final o in all.occurrences) _oct(o)};
    expect(allGone.intersection({19, 20}), isEmpty, reason: 'done stay');
    expect(allGone.contains(21), isTrue);
  });

  test('SeriesChange.between reads what changed', () {
    final berlin = tz.getLocation('Europe/Berlin');
    final s = _series();
    final o = _rows(s).first;
    final c = SeriesChange.between(
      o,
      o.copyWith(
        title: 'Swim',
        startUtc: o.startUtc!.add(const Duration(hours: 1)),
      ),
      berlin,
    );
    expect((c.title, c.startMinute, c.colorKey), ('Swim', 8 * 60, null));
    expect(c.moves, isTrue);
    expect(SeriesChange.between(o, o, berlin).isEmpty, isTrue);
  });

  test('energy: set, cleared and unchanged are told apart (F2.9)', () {
    final berlin = tz.getLocation('Europe/Berlin');
    final s = _series().copyWith(energy: Energy.low);
    final o = _rows(s).first;
    final high = o.copyWith(energy: Energy.high);
    final set = SeriesChange.between(o, high, berlin);
    expect(set.energy, (to: Energy.high));
    expect(set.moves, isFalse);
    expect(set.template(s).energy, Energy.high);
    final cleared = SeriesChange.between(o, o.copyWith(energy: null), berlin);
    expect(cleared.isEmpty, isFalse);
    expect(cleared.template(s).energy, isNull);
    expect(cleared.fields(high).energy, isNull);
    expect(const SeriesChange(title: 'x').fields(high).energy, Energy.high);
  });

  test('notes: emptied notes reach the series, unchanged keep them', () {
    final berlin = tz.getLocation('Europe/Berlin');
    final s = _series().copyWith(notes: 'Bring towel');
    final o = _rows(s).first.copyWith(notes: 'Bring towel');
    final cleared = SeriesChange.between(o, o.copyWith(notes: null), berlin);
    expect(cleared.notes, (to: null));
    expect(cleared.isEmpty, isFalse);
    expect(cleared.moves, isFalse);
    expect(cleared.template(s).notes, isNull);
    expect(cleared.fields(o).notes, isNull);
    final set = SeriesChange.between(o, o.copyWith(notes: 'Goggles'), berlin);
    expect(set.template(s).notes, 'Goggles');
    expect(const SeriesChange(title: 'x').template(s).notes, 'Bring towel');
    expect(SeriesChange.between(o, o, berlin).notes, isNull);
  });
}
