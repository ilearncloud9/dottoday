import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/chips/dot_tag.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:dottoday/shared/sheets/sheet_header.dart';
import 'package:flutter/material.dart';

/// B3 (11 §0): the one sheet every model- or rule-made change is shown in
/// before anything is written — Break it down, brain-dump, Rebalance,
/// routines, the reality thread (CLAUDE.md §11 "Proposal rule"). Chrome
/// from E-Phones-2 (ED-150): the sheet title with an origin tag and Close,
/// a subtitle, the [body] in a card, optional [options],
/// Accept, Discard, and "Nothing is saved until you accept".
///
/// Values and callbacks only: the caller writes on [onAccept]. Used as a
/// bottom sheet on phones and as the right-hand panel at the expanded width
/// (docs/10 §4).
class ProposalSheet extends StatelessWidget {
  const ProposalSheet({
    required this.title,
    required this.body,
    required this.onAccept,
    required this.onDiscard,
    this.subtitle,
    this.originLabel,
    this.acceptLabel,
    this.options = const [],
    this.hint,
    this.lead,
    this.below,
    this.footnote,
    this.failure,
    this.busy = false,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// "on-device", "Your usual"; null hides the chip.
  final String? originLabel;
  final Widget body;

  /// Right under the subtitle: one quiet line (`StatusHint`, M14.2).
  final Widget? hint;

  /// Above the card: what the proposal is about (the task's row).
  final Widget? lead;

  /// Under the card, before the options: a total, a note.
  final Widget? below;

  /// Toggle chips under the card ("Shift followers", `B-ios-rebalance`).
  final List<Widget> options;

  /// Null keeps the sheet's own "Accept".
  final String? acceptLabel;

  /// Null keeps "Nothing is saved until you accept".
  final String? footnote;

  /// Null disables Accept (nothing left to write).
  final VoidCallback? onAccept;

  /// Discard and ×: closes, writes nothing.
  final VoidCallback onDiscard;

  /// The last Accept's failure, with Try again (R-08: never silent).
  final AppFailure? failure;

  /// Accept is writing: the button waits.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      // As tall as its content: a centred panel fits the plan (E-R2-35).
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            DotSpace.l,
            DotSpace.m,
            DotSpace.s,
            DotSpace.m,
          ),
          child: SheetHeader(
            title: title,
            subtitle: subtitle,
            tag: switch (originLabel) {
              final o? => DotTag(o, large: true),
              null => null,
            },
            onClose: onDiscard,
          ),
        ),
        if (failure case final f?)
          SaveFailureBanner(failure: f, onRetry: onAccept ?? () {}),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DotSpace.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DotSpace.l,
              children: [
                ?hint,
                ?lead,
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.colors.raised,
                    border: Border.all(color: t.colors.outline),
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        DotIdiom.of(context) == DotIdiom.cupertino
                            ? DotRadii.sheetCard
                            : DotRadii.sheetCardAndroid,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(DotSpace.l),
                    child: body,
                  ),
                ),
                ?below,
                if (options.isNotEmpty)
                  Wrap(
                    spacing: DotSpace.s,
                    runSpacing: DotSpace.s,
                    children: options,
                  ),
              ],
            ),
          ),
        ),
        _Actions(
          acceptLabel: acceptLabel ?? context.l10n.proposalAccept,
          footnote: footnote ?? context.l10n.proposalNothingSaved,
          onAccept: busy ? null : onAccept,
          onDiscard: onDiscard,
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.acceptLabel,
    required this.footnote,
    required this.onAccept,
    required this.onDiscard,
  });

  final String acceptLabel;
  final String footnote;
  final VoidCallback? onAccept;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.l,
        DotSpace.l,
        DotSpace.l,
        DotSpace.l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.xs,
        children: [
          FilledButton.icon(
            onPressed: onAccept,
            // E-Phones-2: 54 tall, 800 17, the check before the words.
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(DotSize.primaryButton),
              textStyle: t.styles.primaryButton,
            ),
            icon: DotIcon(DotGlyphs.check, color: t.colors.onAccent),
            label: Text(acceptLabel),
          ),
          TextButton(onPressed: onDiscard, child: Text(l10n.proposalDiscard)),
          Text(
            footnote,
            textAlign: TextAlign.center,
            style: t.styles.caption.copyWith(color: t.colors.muted),
          ),
        ],
      ),
    );
  }
}
