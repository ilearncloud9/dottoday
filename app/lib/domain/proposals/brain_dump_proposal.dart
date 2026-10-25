import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/proposals/rebalance_proposal.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/scheduling/slot_finder.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:timezone/timezone.dart' as tz;

/// A model's dots with times only where the person wrote one (11 B4,
/// docs/09 M12.5): [rules] is Quick Add's parse of the same text. When the
/// two agree line for line, each dot keeps the parsed time (or none);
/// otherwise every model time is dropped and placement decides. A model
/// may name and size tasks, never invent when they happen (the iPhone
/// sweep found it putting untimed lines at midnight).
///
/// ```dart
/// groundTimes(model.dots, rules.dots).map((d) => d.minuteOfDay);
/// ```
List<ProposedDot> groundTimes(
  List<ProposedDot> model,
  List<ProposedDot> rules,
) {
  final aligned = model.length == rules.length;
  return [
    for (final (i, d) in model.indexed)
      ProposedDot(
        title: d.title,
        durationMin: d.durationMin,
        minuteOfDay: aligned ? rules[i].minuteOfDay : null,
      ),
  ];
}

/// What a brain dump lands on: a day as it is.
final class DumpDay {
  const DumpDay({
    required this.date,
    required this.blocks,
    required this.wakeUtc,
    required this.bedUtc,
  });

  /// Local date (y/m/d).
  final DateTime date;
  final List<Occurrence> blocks;
  final DateTime wakeUtc;
  final DateTime bedUtc;
}

/// Brain-dump to thread (11 B4, docs/09 M12.5) as a [Proposal]: one new
/// task per line (R-07). A line with a time sits at it on [day]; the
/// others, in the order they were written, take the day's first free time
/// that fits from Wake Up (never before [nowUtc]); a line with no room goes
/// to the Inbox. A task already there that a timed line overlaps gets an
/// "already here · overlaps" line and never moves. × drops a line; Accept
/// writes exactly the lines left (CLAUDE.md §11 proposal rule).
///
/// ```dart
/// brainDumpProposal(userId: me, dots: plan.dots, day: today, ...).edits;
/// ```
Proposal brainDumpProposal({
  required String userId,
  required List<ProposedDot> dots,
  required DumpDay day,
  required tz.Location zone,
  required DateTime nowUtc,
  required int defaultDurationMin,
  required List<Alert> alerts,
  required String Function() newId,
}) {
  final timed = scheduledBlocks(day.blocks);
  final taken = [...timed];
  Occurrence task(ProposedDot d, DateTime? start) => Occurrence(
    id: newId(),
    userId: userId,
    title: d.title,
    startUtc: start,
    tzId: zone.name,
    durationMin: d.durationMin ?? defaultDurationMin,
    alerts: alerts,
    createdAt: nowUtc,
    updatedAt: nowUtc,
  );
  final added = <Occurrence>[];
  for (final d in dots.where((d) => d.minuteOfDay != null)) {
    final start = ClockTime.fromMinutes(d.minuteOfDay!).onDate(zone, day.date);
    added.add(task(d, start));
  }
  taken.addAll(added);
  final from = nowUtc.isAfter(day.wakeUtc) ? nowUtc : day.wakeUtc;
  for (final d in dots.where((d) => d.minuteOfDay == null)) {
    final minutes = d.durationMin ?? defaultDurationMin;
    final slot = findSlots(
      taken,
      minutes,
      fromUtc: from,
      dayStartUtc: day.wakeUtc,
      dayEndUtc: day.bedUtc,
      limit: 1,
    ).firstOrNull;
    final o = task(d, slot?.startUtc);
    if (slot != null) taken.add(o);
    added.add(o);
  }
  return Proposal(
    userId: userId,
    before: DaySnapshot(
      generatedAtUtc: nowUtc,
      wakeUtc: day.wakeUtc,
      bedUtc: day.bedUtc,
      dots: [
        for (final o in timed)
          if (o.status != OccurrenceStatus.skipped) snapshotDotOf(o)!,
      ],
      inboxCount: 0,
    ),
    // Day order, then the Inbox lines in the order they were written.
    edits: [
      ...[
        for (final o in added)
          if (o.startUtc != null)
            ProposalEdit(
              id: o.id,
              change: ProposalChange.added,
              after: snapshotDotOf(o),
              occurrences: [o],
            ),
        for (final o in timed)
          if (o.status == OccurrenceStatus.planned &&
              added.any((a) => a.startUtc != null && _overlap(o, a)))
            ProposalEdit(
              id: o.id,
              change: ProposalChange.overlaps,
              before: snapshotDotOf(o),
              after: snapshotDotOf(o),
              removable: false,
            ),
      ]..sort(_byStart),
      for (final o in added)
        if (o.startUtc == null)
          ProposalEdit(
            id: o.id,
            change: ProposalChange.toInbox,
            occurrences: [o],
          ),
    ],
  );
}

int _byStart(ProposalEdit a, ProposalEdit b) {
  final byStart = (a.after ?? a.before)!.startUtc.compareTo(
    (b.after ?? b.before)!.startUtc,
  );
  return byStart != 0 ? byStart : a.id.compareTo(b.id);
}

bool _overlap(Occurrence a, Occurrence b) =>
    a.startUtc!.isBefore(b.endUtc!) && b.startUtc!.isBefore(a.endUtc!);
