import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sample_proposal.dart';

// B3 (docs/09 M10.2): the proposed thread is the day with the remaining
// edits applied; × drops a line (never an untouched one); Accept writes
// every remaining row once.

void main() {
  test('after = before with the edits applied, earliest first', () {
    final p = sampleProposal(4);
    final after = p.after.dots;
    final byId = {for (final d in after) d.id: d};
    final rows = sampleDayRows();
    // Shifted +25, untouched, shrunk to 45, moved off the day.
    expect(
      byId[rows[0].id]!.startUtc,
      rows[0].startUtc!.add(const Duration(minutes: 25)),
    );
    expect(byId[rows[1].id]!.startUtc, rows[1].startUtc);
    expect(byId[rows[2].id]!.durationMin, 45);
    expect(byId.containsKey(rows[3].id), isFalse);
    expect(after.length, 6);
    expect(
      after.map((d) => d.startUtc),
      orderedEquals([...after.map((d) => d.startUtc)]..sort()),
    );
    expect(p.after.bedUtc, p.before.bedUtc);
  });

  test('deltas and an added dot', () {
    final p = sampleProposal(3);
    expect(p.edits[0].deltaMin, 25);
    expect(p.edits[1].deltaMin, 0);
    expect(p.edits[2].deltaMin, -15);
    final added = ProposalEdit(
      id: 'new',
      change: ProposalChange.added,
      after: p.before.dots.first,
    );
    expect(p.withEdits([added]).after.dots.length, 8);
  });

  test('without drops a removable line and keeps untouched ones', () {
    final p = sampleProposal(3);
    expect(p.without('e0').edits.map((e) => e.id), ['e1', 'e2']);
    expect(p.without('e1').edits.length, 3);
    expect(
      p.without('e0').after.dots.first.startUtc,
      p.before.dots.first.startUtc,
    );
  });

  test('toBatch: remaining rows once, the later edit winning', () {
    final p = sampleProposal(4);
    final batch = p.toBatch();
    expect(batch.occurrences.length, 3, reason: 'untouched writes nothing');
    expect(batch.userId, p.userId);
    final row = sampleDayRows().first;
    final twice = p.withEdits([
      ...p.edits,
      ProposalEdit(
        id: 'again',
        change: ProposalChange.resized,
        occurrences: [row.copyWith(durationMin: 50)],
      ),
    ]).toBatch();
    expect(
      twice.occurrences.where((o) => o.id == row.id).single.durationMin,
      50,
    );
  });

  test('nothing left to write is empty', () {
    expect(sampleProposal(0).isEmpty, isTrue);
    expect(sampleProposal(2).without('e0').isEmpty, isTrue);
    expect(sampleProposal(1).isEmpty, isFalse);
  });
}
