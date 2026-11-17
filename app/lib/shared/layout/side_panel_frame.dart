import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// [child] with a 420 [panel] at its end edge (the task editor, a
/// proposal): docked beside it where [AppLayout.docks], else floating
/// over it as a card (ED-167, ED-168).
///
/// Both ways use the same tree, only the edges move, so a resize never
/// resets the content's scroll or the panel's text, steps or focus.
class SidePanelFrame extends StatelessWidget {
  const SidePanelFrame({required this.child, required this.panel, super.key});

  final Widget child;
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final docked = AppLayout.docks(context, available: box.maxWidth);
        const width = DotSize.sidePanel;
        final inset = docked ? 0.0 : DotSpace.s;
        return Stack(
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              end: docked ? width + DotSpace.hairline : 0,
              child: child,
            ),
            PositionedDirectional(
              top: inset,
              bottom: inset,
              end: inset,
              width: docked ? width + DotSpace.hairline : width,
              child: DecoratedBox(
                // Floating, it is a card over the content (rules §7.3
                // inspector look); docked, a hairline divides them.
                decoration: BoxDecoration(
                  color: c.raised,
                  borderRadius: docked
                      ? null
                      : BorderRadius.circular(DotRadii.block),
                  border: docked
                      ? BorderDirectional(start: BorderSide(color: c.outline))
                      : Border.all(color: c.outline),
                  boxShadow: docked ? null : DotElevation.floating,
                ),
                child: Padding(
                  // Docked, the hairline sits beside the panel, not on it.
                  padding: EdgeInsetsDirectional.only(
                    start: docked ? DotSpace.hairline : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: docked
                        ? BorderRadius.zero
                        : BorderRadius.circular(DotRadii.block),
                    child: panel,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
