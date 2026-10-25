import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/calendar/calendar_shift_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/proposals/rebalance_proposal.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/rebalance.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/rebalance_rules.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

// Rebalance (11 C1, docs/09 M11.1): Running late, a task that ran over
// its end by more than [rebalanceOverrunMin], and "Shift the rest" with
// more than [rebalanceFollowers] tasks behind it open a ProposalSheet
// instead of moving anything. Nothing is written until Accept.

/// Minutes past its end after which an unticked task opens Rebalance.
const rebalanceOverrunMin = 10;

/// "Shift the rest" moving more tasks than this asks first.
const rebalanceFollowers = 2;

/// Opens the Rebalance proposal for [today]: a delay of [deltaMin] at
/// [fromUtc], explained by [subtitle]. Tomorrow's day is read so a task
/// pushed past Bedtime lands in its first free slot. [keep] never moves
/// (the event a calendar move is about, M11.1b); [title] heads the sheet
/// (default "Running late").
Future<void> openRebalance(
  ProviderContainer container,
  AppLocalizations l10n, {
  required DateTime today,
  required DateTime fromUtc,
  required int deltaMin,
  required String subtitle,
  Set<String> keep = const {},
  String? title,
}) async {
  final data = await _day(container, today);
  final later = await _day(
    container,
    DateTime(today.year, today.month, today.day + 1),
  );
  if (data.blocks.isEmpty) return;
  final shape = _shape(data);
  final tomorrow = _shape(later);
  final next = RebalanceTomorrow(
    blocks: later.blocks,
    wakeUtc: tomorrow.wakeUtc,
    bedUtc: tomorrow.bedUtc,
  );
  final fixed = container.read(readOnlyCalendarIdsProvider).value;
  final now = container.read(clockProvider).nowUtc();
  Proposal compute(RebalanceOptions options) => rebalanceProposal(
    day: data.blocks,
    plan: rebalance(
      data.blocks,
      fromUtc: fromUtc,
      deltaMin: deltaMin,
      bedUtc: shape.bedUtc,
      options: options,
      tomorrow: next,
      // Unknown read-only calendars yet: no event moves (docs/09 M7.6).
      includeCalendar: fixed != null && data.settings.includeCalendarInShift,
      readOnlyIds: {...?fixed, ...keep},
    ),
    wakeUtc: shape.wakeUtc,
    bedUtc: shape.bedUtc,
    nowUtc: now,
  );
  container
      .read(activeProposalProvider.notifier)
      .open(
        rebalanceRequest(
          l10n,
          title: title,
          subtitle: subtitle,
          compute: compute,
        ),
      );
}

/// Rebalance's sheet (`B-ios-rebalance`) for the plan [compute] makes
/// under the rules the chips set.
ProposalRequest rebalanceRequest(
  AppLocalizations l10n, {
  required String subtitle,
  required Proposal Function(RebalanceOptions options) compute,
  String? title,
}) => ProposalRequest(
  proposal: compute(const RebalanceOptions()),
  title: title ?? l10n.runningLate,
  subtitle: subtitle,
  acceptLabel: l10n.rebalanceAccept,
  acceptedMessage: l10n.rebalanceAccepted,
  footnote: l10n.rebalanceFootnote,
  options: (context, proposal, update) => [
    RebalanceRules(onChanged: (o) => update(compute(o))),
  ],
);

/// [date]'s timeline, held while it loads: nothing may be watching it
/// (tomorrow, or a closed sheet's today), and an unwatched day is
/// disposed mid-load.
Future<TimelineData> _day(ProviderContainer container, DateTime date) async {
  final hold = container.listen(timelineDataProvider(date), (_, _) {});
  try {
    return await container.read(timelineDataProvider(date).future);
  } finally {
    hold.close();
  }
}

DayShape _shape(TimelineData data) => DayShape.on(
  data.day.location,
  data.day.date,
  data.settings.boundaryFor(data.day.weekday),
);

/// "Shift the rest" for [live], [overrunMin] over its next task: opens
/// Rebalance and returns true when it would move more than
/// [rebalanceFollowers] tasks; false leaves the plain shift to the caller.
bool rebalanceShiftRest(
  BuildContext context,
  List<Occurrence> day,
  Occurrence live,
  int overrunMin,
) {
  if (_followers(day, live, overrunMin) <= rebalanceFollowers) return false;
  final l10n = context.l10n;
  final local = tz.TZDateTime.from(live.startUtc!, tz.getLocation(live.tzId));
  unawaited(
    openRebalance(
      ProviderScope.containerOf(context, listen: false),
      l10n,
      today: DateTime(local.year, local.month, local.day),
      fromUtc: live.endUtc!.subtract(Duration(minutes: overrunMin)),
      deltaMin: overrunMin,
      subtitle: l10n.rebalanceRunsOver(
        live.title,
        formatDurationShort(l10n, overrunMin),
      ),
    ),
  );
  return true;
}

/// How many tasks the plain "Shift the rest" would move.
int _followers(List<Occurrence> day, Occurrence live, int overrunMin) =>
    const DaySchedulerService()
        .runningLate(
          day,
          live.endUtc!.subtract(Duration(minutes: overrunMin)),
          overrunMin,
        )
        .report
        .movedIds
        .length;
