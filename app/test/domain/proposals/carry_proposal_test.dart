import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/carry_proposal.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:flutter_test/flutter_test.dart';

// Carrying tasks to later days as a proposal (11 D1 weekly review, D2
// low-energy): each into the first free slot that fits, in plan order,
// never before now, else the Inbox; nothing is written until Accept.

final _now = DateTime.utc(2026, 10, 25, 20, 30);

Occurrence _task(String id, DateTime start, int minutes, {int moves = 0}) =>
    Occurrence(
      id: id,
      userId: 'u',
      title: id,
      startUtc: start,
      tzId: 'UTC',
      durationMin: minutes,
      moveCount: moves,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

CarryDay _day(int d, {List<Occurrence> blocks = const []}) => CarryDay(
  blocks: blocks,
  wakeUtc: DateTime.utc(2026, 10, d, 7),
  bedUtc: DateTime.utc(2026, 10, d, 22),
);

void main() {
  test('each task takes the first free time, in plan order', () {
    final busy = _task('busy', DateTime.utc(2026, 10, 26, 7), 60);
    final p = carryProposal(
      userId: 'u',
      tasks: [
        _task('b', DateTime.utc(2026, 10, 20, 14), 30),
        _task('a', DateTime.utc(2026, 10, 20, 9), 45),
      ],
      days: [
        _day(26, blocks: [busy]),
        _day(27),
      ],
      nowUtc: _now,
    );
    expect(p.edits.map((e) => e.id), ['a', 'b']);
    expect(p.edits.first.movedToUtc, DateTime.utc(2026, 10, 26, 8));
    expect(p.edits.last.movedToUtc, DateTime.utc(2026, 10, 26, 8, 45));
    expect(p.edits.every((e) => e.change == ProposalChange.movedToDay), isTrue);
  });

  test('never before now: a day that is over is skipped', () {
    final p = carryProposal(
      userId: 'u',
      tasks: [_task('a', DateTime.utc(2026, 10, 20, 9), 30)],
      days: [_day(25), _day(26)],
      nowUtc: DateTime.utc(2026, 10, 25, 22, 30),
    );
    expect(p.edits.single.movedToUtc, DateTime.utc(2026, 10, 26, 7));
  });

  test('no room anywhere: the Inbox', () {
    final p = carryProposal(
      userId: 'u',
      tasks: [_task('long', DateTime.utc(2026, 10, 20, 9), 16 * 60)],
      days: [_day(26)],
      nowUtc: _now,
    );
    expect(p.edits.single.movedToUtc, isNull);
    expect(p.toBatch().occurrences.single.startUtc, isNull);
  });

  test('each move counts for Unstick; × keeps a task where it is', () {
    final p = carryProposal(
      userId: 'u',
      tasks: [
        _task('a', DateTime.utc(2026, 10, 20, 9), 30, moves: 1),
        _task('b', DateTime.utc(2026, 10, 20, 10), 30),
      ],
      days: [_day(26)],
      nowUtc: _now,
    );
    expect(p.toBatch().occurrences.first.moveCount, 2);
    final kept = p.without('a');
    expect(kept.toBatch().occurrences.map((o) => o.id), ['b']);
    expect(kept.after.dots.map((d) => d.id), isNot(contains('b')));
  });
}
