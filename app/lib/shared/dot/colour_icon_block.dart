import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/look/look_sheet.dart';
import 'package:dottoday/shared/pickers/task_icon_choice.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:flutter/material.dart';

/// "COLOUR AND ICON" (docs/10 §3 `ColourIconBlock`, `A-ios-add-what`,
/// `A-mac-editor`): the 9 colour dots, then the chosen icon and up to two
/// [suggested] ones, then "…" for the full icon library (by category, with search). The chosen icon
/// is tinted in the chosen colour; selection is never colour alone (ring
/// and check).
class ColourIconBlock extends StatelessWidget {
  const ColourIconBlock({
    required this.color,
    required this.icon,
    required this.onColor,
    required this.onIcon,
    this.suggested = const [TaskIcon.cart, TaskIcon.heart],
    this.title = '',
    super.key,
  });

  final TaskColor color;
  final TaskIcon icon;
  final ValueChanged<TaskColor> onColor;
  final ValueChanged<TaskIcon> onIcon;

  /// Quick icons beside the chosen one (from habits; M3c.1).
  final List<TaskIcon> suggested;

  /// The task's title, for the picker's suggested icons.
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final quick = [
      if (icon.glyph != null) icon,
      ...suggested.where((i) => i != icon && i.glyph != null),
    ].take(3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.colourIconCaption.toUpperCase(),
            style: t.styles.caption,
          ),
        ),
        // One row as in the renders; it scrolls rather than shrinking the
        // 44 pt targets (§7.4 wins over the render's tighter spacing).
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in TaskColor.values)
                ColourDot(
                  colour: c,
                  selected: c == color,
                  onTap: () => onColor(c),
                ),
              for (final i in quick)
                TaskIconChoice(
                  icon: i,
                  colour: color,
                  selected: i == icon,
                  onTap: () => onIcon(i),
                ),
              _More(onTap: (at) => unawaited(_pickIcon(context, at))),
            ],
          ),
        ),
      ],
    );
  }

  /// Colour and icon (M19.4 part 4c): each pick lands as it is made.
  Future<void> _pickIcon(BuildContext context, Rect? anchor) async {
    var last = (color: color, icon: icon);
    await showTaskLook(
      context,
      colour: color,
      icon: icon,
      title: title,
      anchor: anchor,
      onChanged: (l) {
        if (l.color != last.color) onColor(l.color);
        if (l.icon != last.icon) onIcon(l.icon);
        last = l;
      },
    );
  }
}

/// One task colour as a 44 pt choice: ring and check when [selected].
class ColourDot extends StatelessWidget {
  const ColourDot({
    required this.colour,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final TaskColor colour;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Semantics(
      button: true,
      selected: selected,
      label: taskColorName(context.l10n, colour),
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: DotTouch.android / 2,
        child: SizedBox.square(
          dimension: DotTouch.android,
          child: Center(
            child: Container(
              width: DotSize.macRowDot + DotSpace.xs,
              height: DotSize.macRowDot + DotSpace.xs,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colour.color,
                border: selected
                    ? Border.all(
                        color: c.raised,
                        width: DotSize.smallDotOutline,
                      )
                    : null,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: colour.color,
                          spreadRadius: DotSize.smallDotOutline,
                        ),
                      ]
                    : null,
              ),
              child: selected
                  ? DotIcon(
                      DotGlyphs.check,
                      color: c.raised,
                      size: DotSize.rowIcon - DotSpace.xs,
                      active: true,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _More extends StatelessWidget {
  const _More({required this.onTap});

  final ValueChanged<Rect?> onTap;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return IconButton(
      onPressed: () => onTap(globalRectOf(context)),
      tooltip: context.l10n.colourIconMore,
      icon: DotIcon(DotGlyphs.more, color: c.muted),
    );
  }
}
