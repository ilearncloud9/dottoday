import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:flutter/material.dart';

/// B3 (11 §0): the one sheet every model- or rule-made change is shown in
/// before anything is written — Break it down, brain-dump, Rebalance,
/// routines, the reality thread (CLAUDE.md §11 "Proposal rule"). Chrome
/// from `B-ios-break-it-down` / `B-ios-rebalance`: title with an origin
/// chip and ×, a subtitle, the [body] in a card, optional [options],
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(title: title, originLabel: originLabel, onClose: onDiscard),
        if (failure case final f?)
          SaveFailureBanner(failure: f, onRetry: onAccept ?? () {}),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DotSpace.page,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DotSpace.l,
              children: [
                if (subtitle case final s?)
                  Text(s, style: t.styles.body.copyWith(color: t.colors.muted)),
                ?lead,
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.colors.raised,
                    border: Border.all(color: t.colors.outline),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(DotRadii.cardLarge),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.originLabel,
    required this.onClose,
  });

  final String title;
  final String? originLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.s,
        DotSpace.s,
      ),
      child: Row(
        spacing: DotSpace.s,
        children: [
          Flexible(
            child: Semantics(
              header: true,
              child: Text(title, style: t.styles.pageTitle),
            ),
          ),
          if (originLabel case final o?) _OriginChip(o),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            tooltip: context.l10n.sheetClose,
            icon: DotIcon(DotGlyphs.close, color: t.colors.text),
          ),
        ],
      ),
    );
  }
}

/// "on-device" in an accent tint (`B-ios-break-it-down`).
class _OriginChip extends StatelessWidget {
  const _OriginChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.accentTint,
        borderRadius: const BorderRadius.all(Radius.circular(DotRadii.pill)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.xs,
        ),
        child: Text(
          label,
          style: t.styles.rowMeta.copyWith(color: t.colors.accentInk),
        ),
      ),
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
        DotSpace.page,
        DotSpace.l,
        DotSpace.page,
        DotSpace.l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.xs,
        children: [
          FilledButton.icon(
            onPressed: onAccept,
            iconAlignment: IconAlignment.end,
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
