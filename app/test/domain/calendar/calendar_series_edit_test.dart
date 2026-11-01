import 'package:dottoday/domain/calendar/calendar_series_edit.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/recurrence/series_change.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

// Scope All on a repeating calendar event (docs/02 F5.7): the series'
// settings and every planned instance from today change in one write.

const _user = 'u1';
final _now = DateTime.utc(2026, 11, 2, 6);
final _today = DateTime.utc(2026, 11, 1, 23); // 00:00 Berlin, 2 Nov

Occurrence _day(String id, DateTime start, {OccurrenceStatus? status}) =>
    Occurrence(
      id: id,
      userId: _user,
      title: 'Read the Bible and pray',
      startUtc: start,
      tzId: 'Europe/Berlin',
      durationMin: 30,
      source: OccurrenceSource.calendar,
      calendarLinkId: 'l-$id',
      status: status ?? OccurrenceStatus.planned,
      createdAt: _now,
      updatedAt: _now,
    );

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const series = ImportedSeries(accountId: 'acc', seriesKey: 'R1');
  final yesterday = _day('y', DateTime.utc(2026, 11, 1, 5));
  final todayDone = _day(
    'd',
    DateTime.utc(2026, 11, 2, 5),
    status: OccurrenceStatus.done,
  );
  final tomorrow = _day('t', DateTime.utc(2026, 11, 3, 5));
  final later = _day('l', DateTime.utc(2026, 11, 10, 5));
  final rows = [yesterday, todayDone, tomorrow, later];
  var n = 0;
  String newId() => 'new-${++n}';

  test('All reaches planned instances from today and the settings', () {
    final w = editImportedSeries(
      series: series,
      instances: rows,
      target: tomorrow,
      change: const SeriesChange(
        notes: (to: 'Psalm 23'),
        alerts: [Alert(kind: AlertKind.atStart)],
      ),
      fromUtc: _today,
      now: _now,
      newId: newId,
    );
    expect(w.settings.notes, 'Psalm 23');
    expect(w.settings.alerts, const [Alert(kind: AlertKind.atStart)]);
    expect((w.settings.accountId, w.settings.seriesKey), ('acc', 'R1'));
    expect({for (final o in w.occurrences) o.id}, {'t', 'l'});
    for (final o in w.occurrences) {
      expect(o.notes, 'Psalm 23');
      expect(o.alerts, const [Alert(kind: AlertKind.atStart)], reason: 'own');
    }
  });

  test('a new time moves each instance on its own date (DST safe)', () {
    final w = editImportedSeries(
      series: series,
      instances: rows,
      target: tomorrow,
      change: const SeriesChange(startMinute: 330),
      fromUtc: _today,
      now: _now,
      newId: newId,
    );
    expect(w.settings.startMinute, 330);
    expect(w.settings.tzId, 'Europe/Berlin');
    final starts = {for (final o in w.occurrences) o.id: o.startUtc};
    // 05:30 Berlin is 04:30Z in November (CET).
    expect(starts['t'], DateTime.utc(2026, 11, 3, 4, 30));
    expect(starts['l'], DateTime.utc(2026, 11, 10, 4, 30));
  });

  test('an existing settings row is updated, not replaced', () {
    final first = editImportedSeries(
      series: series,
      instances: rows,
      target: tomorrow,
      change: const SeriesChange(colorKey: 'sky'),
      fromUtc: _today,
      now: _now,
      newId: newId,
    );
    final second = editImportedSeries(
      series: ImportedSeries(
        accountId: 'acc',
        seriesKey: 'R1',
        settings: first.settings,
      ),
      instances: rows,
      target: tomorrow,
      change: const SeriesChange(durationMin: 45),
      fromUtc: _today,
      now: _now,
      newId: newId,
    );
    expect(second.settings.id, first.settings.id);
    expect(
      (second.settings.colorKey, second.settings.durationMin),
      ('sky', 45),
    );
  });

  test('delete All hides the series and trashes from today on', () {
    final w = deleteImportedSeries(
      series: series,
      instances: rows,
      target: tomorrow,
      fromUtc: _today,
      now: _now,
      newId: newId,
    );
    expect(w.settings.hidden, isTrue);
    expect({for (final o in w.occurrences) o.id}, {'t', 'l'});
    expect(w.occurrences.every((o) => o.deletedAt == _now), isTrue);
  });
}
