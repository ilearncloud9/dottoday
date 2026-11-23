import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/look/look_sheet.dart';
import 'package:dottoday/shared/sheets/dot_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// One button of a [SelectionBarFrame]: icon over label; null [onTap]
/// greys it out.
typedef SelectionAction = ({Widget icon, String label, VoidCallback? onTap});

/// The multi-select card (docs/03 §3.2, R-05; E-R2-6, ED-278; shared with
/// the Inbox): "3 selected" with ×, then the actions, icon over label. Escape
/// closes; the count is a live region.
class SelectionBarFrame extends StatelessWidget {
  const SelectionBarFrame({
    required this.count,
    required this.onClose,
    required this.actions,
    super.key,
  });

  final int count;
  final VoidCallback onClose;
  final List<SelectionAction> actions;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onClose},
      child: Focus(
        autofocus: true,
        // Centred, at most 470 wide: under the grid on wide screens, the
        // phone's width less its margins (E-R2-6, ED-278).
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: DotSize.selectionCardWide + DotSpace.l,
            ),
            child: _card(context, t, l10n),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, DotTheme t, AppLocalizations l10n) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.s + DotSpace.xxs,
          vertical: DotSpace.s,
        ),
        // E-R2-6 (ED-278): the card at 26, a hairline edge, the floating
        // shadow, 6 inside.
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.colors.raised,
            borderRadius: BorderRadius.circular(DotRadii.selectionCard),
            border: Border.all(color: t.colors.outline),
            boxShadow: DotElevation.floating,
          ),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.xs + DotSpace.xxs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: l10n.selectionClose,
                      onPressed: onClose,
                      icon: DotIcon(DotGlyphs.close, color: t.colors.text),
                    ),
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.selectionCount(count),
                          style: t.styles.rowTitle,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(children: [for (final a in actions) _Action(a)]),
              ],
            ),
          ),
        ),
      );
}

class _Action extends StatelessWidget {
  const _Action(this.action);

  final SelectionAction action;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final (:icon, :label, :onTap) = action;
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DotRadii.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: DotSize.selectionAction,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
              child: Column(
                spacing: DotSpace.xxs,
                children: [
                  icon,
                  Text(
                    label,
                    style: t.styles.caption.copyWith(
                      color: onTap == null ? t.colors.tertiary : t.colors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The Colour action's icon (E-R2-6): a ring half filled, in the text
/// colour like the other actions' glyphs.
class ColourSwatchIcon extends StatelessWidget {
  const ColourSwatchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    // The size of the other actions' glyphs, so the labels line up.
    return SizedBox.square(
      dimension: DotSize.navIcon,
      child: Center(
        child: Container(
          width: DotSize.rowIcon,
          height: DotSize.rowIcon,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.text, width: DotSize.smallDotOutline),
            // The start half filled: a hard stop at the middle.
            gradient: LinearGradient(
              colors: [c.text, c.text, Colors.transparent, Colors.transparent],
              stops: const [0, 0.5, 0.5, 1],
            ),
          ),
        ),
      ),
    );
  }
}

/// A colour for the picked tasks, or null (owner, M19.4 part 4c): All
/// colours on phones and tablets below expanded, the colour popover on the
/// Mac and web, boxed on wide tablets.
Future<TaskColor?> showColourChoice(BuildContext context) =>
    showColourOnly(context);

/// "Delete 3 tasks?": true only on Delete.
Future<bool> confirmDeleteMany(BuildContext context, int count) async {
  final l10n = context.l10n;
  final sure = await showChoiceAlert<bool>(
    context,
    title: l10n.selectionDeleteConfirm(count),
    choices: [
      AlertChoice(label: l10n.editorCancel, value: false, cancel: true),
      AlertChoice(label: l10n.selectionDelete, value: true, primary: true),
    ],
  );
  return sure ?? false;
}

/// Says the new count when it changes, from the first pick on (R-12).
/// Called by the screen, which outlives the bar.
void announceCount(BuildContext context, int? before, int now) {
  if (now == 0 || now == before) return;
  unawaited(
    SemanticsService.sendAnnouncement(
      View.of(context),
      context.l10n.selectionCount(now),
      Directionality.of(context),
    ),
  );
}
