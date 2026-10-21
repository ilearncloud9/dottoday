import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/layout/block_facts.dart';
import 'package:dottoday/features/timeline/widgets/block_label.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/fixtures.dart';

void main() {
  final o = occurrenceFixture(); // 08:00Z for 45 min
  final before = DateTime.utc(2026, 10, 21, 8, 30);
  final after = DateTime.utc(2026, 10, 21, 9);

  test('overdue only once a planned block has ended', () {
    expect(BlockFacts.of(o, nowUtc: before).overdue, isFalse);
    expect(BlockFacts.of(o, nowUtc: o.endUtc).overdue, isTrue);
    expect(BlockFacts.of(o, nowUtc: after).overdue, isTrue);
    expect(BlockFacts.of(o, nowUtc: null).overdue, isFalse);
    final done = o.copyWith(status: OccurrenceStatus.done);
    expect(BlockFacts.of(done, nowUtc: after).overdue, isFalse);
    final skipped = o.copyWith(status: OccurrenceStatus.skipped);
    expect(BlockFacts.of(skipped, nowUtc: after).overdue, isFalse);
  });

  test('alerts: own override wins, else inherited from the series', () {
    const two = [Alert(kind: AlertKind.atStart), Alert(kind: AlertKind.atEnd)];
    expect(BlockFacts.of(o, nowUtc: null, seriesAlerts: two).alertCount, 2);
    final none = o.copyWith(alerts: const []);
    expect(BlockFacts.of(none, nowUtc: null, seriesAlerts: two).alertCount, 0);
  });

  test('badges from the row', () {
    final f = BlockFacts.of(
      o.copyWith(
        pinned: true,
        seriesId: 's',
        source: OccurrenceSource.calendar,
      ),
      nowUtc: null,
      subtasks: (done: 2, total: 3),
    );
    expect(
      (f.pinned, f.recurring, f.calendar, f.hasSubtasks),
      (true, true, true, true),
    );
  });

  test('label reads like docs/03 §4, with every badge in words', () {
    final l10n = AppLocalizationsEn();
    final f = BlockFacts.of(
      o.copyWith(
        pinned: true,
        seriesId: 's',
        alerts: const [Alert(kind: AlertKind.atStart)],
      ),
      nowUtc: after,
      subtasks: (done: 2, total: 3),
      endsAfter: true,
    );
    expect(
      blockLabel(
        l10n,
        title: 'Gym',
        start: '7:00 AM',
        end: '7:45 AM',
        facts: f,
      ),
      'Gym, 7:00 AM to 7:45 AM, 2 of 3 subtasks done, not done yet, '
      'recurring, pinned, 1 alert, continues into the next day',
    );
    final done = BlockFacts.of(
      o.copyWith(status: OccurrenceStatus.done),
      nowUtc: after,
    );
    expect(
      blockLabel(l10n, title: 'Gym', start: 'a', end: 'b', facts: done),
      'Gym, a to b, done',
    );
  });

  test('equality is by value', () {
    expect(BlockFacts.of(o, nowUtc: null), BlockFacts.of(o, nowUtc: null));
    expect(
      BlockFacts.of(o, nowUtc: null).hashCode,
      BlockFacts.of(o, nowUtc: null).hashCode,
    );
  });
}
