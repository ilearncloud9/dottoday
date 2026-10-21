import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/recurrence/recurrence_expander.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../fixtures.dart';

// Critical cases from docs/08 §2 `recurrence_expander_test` (R-01, R-09).

const _expander = RecurrenceExpander();

Series _series(
  String rrule,
  String dtstartLocal, {
  String tzId = 'Europe/Berlin',
  int? count,
  DateTime? untilUtc,
}) => seriesFixture().copyWith(
  rrule: rrule,
  dtstartLocal: dtstartLocal,
  tzId: tzId,
  count: count,
  untilUtc: untilUtc,
);

List<DateTime> _expand(
  Series s,
  DateTime from,
  DateTime to, {
  Set<DateTime> exceptions = const {},
}) => _expander.expand(s, fromUtc: from, toUtc: to, exceptionsUtc: exceptions);

/// Local wall-clock strings of [utc] instants in [tzId], for readable
/// expectations.
List<String> _local(List<DateTime> utc, String tzId) {
  final loc = tz.getLocation(tzId);
  return [
    for (final u in utc)
      utcToWallClock(loc, u).toIso8601String().substring(0, 16),
  ];
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('weekly rule stays at 07:00 local across the October DST change', () {
    final s = _series('FREQ=WEEKLY;BYDAY=MO', '2026-10-19T07:00');
    final got = _expand(
      s,
      DateTime.utc(2026, 10, 19),
      DateTime.utc(2026, 11, 3),
    );
    expect(_local(got, 'Europe/Berlin'), [
      '2026-10-19T07:00',
      '2026-10-26T07:00',
      '2026-11-02T07:00',
    ]);
    // Same wall time, different UTC offset before/after the change.
    expect(got.first.hour, 5);
    expect(got[1].hour, 6);
  });

  test('monthly on the 31st skips shorter months (RFC 5545)', () {
    final s = _series('FREQ=MONTHLY;BYMONTHDAY=31', '2026-01-31T09:00');
    final got = _expand(s, DateTime.utc(2026), DateTime.utc(2026, 8));
    expect(_local(got, 'Europe/Berlin'), [
      '2026-01-31T09:00',
      '2026-03-31T09:00',
      '2026-05-31T09:00',
      '2026-07-31T09:00',
    ]);
  });

  test('BYMONTHDAY=-1 is the last day of every month', () {
    final s = _series('FREQ=MONTHLY;BYMONTHDAY=-1', '2026-01-31T09:00');
    final got = _expand(s, DateTime.utc(2026), DateTime.utc(2026, 4));
    expect(_local(got, 'Europe/Berlin').map((d) => d.substring(0, 10)), [
      '2026-01-31',
      '2026-02-28',
      '2026-03-31',
    ]);
  });

  test('Feb 29 yearly only occurs in leap years', () {
    final s = _series('FREQ=YEARLY', '2024-02-29T08:00', tzId: 'UTC');
    final got = _expand(s, DateTime.utc(2024), DateTime.utc(2033));
    expect(got, [
      DateTime.utc(2024, 2, 29, 8),
      DateTime.utc(2028, 2, 29, 8),
      DateTime.utc(2032, 2, 29, 8),
    ]);
  });

  test('DST spring-forward: 02:30 Europe/Berlin becomes 03:30 CEST', () {
    final s = _series('FREQ=DAILY', '2026-03-28T02:30');
    final got = _expand(
      s,
      DateTime.utc(2026, 3, 28),
      DateTime.utc(2026, 3, 31),
    );
    expect(_local(got, 'Europe/Berlin'), [
      '2026-03-28T02:30',
      '2026-03-29T03:30',
      '2026-03-30T02:30',
    ]);
    expect(got[1], DateTime.utc(2026, 3, 29, 1, 30));
  });

  test('DST fall-back: the duplicated 02:30 fires once, at the first one', () {
    final s = _series('FREQ=DAILY', '2026-10-24T02:30');
    final got = _expand(
      s,
      DateTime.utc(2026, 10, 24),
      DateTime.utc(2026, 10, 27),
    );
    expect(got, [
      DateTime.utc(2026, 10, 24, 0, 30),
      DateTime.utc(2026, 10, 25, 0, 30), // 02:30 CEST, not 02:30 CET
      DateTime.utc(2026, 10, 26, 1, 30),
    ]);
  });

  group('UNTIL in another zone', () {
    // Daily 09:00 New York (13:00Z in October).
    Series ny(String rrule) =>
        _series(rrule, '2026-10-01T09:00', tzId: 'America/New_York');
    final from = DateTime.utc(2026, 10);
    final to = DateTime.utc(2026, 11);

    test(
      'UTC UNTIL is an instant: 2026-10-03T12:00Z excludes 3 Oct 09:00 EDT',
      () {
        final got = _expand(ny('FREQ=DAILY;UNTIL=20261003T120000Z'), from, to);
        expect(_local(got, 'America/New_York'), [
          '2026-10-01T09:00',
          '2026-10-02T09:00',
        ]);
      },
    );

    test('floating UNTIL is wall-clock in the series zone', () {
      final got = _expand(ny('FREQ=DAILY;UNTIL=20261003T090000'), from, to);
      expect(got.length, 3);
    });

    test('date-only UNTIL includes that local day', () {
      final got = _expand(ny('FREQ=DAILY;UNTIL=20261003'), from, to);
      expect(got.length, 3);
    });

    test('series.untilUtc set from another zone narrows the rule', () {
      // 3 Oct 14:00 Berlin = 12:00Z, before 09:00 New York (13:00Z).
      final s = ny(
        'FREQ=DAILY',
      ).copyWith(untilUtc: DateTime.utc(2026, 10, 3, 12));
      expect(_expand(s, from, to).length, 2);
    });
  });

  group('COUNT with exceptions', () {
    final s = _series('FREQ=DAILY;COUNT=5', '2026-10-01T10:00', tzId: 'UTC');
    final from = DateTime.utc(2026, 9);
    final to = DateTime.utc(2026, 12);

    test('exceptions still consume the count (EXDATE semantics)', () {
      final got = _expand(
        s,
        from,
        to,
        exceptions: {
          DateTime.utc(2026, 10, 2, 10),
          DateTime.utc(2026, 10, 4, 10),
        },
      );
      expect(got.map((d) => d.day), [1, 3, 5]);
    });

    test('series.count overrides the rule COUNT', () {
      expect(_expand(s.copyWith(count: 2), from, to).length, 2);
    });

    test(
      'count is honoured when the window starts after the first instances',
      () {
        final got = _expand(s, DateTime.utc(2026, 10, 4), to);
        expect(got.map((d) => d.day), [4, 5]);
      },
    );
  });

  group('window', () {
    final s = _series(
      'FREQ=DAILY',
      '2026-10-01T23:30',
      tzId: 'Pacific/Auckland',
    );

    test('is half-open [from, to) in UTC', () {
      final first = _expand(
        s,
        DateTime.utc(2026, 9),
        DateTime.utc(2026, 11),
      ).first;
      expect(_expand(s, first, first.add(const Duration(days: 1))), [first]);
      expect(
        _expand(
          s,
          first.add(const Duration(seconds: 1)),
          first.add(const Duration(days: 1)),
        ),
        isEmpty,
      );
    });

    test('window entirely before DTSTART is empty', () {
      expect(_expand(s, DateTime.utc(2025), DateTime.utc(2025, 2)), isEmpty);
    });

    test('a 90-day window far from DTSTART stays exact', () {
      final from = DateTime.utc(2030, 1, 1);
      final got = _expand(s, from, from.add(const Duration(days: 90)));
      expect(got.length, 90);
      expect(got.every((d) => !d.isBefore(from)), isTrue);
    });

    test('interval > 1 keeps its phase', () {
      final every3 = _series(
        'FREQ=DAILY;INTERVAL=3',
        '2026-10-01T08:00',
        tzId: 'UTC',
      );
      final got = _expand(
        every3,
        DateTime.utc(2026, 10, 5),
        DateTime.utc(2026, 10, 14),
      );
      expect(got.map((d) => d.day), [7, 10, 13]);
    });
  });

  group('wallClockToUtc', () {
    test('non-transition times use the zone offset', () {
      final loc = tz.getLocation('Asia/Kolkata');
      expect(
        wallClockToUtc(loc, DateTime(2026, 6, 1, 9)),
        DateTime.utc(2026, 6, 1, 3, 30),
      );
    });

    test('round-trips with utcToWallClock', () {
      final loc = tz.getLocation('America/New_York');
      final utc = DateTime.utc(2026, 7, 4, 16);
      expect(wallClockToUtc(loc, utcToWallClock(loc, utc)), utc);
    });
  });
}
