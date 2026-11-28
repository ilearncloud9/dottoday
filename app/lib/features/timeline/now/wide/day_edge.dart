import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The folded Day column's edge button (ED-170): a 44 strip at the
/// window's end with "Day" on a pill, no shortcut of its own. It opens
/// the column as a panel over Now and closes it again; a screen reader
/// hears "Day", expanded or collapsed.
class DayEdge extends StatelessWidget {
  const DayEdge({
    required this.open,
    required this.onTap,
    required this.focusNode,
    super.key,
  });

  final bool open;
  final VoidCallback onTap;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Container(
      width: DotSize.dayEdge,
      decoration: BoxDecoration(
        color: t.colors.ground,
        border: BorderDirectional(start: BorderSide(color: t.colors.hairline)),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: DotSpace.m),
      child: Semantics(
        button: true,
        expanded: open,
        label: l10n.workspaceDay,
        excludeSemantics: true,
        onTap: onTap,
        child: Tooltip(
          message: open
              ? MaterialLocalizations.of(context).closeButtonTooltip
              : l10n.dayColumnShow,
          child: Material(
            color: open ? t.colors.tonal : t.colors.card,
            shape: StadiumBorder(side: BorderSide(color: t.colors.hairline)),
            child: InkWell(
              focusNode: focusNode,
              onTap: onTap,
              customBorder: const StadiumBorder(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: DotTouch.min,
                  minHeight: DotTouch.android * 2,
                ),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(l10n.workspaceDay, style: t.styles.button),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
