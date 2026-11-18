import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// One folding section of the Plan panel (rules §9.16): a heading button
/// with a chevron and its state for a screen reader, then [child] unless
/// folded. Values in, callbacks out.
@immutable
final class PlanPanelSection {
  const PlanPanelSection({
    required this.title,
    required this.folded,
    required this.onToggle,
    required this.child,
    this.trailing,
  });

  final String title;

  /// A count ("3") or a key hint ("⇧⌘N") after the title.
  final String? trailing;
  final bool folded;
  final VoidCallback onToggle;
  final Widget child;
}

/// The Plan panel (E-FullA-v2, ED-184): [top] (Capture) and the folding
/// [sections], scrolling, [width] wide; its end edge drags to resize
/// ([onResize] with the new width) and past [minWidth] hides it
/// ([onHide]). [pin] sits at its top while it is brought out.
class PlanPanelShell extends StatelessWidget {
  const PlanPanelShell({
    required this.width,
    required this.minWidth,
    required this.sections,
    required this.onResize,
    required this.onHide,
    this.top,
    this.pin,
    this.touch = false,
    super.key,
  });

  /// Touch sizes (tablets, touch-first web): the headings 48 tall.
  final bool touch;

  final double width;
  final double minWidth;
  final Widget? top;
  final List<PlanPanelSection> sections;
  final ValueChanged<double> onResize;
  final VoidCallback onHide;
  final Widget? pin;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return SizedBox(
      width: width,
      child: Material(
        color: c.sunk,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                DotSpace.m,
                DotSpace.s,
                DotSpace.m,
                DotSpace.l,
              ),
              children: [
                if (pin case final p?)
                  Align(alignment: AlignmentDirectional.centerEnd, child: p),
                ?top,
                for (final s in sections) ...[
                  _Heading(section: s, touch: touch),
                  if (!s.folded) s.child,
                ],
              ],
            ),
            PositionedDirectional(
              top: 0,
              bottom: 0,
              end: 0,
              child: _Edge(
                width: width,
                minWidth: minWidth,
                onResize: onResize,
                onHide: onHide,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.section, required this.touch});

  final PlanPanelSection section;
  final bool touch;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final s = section;
    return Semantics(
      button: true,
      header: true,
      expanded: !s.folded,
      label: s.title,
      excludeSemantics: true,
      onTap: s.onToggle,
      child: InkWell(
        onTap: s.onToggle,
        borderRadius: BorderRadius.circular(DotRadii.sidebarRow),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: touch ? DotTouch.android : DotSize.planHeading,
          ),
          child: Row(
            spacing: DotSpace.xs,
            children: [
              DotIcon(
                s.folded ? DotGlyphs.chevronRight : DotGlyphs.chevronDown,
                color: t.colors.ink2,
                size: DotSize.sidebarGlyph * 2 / 3,
              ),
              Expanded(child: Text(s.title, style: t.styles.planHeading)),
              if (s.trailing case final text?)
                Text(text, style: t.styles.sidebarHint),
            ],
          ),
        ),
      ),
    );
  }
}

/// The panel's draggable edge: resizes, and hides past the minimum.
class _Edge extends StatelessWidget {
  const _Edge({
    required this.width,
    required this.minWidth,
    required this.onResize,
    required this.onHide,
  });

  final double width;
  final double minWidth;
  final ValueChanged<double> onResize;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    var dragged = width;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (d) {
          dragged += d.primaryDelta ?? 0;
          if (dragged >= minWidth) onResize(dragged);
        },
        onHorizontalDragEnd: (_) {
          // Well past the minimum: the person means to hide it.
          if (dragged < minWidth - DotSize.planHideSlack) onHide();
          dragged = width;
        },
        child: const SizedBox(width: DotSize.planEdge),
      ),
    );
  }
}
