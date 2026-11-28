import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// How a [SidePanelFrame] floats when it can't dock: the Mac and web's
/// card over the content (ED-167); the iPad's card over a slight dim; and
/// Android's M3 modal side sheet against the edge (E-R2-4, ED-274).
enum SidePanelFloat { card, dimmedCard, edgeSheet }

/// [child] with a 420 [panel] at its end edge (the task editor, a
/// proposal): docked beside it where [AppLayout.docks], else floating
/// over it as [float] says (ED-167, ED-168). A dimmed float closes with
/// [onDismiss] when the dim is tapped.
///
/// Both ways use the same tree, only the edges move, so a resize never
/// resets the content's scroll or the panel's text, steps or focus.
class SidePanelFrame extends StatelessWidget {
  const SidePanelFrame({
    required this.child,
    required this.panel,
    this.float = SidePanelFloat.card,
    this.onDismiss,
    super.key,
  });

  final Widget child;
  final Widget panel;
  final SidePanelFloat float;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final docked = AppLayout.docks(context, available: box.maxWidth);
        final edge = !docked && float == SidePanelFloat.edgeSheet;
        final dim = !docked && float != SidePanelFloat.card;
        const width = DotSize.sidePanel;
        final inset = docked || edge ? 0.0 : DotSpace.s;
        final BorderRadiusGeometry? radius = docked
            ? null
            : edge
            ? const BorderRadiusDirectional.horizontal(
                start: Radius.circular(DotRadii.sheet),
              )
            : BorderRadius.circular(DotRadii.block);
        return Stack(
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              end: docked ? width + DotSpace.hairline : 0,
              child: child,
            ),
            // Always in the tree, so the panel keeps its place (and state)
            // when a resize docks it.
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !dim,
                child: Semantics(
                  label: dim ? context.l10n.sheetClose : null,
                  button: dim,
                  onTap: dim ? onDismiss : null,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onDismiss,
                    child: ColoredBox(
                      color: dim ? c.scrim : c.scrim.withValues(alpha: 0),
                    ),
                  ),
                ),
              ),
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
                  color: edge ? c.sheet : c.card,
                  borderRadius: radius,
                  border: docked
                      ? BorderDirectional(start: BorderSide(color: c.hairline))
                      : edge
                      ? null
                      : Border.all(color: c.hairline),
                  boxShadow: docked ? null : DotElevation.floating,
                ),
                child: Padding(
                  // Docked, the hairline sits beside the panel, not on it.
                  padding: EdgeInsetsDirectional.only(
                    start: docked ? DotSpace.hairline : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: radius ?? BorderRadius.zero,
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
