import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/proposals/rebalance_proposal.dart';
import 'package:dottoday/domain/scheduling/rebalance.dart';

import 'sample_proposal.dart';

// Rebalance on the `B-ios-rebalance` day (docs/09 M11.1): New York, Wed
// 21 Oct 2026; Deep work ran 25 min over, so from 11:00 the rest of the
// day is 25 min late. Lunch with Sam is pinned.

/// 11:25 in New York.
final rebalanceNow = DateTime.utc(2026, 10, 21, 15, 25);

/// 11:00 in New York, where the delay starts.
final rebalanceFrom = DateTime.utc(2026, 10, 21, 15);

/// Wake Up 7:00 and Wind Down 22:00 in New York.
final rebalanceWake = DateTime.utc(2026, 10, 21, 11);
final rebalanceBed = DateTime.utc(2026, 10, 22, 2);

/// The sample day with lunch pinned.
List<Occurrence> rebalanceDayRows() => [
  for (final o in sampleDayRows())
    o.title == 'Lunch with Sam' ? o.copyWith(pinned: true) : o,
];

/// The proposal for [rebalanceDayRows] under [options].
Proposal rebalanceSample([
  RebalanceOptions options = const RebalanceOptions(),
]) {
  final day = rebalanceDayRows();
  return rebalanceProposal(
    day: day,
    plan: rebalance(
      day,
      fromUtc: rebalanceFrom,
      deltaMin: 25,
      bedUtc: rebalanceBed,
      options: options,
    ),
    wakeUtc: rebalanceWake,
    bedUtc: rebalanceBed,
    nowUtc: rebalanceNow,
  );
}
