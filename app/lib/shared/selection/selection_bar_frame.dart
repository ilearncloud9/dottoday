import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// One button of a [SelectionBarFrame]: icon over label; null [onTap]
/// greys it out.
typedef SelectionAction = ({Widget icon, String label, VoidCallback? onTap});

/// The multi-select bar (docs/03 §3.2, R-05; M3b.7, shared with the Inbox
/// in M3f.9c): "3 selected" with ×, then the actions in a row. Escape
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
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.s),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.raised,
              borderRadius: BorderRadius.circular(DotRadii.card),
              boxShadow: DotElevation.floating,
            ),
            child: Padding(
              padding: const EdgeInsets.all(DotSpace.xs),
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
                            style: t.styles.cardTitle,
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
        ),
      ),
    );
  }
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
            constraints: const BoxConstraints(minHeight: DotTouch.android),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
              child: Column(
                spacing: DotSpace.xxs,
                children: [
                  icon,
                  Text(
                    label,
                    style: t.styles.caption,
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

/// The Colour action's icon: a filled accent dot in a text-coloured ring.
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
            color: c.accent,
            border: Border.all(color: c.text, width: DotSize.smallDotOutline),
          ),
        ),
      ),
    );
  }
}

/// The nine task colours in a sheet; the one tapped, or null.
Future<TaskColor?> showColourChoice(BuildContext context) =>
    showModalBottomSheet<TaskColor>(
      context: context,
      builder: (_) => const _ColourSheet(),
    );

class _ColourSheet extends StatelessWidget {
  const _ColourSheet();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.m,
          children: [
            Text(context.l10n.selectionColour, style: t.styles.cardTitle),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (final c in TaskColor.values)
                  ColourDot(
                    colour: c,
                    selected: false,
                    onTap: () => Navigator.of(context).pop(c),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Delete 3 tasks?": true only on Delete.
Future<bool> confirmDeleteMany(BuildContext context, int count) async {
  final l10n = context.l10n;
  final sure = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.selectionDeleteConfirm(count)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(false),
          child: Text(l10n.editorCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialog).pop(true),
          child: Text(l10n.selectionDelete),
        ),
      ],
    ),
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
