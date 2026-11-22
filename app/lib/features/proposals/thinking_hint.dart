import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/shared/thinking/thinking_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The proposal sheet's "Made with simple rules · Turn on …" line (docs/09
/// M14.2, D4): only when the rules answered, the model could become
/// available on this device, and it was not put away (one flag for Break
/// it down and Brain dump). A tinted box with Don't show again (E-R2-23). A tap closes the sheet via [onOpen] — nothing
/// is written — and opens Settings › Privacy.
class ThinkingHint extends ConsumerWidget {
  const ThinkingHint({required this.onOpen, super.key});

  /// Closes the proposal before the Privacy page opens.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(thinkingStatusProvider).value;
    final l10n = context.l10n;
    final action = status == null ? null : l10n.thinkingHintAction(status);
    // The flag is read only where a hint could show at all.
    if (action == null) return const SizedBox.shrink();
    final seen = ref.watch(seenTipsProvider).value;
    if (seen == null || seen.contains(Tip.thinkingHint)) {
      return const SizedBox.shrink();
    }
    final t = DotTheme.of(context);
    void open() {
      final router = GoRouter.of(context);
      onOpen();
      unawaited(router.push(AppRoutes.settingsPage(SettingsPage.privacy)));
    }

    final text = Semantics(
      button: true,
      excludeSemantics: true,
      label: l10n.statusHintJoin(l10n.thinkingHintLead, action),
      onTap: open,
      child: InkWell(
        onTap: open,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            DotSpace.m,
            DotSpace.s,
            DotSpace.s,
            DotSpace.s,
          ),
          child: Text(
            l10n.statusHintJoin(l10n.thinkingHintLead, action),
            style: t.styles.smallChip.copyWith(color: t.colors.accentInk),
          ),
        ),
      ),
    );
    final dismiss = TextButton(
      onPressed: () => unawaited(
        ref.read(seenTipsProvider.notifier).putAway(Tip.thinkingHint),
      ),
      child: Text(l10n.thinkingHintDismiss),
    );
    // A tinted box with Don't show again (E-R2-23 §1, simple rules).
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.accentTint,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: _stacks(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                text,
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: dismiss,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: text),
                dismiss,
              ],
            ),
    );
  }

  /// Large text: Don't show again goes under the words.
  static bool _stacks(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1) > DotSize.stackAbove;
}
