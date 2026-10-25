import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/proposals/proposal_acceptor.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:dottoday/shared/proposals/proposal_thread_list.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The open [ProposalRequest] as a `ProposalSheet` (docs/09 M10.2): the
/// flow's own body or the now/proposed change list; × on a line drops it;
/// Accept writes once through `ProposalAcceptor` and offers Undo for 30 s;
/// Discard writes nothing. [onClosed] pops the sheet's route on phones.
class ProposalView extends ConsumerWidget {
  const ProposalView({this.onClosed, super.key});

  final VoidCallback? onClosed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(activeProposalProvider);
    final profile = ref.watch(currentProfileProvider).value;
    if (request == null || profile == null) return const SizedBox.shrink();
    final active = ref.read(activeProposalProvider.notifier);
    final zone = tz.getLocation(profile.tzId);
    final now = tz.TZDateTime.from(ref.watch(clockProvider).nowUtc(), zone);
    final proposal = request.proposal;
    final body =
        request.body?.call(context, proposal, active.update) ??
        ProposalThreadList(
          proposal: proposal,
          location: zone,
          use24h: use24hFor(context, profile.settings.use24h),
          today: DateTime(now.year, now.month, now.day),
          onRemove: active.removeEdit,
        );
    return ProposalSheet(
      title: request.title,
      subtitle: request.subtitle,
      originLabel: request.originLabel,
      acceptLabel: request.acceptLabel,
      failure: request.failure,
      busy: request.busy,
      body: body,
      lead: request.lead?.call(context, proposal),
      below: request.below?.call(context, proposal),
      options:
          request.options?.call(context, proposal, active.update) ?? const [],
      footnote: request.footnote,
      onAccept: (request.draftOnly ? proposal.edits.isEmpty : proposal.isEmpty)
          ? null
          : () => unawaited(_accept(context, ref, request)),
      onDiscard: () {
        active.close();
        onClosed?.call();
      },
    );
  }

  Future<void> _accept(
    BuildContext context,
    WidgetRef ref,
    ProposalRequest request,
  ) async {
    final active = ref.read(activeProposalProvider.notifier);
    if (request.draftOnly) {
      active.close();
      onClosed?.call();
      return request.onAccepted?.call(request.proposal);
    }
    if (!active.beginAccept()) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    final result = await ref
        .read(proposalAcceptorProvider)
        .accept(request.proposal);
    switch (result) {
      case Ok(:final value):
        active.close();
        onClosed?.call();
        request.onAccepted?.call(request.proposal);
        if (value == null) return;
        showUndoSnackbarOn(
          messenger,
          l10n,
          message: request.acceptedMessage,
          onUndo: () => unawaited(undo.undo(value)),
        );
      case Err(:final failure):
        active.failed(failure);
    }
  }
}
