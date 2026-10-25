import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_proposal.g.dart';

/// Draws a flow's own editable middle of the proposal sheet (Break it
/// down's mini thread); [update] replaces the proposal as the user edits.
typedef ProposalBodyBuilder =
    Widget Function(
      BuildContext context,
      Proposal proposal,
      ValueChanged<Proposal> update,
    );

/// The rule chips under the card (`B-ios-rebalance`); a chip that changes
/// the rules hands a recomputed proposal to [update].
typedef ProposalOptionsBuilder =
    List<Widget> Function(
      BuildContext context,
      Proposal proposal,
      ValueChanged<Proposal> update,
    );

/// Draws a read-only part of the sheet from the current proposal (the
/// task's identity row above the card, the total below it).
typedef ProposalPartBuilder =
    Widget Function(BuildContext context, Proposal proposal);

/// What a flow asks `ProposalSheet` to show (11 §0 B3). Texts arrive
/// localised; [body] defaults to the now/proposed change list.
@immutable
final class ProposalRequest {
  const ProposalRequest({
    required this.proposal,
    required this.title,
    required this.acceptedMessage,
    this.subtitle,
    this.originLabel,
    this.acceptLabel,
    this.body,
    this.lead,
    this.below,
    this.options,
    this.footnote,
    this.onAccepted,
    this.failure,
    this.busy = false,
    this.draftOnly = false,
    this.overSheet = false,
  });

  final Proposal proposal;
  final String title;
  final String? subtitle;

  /// "on-device" / "Your usual" chip by the title (`B-ios-break-it-down`).
  final String? originLabel;

  /// "Accept" unless the flow says otherwise ("Accept plan").
  final String? acceptLabel;

  /// The Undo snackbar's text after Accept.
  final String acceptedMessage;
  final ProposalBodyBuilder? body;

  /// Above the card (`B-ios-break-it-down`: the task being broken down).
  final ProposalPartBuilder? lead;

  /// Under the card ("Total 1 h 40 · the dot grows to fit").
  final ProposalPartBuilder? below;

  /// Rule chips under the card ("Shift followers", Rebalance).
  final ProposalOptionsBuilder? options;

  /// Replaces "Nothing is saved until you accept" ("Nothing moves until
  /// you accept · Undo for 30 s after").
  final String? footnote;

  /// Accept hands the proposal back to an unsaved draft (Add step 1),
  /// which writes it with the task on Save: no write and no Undo here,
  /// and Accept needs an edit rather than rows.
  final bool draftOnly;

  /// Opened from a sheet or popover (Add): shown above it as a sheet or
  /// popover at every width, never in the panel the popover covers.
  final bool overSheet;

  /// After the write committed, with the proposal as accepted (e.g. to
  /// remember "My usual breakdown").
  final void Function(Proposal accepted)? onAccepted;

  /// The last Accept's failure, shown on the sheet with Try again.
  final AppFailure? failure;

  /// Accept is writing: a second tap does nothing (one batch, one Undo).
  final bool busy;

  ProposalRequest copyWith({
    Proposal? proposal,
    AppFailure? failure,
    bool busy = false,
  }) => ProposalRequest(
    proposal: proposal ?? this.proposal,
    title: title,
    acceptedMessage: acceptedMessage,
    subtitle: subtitle,
    originLabel: originLabel,
    acceptLabel: acceptLabel,
    body: body,
    lead: lead,
    below: below,
    options: options,
    footnote: footnote,
    onAccepted: onAccepted,
    failure: failure,
    busy: busy,
    draftOnly: draftOnly,
    overSheet: overSheet,
  );
}

/// The proposal on screen, if any: a bottom sheet on phones, the right-hand
/// panel at the expanded width (docs/10 §4 "no sheets at expanded"). Held
/// in core, like `EditingTask`, so any feature can open one without
/// importing the sheet. Nothing here writes; Accept goes through
/// `ProposalAcceptor`.
@Riverpod(keepAlive: true)
class ActiveProposal extends _$ActiveProposal {
  @override
  ProposalRequest? build() => null;

  void open(ProposalRequest request) => state = request;

  /// The user edited the proposal (dropped a line, changed a step).
  void update(Proposal proposal) => state = state?.copyWith(proposal: proposal);

  /// × on a line of the change list.
  void removeEdit(String editId) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(proposal: current.proposal.without(editId));
  }

  /// Accept started; false when it was already running.
  bool beginAccept() {
    final current = state;
    if (current == null || current.busy) return false;
    state = current.copyWith(busy: true);
    return true;
  }

  /// Accept didn't land: the sheet stays with the proposal and says so.
  void failed(AppFailure failure) => state = state?.copyWith(failure: failure);

  /// Discard, ×, Esc, a swipe down, or after Accept.
  void close() => state = null;
}
