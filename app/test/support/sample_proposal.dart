import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';

import '../domain/fixtures.dart';

// A day like `B-ios-rebalance` (America/New_York, the profile fixture's
// zone): Wed 21 Oct 2026, EDT = UTC−4.
final _day = DateTime.utc(2026, 10, 21);

DateTime _at(int hour, [int minute = 0]) =>
    _day.add(Duration(hours: hour + 4, minutes: minute));

const _specs = [
  ('Reply to email', 11, 0, 30, 'indigo', 'mail'),
  ('Lunch with Sam', 12, 30, 45, 'rose', 'meal'),
  ('Spanish lesson', 14, 0, 60, 'teal', 'language'),
  ('Call the dentist', 16, 0, 15, 'amber', 'call'),
  ('Gym', 17, 0, 60, 'mint', 'gym'),
  ('Groceries', 18, 15, 30, 'sky', 'cart'),
  ('Read', 20, 0, 30, 'violet', 'book'),
];

/// The day's tasks as rows (seed them before showing the proposal).
List<Occurrence> sampleDayRows() => [
  for (final (i, (title, h, m, len, color, icon)) in _specs.indexed)
    occurrenceFixture().copyWith(
      id: '01928c3e-0000-7000-8000-00000000c${i}0',
      title: title,
      startUtc: _at(h, m),
      durationMin: len,
      colorKey: color,
      iconKey: icon,
    ),
];

SnapshotDot _dot(Occurrence o) => SnapshotDot(
  id: o.id,
  title: o.title,
  startUtc: o.startUtc!,
  durationMin: o.durationMin,
  colorKey: o.colorKey,
  iconKey: o.iconKey,
  done: false,
);

/// The day as it is, in the one snapshot format (B5).
DaySnapshot sampleBefore() => DaySnapshot(
  generatedAtUtc: _at(11, 25),
  wakeUtc: _at(7),
  bedUtc: _at(22),
  dots: [for (final o in sampleDayRows()) _dot(o)],
  inboxCount: 0,
);

ProposalEdit _edit(int i, Occurrence row) {
  final before = _dot(row);
  return switch (i) {
    1 => ProposalEdit(
      id: 'e$i',
      change: ProposalChange.untouched,
      before: before,
      after: before,
      removable: false,
    ),
    2 => _write(
      i,
      before,
      row.copyWith(durationMin: 45),
      ProposalChange.resized,
    ),
    3 => ProposalEdit(
      id: 'e$i',
      change: ProposalChange.movedToDay,
      before: before,
      movedToUtc: _at(9).add(const Duration(days: 1)),
      occurrences: [
        row.copyWith(startUtc: _at(9).add(const Duration(days: 1))),
      ],
    ),
    _ => _write(
      i,
      before,
      row.copyWith(startUtc: row.startUtc!.add(const Duration(minutes: 25))),
      ProposalChange.shifted,
    ),
  };
}

ProposalEdit _write(
  int i,
  SnapshotDot before,
  Occurrence row,
  ProposalChange change,
) => ProposalEdit(
  id: 'e$i',
  change: change,
  before: before,
  after: _dot(row),
  occurrences: [row],
);

/// A Rebalance-like proposal with the first [edits] (0–7) of the day's
/// tasks changed: shifted +25, pinned, shrunk, moved to tomorrow, shifted…
Proposal sampleProposal(int edits) {
  final rows = sampleDayRows();
  return Proposal(
    userId: userId,
    before: sampleBefore(),
    edits: [for (var i = 0; i < edits; i++) _edit(i, rows[i])],
  );
}
