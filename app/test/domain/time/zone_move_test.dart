import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/domain/time/zone_move.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/fake_ids.dart';
import '../fixtures.dart';

// A Berlin planner lands in New York (docs/07, docs/09 M5.9). Now is Wed
// 21 Oct 2026 12:00 in Berlin (10:00 UTC).

final _now = DateTime.utc(2026, 10, 21, 10);
const _ny = 'America/New_York';

Occurrence _task(String id, DateTime startUtc) => occurrenceFixture().copyWith(
  id: id,
  seriesId: null,
  startUtc: startUtc,
  tzId: 'Europe/Berlin',
);

WriteBatch _plan(
  ZoneMoveChoice choice, {
  List<Occurrence> upcoming = const [],
  List<({Series series, List<Occurrence> rows})> series = const [],
}) => planZoneMove(
  profile: profileFixture().copyWith(tzId: 'Europe/Berlin'),
  newZone: _ny,
  choice: choice,
  upcoming: upcoming,
  series: series,
  editor: SeriesEditor(clock: FakeClock(_now), ids: FakeIds('new')),
  nowUtc: _now,
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final tomorrow9 = _task('a', DateTime.utc(2026, 10, 22, 7)); // 09:00 Berlin

  test('shift: only the profile changes zone', () {
    final b = _plan(ZoneMoveChoice.shift, upcoming: [tomorrow9]);
    expect(b.profile!.tzId, _ny);
    expect(b.occurrences, isEmpty);
    expect(b.series, isEmpty);
  });

  test('keep times: 09:00 stays 09:00 in the new zone', () {
    final b = _plan(ZoneMoveChoice.keepTimes, upcoming: [tomorrow9]);
    final o = b.occurrences.single;
    expect(o.tzId, _ny);
    expect(o.startUtc, DateTime.utc(2026, 10, 22, 13)); // 09:00 EDT
    expect(b.profile!.tzId, _ny);
  });

  test('keep times leaves started, done, calendar and inbox tasks', () {
    final b = _plan(
      ZoneMoveChoice.keepTimes,
      upcoming: [
        _task('past', DateTime.utc(2026, 10, 21, 9)),
        _task(
          'done',
          DateTime.utc(2026, 10, 22, 7),
        ).copyWith(status: OccurrenceStatus.done),
        _task(
          'cal',
          DateTime.utc(2026, 10, 22, 7),
        ).copyWith(source: OccurrenceSource.calendar),
        _task('inbox', DateTime.utc(2026, 10, 22, 7)).copyWith(startUtc: null),
        _task('there', DateTime.utc(2026, 10, 22, 7)).copyWith(tzId: _ny),
      ],
    );
    expect(b.occurrences, isEmpty);
  });

  test('keep times splits a repeat at its next instance, no duplicates', () {
    final s = seriesFixture().copyWith(
      rrule: 'FREQ=DAILY',
      dtstartLocal: '2026-10-19T07:00',
      alerts: const [],
      subtaskTemplate: const [],
    );
    final rows = Materialiser(
      clock: FakeClock(DateTime.utc(2026, 10, 19, 12)),
      ids: FakeIds('row'),
    ).plan(s, const []).occurrences;
    final b = _plan(
      ZoneMoveChoice.keepTimes,
      series: [(series: s, rows: rows)],
    );
    final series = b.series;
    expect(series, hasLength(2));
    final next = series.firstWhere((x) => x.id != s.id);
    expect(next.tzId, _ny);
    expect(next.dtstartLocal, '2026-10-22T07:00:00');
    // The old one ends before the 22nd's instance; today's (07:00 Berlin,
    // already past) stays with it.
    expect(
      series.firstWhere((x) => x.id == s.id).untilUtc,
      DateTime.utc(2026, 10, 22, 4, 59, 59),
    );
    final moved = b.occurrences;
    final thu = moved.firstWhere((o) => o.startUtc!.day == 22);
    expect(thu.startUtc, DateTime.utc(2026, 10, 22, 11)); // 07:00 EDT
    expect(thu.seriesId, next.id);
    expect(thu.tzId, _ny);
    expect(moved.where((o) => o.deletedAt != null), isEmpty);
    // Materialising the new series over the moved rows adds nothing new.
    final again = Materialiser(clock: FakeClock(_now), ids: FakeIds('x'))
        .plan(next.copyWith(materialisedThroughUtc: null), moved)
        .occurrences
        .where((o) => o.startUtc!.isBefore(moved.last.startUtc!));
    expect(again, isEmpty);
  });
}
