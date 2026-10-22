import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// Fits, auto-plan and sort for the Mac/web Inbox (M3e.2, `A-mac-inbox`).
// Days run 07:00–22:00 UTC; "now" is 09:00 on day 0.

DateTime _at(int day, int h, [int m = 0]) =>
    DateTime.utc(2026, 10, 21 + day, h, m);

Occurrence _item(String id, int minutes) => occurrenceFixture().copyWith(
  id: id,
  title: id,
  startUtc: null,
  durationMin: minutes,
);

Occurrence _block(int day, int h, int minutes) => occurrenceFixture().copyWith(
  id: 'b$day$h',
  startUtc: _at(day, h),
  durationMin: minutes,
);

DayRoom _room(int day, List<Occurrence> blocks) => DayRoom(
  blocks: blocks,
  fromUtc: day == 0 ? _at(0, 9) : _at(day, 7),
  startUtc: _at(day, 7),
  endUtc: _at(day, 22),
);

void main() {
  // Today is booked 09:00–21:30 but for one free hour at 12:00.
  final today = _room(0, [_block(0, 9, 180), _block(0, 13, 510)]);
  final week = [today, _room(1, const []), _room(2, const [])];

  test('first fit: today if it fits, else the next day with room', () {
    final run = firstFit(_item('run', 60), week)!;
    expect((run.day, run.slot.startUtc), (0, _at(0, 12)));
    final taxes = firstFit(_item('taxes', 90), week)!;
    expect(taxes.day, 1);
    expect(taxes.slot.startUtc, _at(1, 7));
    expect(firstFit(_item('huge', 24 * 60), week), isNull);
  });

  test('auto-plan books one after another, the rest stays put', () {
    final plan = autoPlan([
      _item('a', 60),
      _item('b', 60),
      _item('c', 30),
      _item('huge', 24 * 60),
    ], week);
    expect(plan.placed.map((p) => (p.item.id, p.slot.startUtc)), [
      ('a', _at(0, 12)),
      ('b', _at(1, 7)),
      ('c', _at(0, 21, 30)), // today's last half hour
    ]);
    expect(plan.unplaced.map((o) => o.id), ['huge']);
  });

  test('auto-plan skips done items', () {
    final done = _item('done', 30).copyWith(status: OccurrenceStatus.done);
    expect(autoPlan([done], week).placed, isEmpty);
  });

  test('sort: added keeps order; duration; fit puts no-room last', () {
    final items = [_item('long', 90), _item('short', 15), _item('huge', 1500)];
    WeekFit? fit(Occurrence o) => firstFit(o, week);
    expect(sortInbox(items, InboxSort.added, fit).map((o) => o.id), [
      'long',
      'short',
      'huge',
    ]);
    expect(sortInbox(items, InboxSort.duration, fit).map((o) => o.id), [
      'short',
      'long',
      'huge',
    ]);
    expect(sortInbox(items, InboxSort.fit, fit).map((o) => o.id), [
      'short',
      'long',
      'huge',
    ]);
  });
}
