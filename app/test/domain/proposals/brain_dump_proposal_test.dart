import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/brain_dump_proposal.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Brain-dump to thread (docs/09 M12.5, 11 B4): one new task per line;
// timed lines at their time, the rest in order into the first free time,
// the Inbox when nothing fits; overlaps shown, never moved.

final _now = DateTime.utc(2026, 10, 21, 9);
var _n = 0;
String _id() => 'new-${_n++}';

Occurrence _busy(int hour, int minutes) => Occurrence(
  id: 'busy-$hour',
  userId: 'u',
  title: 'Busy',
  startUtc: DateTime.utc(2026, 10, 21, hour),
  tzId: 'UTC',
  durationMin: minutes,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

Proposal _plan(List<ProposedDot> dots, {List<Occurrence> blocks = const []}) =>
    brainDumpProposal(
      userId: 'u',
      dots: dots,
      day: DumpDay(
        date: DateTime(2026, 10, 21),
        blocks: blocks,
        wakeUtc: DateTime.utc(2026, 10, 21, 7),
        bedUtc: DateTime.utc(2026, 10, 21, 22),
      ),
      zone: tz.UTC,
      nowUtc: _now,
      defaultDurationMin: 30,
      alerts: const [],
      newId: _id,
    );

void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUp(() => _n = 0);

  test('timed lines at their time; the rest in order from now', () {
    final p = _plan(
      [
        const ProposedDot(title: 'Email Sam'),
        const ProposedDot(title: 'Gym', minuteOfDay: 18 * 60, durationMin: 60),
        const ProposedDot(title: 'Taxes', durationMin: 45),
      ],
      blocks: [_busy(9, 60)],
    );
    final rows = p.toBatch().occurrences;
    Occurrence row(String t) => rows.singleWhere((o) => o.title == t);
    expect(row('Gym').startUtc, DateTime.utc(2026, 10, 21, 18));
    expect(row('Email Sam').startUtc, DateTime.utc(2026, 10, 21, 10));
    expect(row('Email Sam').durationMin, 30, reason: 'the default length');
    expect(row('Taxes').startUtc, DateTime.utc(2026, 10, 21, 10, 30));
    expect(p.edits.every((e) => e.change == ProposalChange.added), isTrue);
  });

  test('no room left: the Inbox, listed last', () {
    final p = _plan([
      const ProposedDot(title: 'Long', durationMin: 1440),
      const ProposedDot(title: 'Short'),
    ]);
    expect(p.edits.last.change, ProposalChange.toInbox);
    expect(p.edits.last.shown!.title, 'Long');
    final long = p.toBatch().occurrences.singleWhere((o) => o.title == 'Long');
    expect(long.startUtc, isNull);
    expect(p.after.dots.map((d) => d.title), ['Short']);
  });

  test('a timed line over a task shows it, untouched', () {
    final p = _plan(
      [const ProposedDot(title: 'Call', minuteOfDay: 9 * 60 + 30)],
      blocks: [_busy(9, 60)],
    );
    final overlap = p.edits.singleWhere(
      (e) => e.change == ProposalChange.overlaps,
    );
    expect(overlap.removable, isFalse);
    expect(p.toBatch().occurrences.map((o) => o.title), ['Call']);
  });

  test('× drops a line; Accept writes exactly what is left', () {
    final p = _plan([
      const ProposedDot(title: 'A'),
      const ProposedDot(title: 'B'),
    ]);
    final left = p.without(p.edits.first.id);
    expect(left.toBatch().occurrences.map((o) => o.title), ['B']);
  });

  test('a model never sets a time the person did not write', () {
    const model = [
      ProposedDot(title: 'Email Sam', minuteOfDay: 0, durationMin: 15),
      ProposedDot(title: 'Bank', minuteOfDay: 900),
    ];
    const rules = [
      ProposedDot(title: 'Email Sam'),
      ProposedDot(title: 'Call the bank', minuteOfDay: 16 * 60),
    ];
    final grounded = groundTimes(model, rules);
    expect(grounded.map((d) => d.minuteOfDay), [null, 16 * 60]);
    expect(grounded.first.durationMin, 15, reason: 'its sizes stay');
    expect(
      groundTimes(model, rules.take(1).toList()).map((d) => d.minuteOfDay),
      [null, null],
      reason: 'not line for line: placement decides',
    );
  });
}
