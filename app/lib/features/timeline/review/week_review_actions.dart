import 'dart:async';
import 'dart:typed_data';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/carry_proposal.dart';
import 'package:dottoday/features/timeline/review/week_review_state.dart';
import 'package:dottoday/features/timeline/review/week_share.dart';
import 'package:dottoday/features/timeline/state/late_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// The weekly review's three actions (11 D1, docs/09 M12.1). They take the
// ProviderContainer because the review sheet closes first.

/// "Place": the unfinished [tasks] of [week] proposed into the seven days
/// after it (a `ProposalSheet`); nothing moves before Accept.
Future<void> placeInNextWeek(
  ProviderContainer container,
  AppLocalizations l10n, {
  required List<DateTime> week,
  required List<Occurrence> tasks,
}) async {
  if (tasks.isEmpty) return;
  final days = await nextWeekDays(container, week);
  final proposal = carryProposal(
    userId: tasks.first.userId,
    tasks: tasks,
    days: days,
    nowUtc: container.read(clockProvider).nowUtc(),
  );
  container
      .read(activeProposalProvider.notifier)
      .open(
        ProposalRequest(
          proposal: proposal,
          title: l10n.weekCarryTitle,
          subtitle: l10n.weekCarrySubtitle(tasks.length),
          acceptLabel: l10n.weekCarryAccept,
          acceptedMessage: l10n.weekCarryAccepted,
        ),
      );
}

/// "Leave in Inbox": the user's own choice, so it writes at once, with
/// Undo (as the Day review's "Send to Inbox").
Future<void> leaveInInbox(
  ProviderContainer container,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  List<Occurrence> tasks,
) async {
  if (tasks.isEmpty) return;
  reportUndoable(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    await sendToInbox(container, tasks),
    message: (_) => l10n.snackSentToInbox(tasks.length),
    tokenOf: (t) => t,
  );
}

/// "Share image": the card behind [boundary] as a PNG through the OS
/// share sheet (a download on the web without Web Share). Named by the
/// week's first day, never by its content.
Future<void> shareWeekImage(
  BuildContext context,
  GlobalKey boundary,
  DateTime firstDay,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final box = context.findRenderObject();
  final origin = box is RenderBox
      ? box.localToGlobal(Offset.zero) & box.size
      : null;
  final png = await captureWeekImage(boundary);
  if (png == null) return;
  const fileDate = 'yyyy-MM-dd'; // l10n-ignore: a file name's date
  final day = DateFormat(fileDate).format(firstDay);
  try {
    await container
        .read(fileGatewayProvider)
        .shareImage(
          Uint8List.fromList(png),
          name: 'dottoday-week-$day.png', // l10n-ignore: a file name
          origin: origin,
        );
  } on Exception catch (e, st) {
    container
        .read(loggerProvider)
        .error(
          'week_review.share_failed', // l10n-ignore: log event, never shown
          error: e,
          stackTrace: st,
        );
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportHandOffFailed)));
  }
}
