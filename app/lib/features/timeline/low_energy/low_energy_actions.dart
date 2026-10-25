import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/carry_proposal.dart';
import 'package:dottoday/features/timeline/review/week_review_state.dart';
import 'package:dottoday/features/timeline/state/late_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Low-energy mode's actions (11 D2, docs/09 M12.2). They take the
// ProviderContainer so a menu or card that closes can't cut them short.

/// Switches low-energy mode on (until the next Wake Up) or off; a refused
/// write says why.
void toggleLowEnergy(BuildContext context, {required bool on}) {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  unawaited(
    setLowEnergy(container, on: on).then((result) {
      if (result case Err(:final failure)) {
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    }),
  );
}

/// "Move everything optional to tomorrow?": [tasks] proposed into
/// tomorrow's first free slots (else the Inbox) as a `ProposalSheet`.
/// Nothing moves before Accept (CLAUDE.md §11).
Future<void> proposeTomorrow(
  ProviderContainer container,
  AppLocalizations l10n, {
  required DateTime today,
  required List<Occurrence> tasks,
}) async {
  if (tasks.isEmpty) return;
  final next = await readTimelineDay(
    container,
    DateTime(today.year, today.month, today.day + 1),
  );
  final shape = shapeOf(next);
  container
      .read(activeProposalProvider.notifier)
      .open(
        ProposalRequest(
          proposal: carryProposal(
            userId: tasks.first.userId,
            tasks: tasks,
            days: [
              CarryDay(
                blocks: next.blocks,
                wakeUtc: shape.wakeUtc,
                bedUtc: shape.bedUtc,
              ),
            ],
            nowUtc: container.read(clockProvider).nowUtc(),
          ),
          title: l10n.lowEnergyProposalTitle,
          subtitle: l10n.lowEnergyProposalSubtitle(tasks.length),
          acceptLabel: l10n.lowEnergyProposalAccept,
          acceptedMessage: l10n.lowEnergyProposalAccepted,
        ),
      );
}

/// "Not today" on the next dot, the user's own choice: a one-off moves to
/// tomorrow at the same time; a repeat or a calendar event is skipped for
/// today (tomorrow has its own). With Undo.
Future<void> notToday(
  ProviderContainer container,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  Occurrence o,
  DateTime today,
) async {
  final roll = o.seriesId == null && o.source == OccurrenceSource.user;
  final result = roll
      ? await rollToDay(container, [
          o,
        ], DateTime(today.year, today.month, today.day + 1))
      : await skipTask(container, o);
  reportUndoable(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    result,
    message: (_) => roll
        ? l10n.lowEnergyMovedTomorrow(o.title)
        : l10n.lowEnergySkipped(o.title),
    tokenOf: (t) => t,
  );
}
