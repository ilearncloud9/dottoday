import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/shared/proposals/proposal_thread_list.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Rebalance's plan (E-R2-35): each line with the task's faded ring for
/// the day now beside its proposed dot, what changes, and × to keep one
/// as it is. Minimal shows before and after only (docs/14 §3 C1
/// Simplified): no tags and no ×; the plan itself is the same.
class RebalancePlanList extends ConsumerWidget {
  const RebalancePlanList({
    required this.proposal,
    required this.update,
    super.key,
  });

  final Proposal proposal;

  /// Hands up the plan with a line dropped.
  final ValueChanged<Proposal> update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final simple = watchSimplified(ref, FeatureId.rebalance);
    final zone = tz.getLocation(profile.tzId);
    final now = tz.TZDateTime.from(ref.watch(clockProvider).nowUtc(), zone);
    return ProposalThreadList(
      proposal: proposal,
      location: zone,
      use24h: use24hFor(context, profile.settings.use24h),
      today: DateTime(now.year, now.month, now.day),
      onRemove: simple ? null : (id) => update(proposal.without(id)),
      nowRings: true,
      labels: !simple,
    );
  }
}
