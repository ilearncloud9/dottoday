import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/fake_ids.dart';
import '../fixtures.dart';

// Daily 07:00 UTC, now = 2026-10-21 12:00Z.
final _now = DateTime.utc(2026, 10, 21, 12);

Series _daily() => seriesFixture().copyWith(
  rrule: 'FREQ=DAILY',
  dtstartLocal: '2026-10-01T07:00',
  tzId: 'UTC',
  energy: Energy.medium,
  pinned: true,
);

Materialiser _materialiser([FakeClock? clock]) =>
    Materialiser(clock: clock ?? FakeClock(_now), ids: FakeIds());

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('materialises 90 days ahead, from today, copying series fields', () {
    final plan = _materialiser().plan(_daily(), const []);
    expect(plan.occurrences.first.startUtc, DateTime.utc(2026, 10, 21, 7));
    expect(plan.occurrences.last.startUtc, DateTime.utc(2027, 1, 19, 7));
    expect(plan.occurrences.length, 91);
    expect(plan.materialisedThroughUtc, _now.add(Materialiser.horizon));

    final o = plan.occurrences.first;
    final s = _daily();
    expect(o.seriesId, s.id);
    expect(o.originalStartUtc, o.startUtc);
    expect(
      (o.title, o.durationMin, o.tzId, o.pinned, o.energy, o.colorKey),
      (s.title, s.durationMin, s.tzId, s.pinned, s.energy, s.colorKey),
    );
    expect(o.alerts, isNull, reason: 'inherits series alerts');
    expect(o.status, OccurrenceStatus.planned);
    expect(o.createdAt, _now);
  });

  test(
    'is idempotent: a second run with the first run\'s rows adds nothing',
    () {
      final m = _materialiser();
      final first = m.plan(_daily(), const []);
      final second = m.plan(_daily(), first.occurrences);
      expect(second.isEmpty, isTrue);
      expect(second.subtasks, isEmpty);
    },
  );

  test('next day only adds the newly reachable day', () {
    final clock = FakeClock(_now);
    final m = _materialiser(clock);
    final first = m.plan(_daily(), const []);
    clock.advance(const Duration(days: 1));
    final next = m.plan(_daily(), first.occurrences);
    expect(next.occurrences.map((o) => o.startUtc), [
      DateTime.utc(2027, 1, 20, 7),
    ]);
  });

  test('edited, moved, skipped and deleted rows are never recreated', () {
    final m = _materialiser();
    final rows = m.plan(_daily(), const []).occurrences;
    final kept = [
      rows[0].copyWith(startUtc: DateTime.utc(2026, 10, 21, 18)), // moved
      rows[1].copyWith(status: OccurrenceStatus.skipped),
      rows[2].copyWith(deletedAt: _now), // tombstone
      rows[3].copyWith(title: 'Edited'),
      ...rows.skip(4),
    ];
    expect(m.plan(_daily(), kept).isEmpty, isTrue);
  });

  test('ignores rows of other series and one-offs with the same start', () {
    final m = _materialiser();
    final other = occurrenceFixture().copyWith(
      seriesId: 'other-series',
      originalStartUtc: DateTime.utc(2026, 10, 21, 7),
    );
    final oneOff = occurrenceFixture().copyWith(
      startUtc: DateTime.utc(2026, 10, 22, 7),
    );
    expect(m.plan(_daily(), [other, oneOff]).occurrences.length, 91);
  });

  test('archived or deleted series materialise nothing', () {
    final m = _materialiser();
    expect(
      m.plan(_daily().copyWith(archivedAt: _now), const []).isEmpty,
      isTrue,
    );
    expect(
      m.plan(_daily().copyWith(deletedAt: _now), const []).isEmpty,
      isTrue,
    );
  });

  test('series alerts are inherited, not copied', () {
    final s = _daily().copyWith(alerts: const [Alert(kind: AlertKind.atStart)]);
    final plan = _materialiser().plan(s, const []);
    expect(plan.occurrences.every((o) => o.alerts == null), isTrue);
  });

  test('a series ending before today yields no rows', () {
    final s = _daily().copyWith(untilUtc: DateTime.utc(2026, 10, 10));
    expect(_materialiser().plan(s, const <Occurrence>[]).isEmpty, isTrue);
  });
}
