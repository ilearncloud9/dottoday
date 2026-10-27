import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:flutter/material.dart';

/// One task icon as a 48 px choice (docs/10 §3 `ColourIconBlock`): tinted
/// in [colour] on a tint disc when [selected], text colour otherwise, so
/// selection is never colour alone (disc and heavier stroke).
class TaskIconChoice extends StatelessWidget {
  const TaskIconChoice({
    required this.icon,
    required this.onTap,
    this.colour,
    this.selected = false,
    super.key,
  });

  final TaskIcon icon;
  final VoidCallback onTap;

  /// The task's colour for the selected state; null shows no selection
  /// colour (the Search filter, which picks an icon only).
  final TaskColor? colour;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = colour == null ? null : t.tasks[colour!];
    final on = selected && swatch != null;
    return Semantics(
      button: true,
      selected: selected,
      label: taskIconName(context.l10n, icon),
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: taskIconName(context.l10n, icon),
        excludeFromSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: DotTouch.android / 2,
          child: Container(
            width: DotTouch.android,
            height: DotTouch.android,
            alignment: Alignment.center,
            decoration: on
                ? BoxDecoration(shape: BoxShape.circle, color: swatch.tint)
                : null,
            child: DotIcon(
              icon.glyph!,
              color: on ? swatch.color : t.colors.text,
              active: selected,
            ),
          ),
        ),
      ),
    );
  }
}
