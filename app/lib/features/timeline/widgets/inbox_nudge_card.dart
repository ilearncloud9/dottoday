import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/inbox/inbox_nudge_seen.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/domain/scheduling/inbox_nudge.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/widgets/prompt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Plan your inbox" (docs/02 F3.3): once a day from Wake Up, with the
/// setting on ([enabled], off by default) and tasks in the Inbox. Plan
/// opens the Inbox; either button puts the card away until tomorrow, on
/// this device ([InboxNudgeSeen]). An invitation, never a count of what
/// is undone (CLAUDE.md §11 no-shame).
class InboxNudgeCard extends ConsumerWidget {
  const InboxNudgeCard({
    required this.enabled,
    required this.today,
    required this.shape,
    required this.now,
    super.key,
  });

  final bool enabled;

  /// Today's local date.
  final DateTime today;
  final DayShape shape;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) return const SizedBox.shrink();
    final seen = ref.watch(inboxNudgeSeenProvider);
    final items = ref.watch(inboxItemsProvider).value;
    // Unknown yet: show nothing rather than flash a card that goes.
    if (!seen.hasValue || items == null) return const SizedBox.shrink();
    final open = openItems(items).length;
    final shows = showsInboxNudge(
      enabled: enabled,
      openCount: open,
      today: today,
      putAwayOn: seen.value,
      nowUtc: now,
      wakeUtc: shape.wakeUtc,
      bedUtc: shape.bedUtc,
    );
    if (!shows) return const SizedBox.shrink();
    final l10n = context.l10n;
    void putAway() =>
        unawaited(ref.read(inboxNudgeSeenProvider.notifier).putAway(today));
    return PromptCard(
      title: l10n.inboxNudgeTitle,
      child: PromptNudge(
        detail: l10n.inboxNudgeDetail(open),
        action: l10n.inboxNudgeAction,
        onAction: () {
          putAway();
          context.go(AppRoutes.inbox);
        },
        onNotNow: putAway,
      ),
    );
  }
}
