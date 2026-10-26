import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The grab handle under the strip that pulls the month open (§2.4).
class PullHandle extends StatelessWidget {
  const PullHandle({required this.open, this.onPull, super.key});

  final bool open;
  final VoidCallback? onPull;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      expanded: open,
      label: open ? l10n.weekStripHideMonth : l10n.weekStripShowMonth,
      excludeSemantics: true,
      onTap: onPull,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPull,
        onVerticalDragEnd: onPull == null ? null : (_) => onPull!(),
        child: SizedBox(
          // A full 48 dp target although the bar is 5 px (§7.4 wins over
          // the render's tighter gap).
          width: DotTouch.android * 2,
          height: DotTouch.android,
          child: Center(
            child: Container(
              width: DotSize.rowDot,
              height: DotSize.weekDot / 2 + 1,
              decoration: BoxDecoration(
                color: c.outline,
                borderRadius: BorderRadius.circular(DotRadii.pill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
