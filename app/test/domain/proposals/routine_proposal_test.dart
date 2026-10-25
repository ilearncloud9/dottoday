import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/proposals/routine_proposal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// A routine drop's proposal (docs/09 M11.4): "added" lines for the steps,
// an "overlaps" line for each task already there that a step meets, in
// day order; Accept writes only the steps.

DateTime _at(int h, [int m = 0]) => DateTime.utc(2026, 10, 21, h, m);

Occurrence _o(String id, int h, int m, int len, {bool done = false}) =>
    occurrenceFixture().copyWith(
      id: id,
      startUtc: _at(h, m),
      durationMin: len,
      status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
    );

void main() {
  test('steps added, overlapped tasks shown and kept, day order', () {
    final day = [
      _o('gym', 17, 0, 60),
      _o('read', 20, 0, 30),
      _o('call', 17, 30, 15, done: true),
    ];
    final steps = [_o('pack', 17, 30, 10), _o('lift', 17, 40, 60)];
    final p = routineProposal(
      userId: userId,
      day: day,
      tasks: steps,
      wakeUtc: _at(7),
      bedUtc: _at(22),
      nowUtc: _at(9),
    );
    expect(p.edits.map((e) => (e.id, e.change)), [
      ('gym', ProposalChange.overlaps),
      ('pack', ProposalChange.added),
      ('lift', ProposalChange.added),
    ]);
    expect(p.edits.first.removable, isFalse);
    expect(p.toBatch().occurrences.map((o) => o.id), ['pack', 'lift']);
    expect(p.without('gym').edits, hasLength(3), reason: 'not removable');
  });
}
