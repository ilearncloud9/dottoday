import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// How a Workspace sidebar row stands out (E-FullA-v2): the current
/// place on the accent's tint, the current view on a faint ink tint with
/// a teal dot, everything else plain. Bold either way, never colour alone.
enum SidebarMark { none, place, view }

/// One row of the Workspace sidebar: an optional glyph, the label, then
/// a count or a key hint at the end. [touch] rows are the touch height
/// and body text; pointer rows 30 tall, 13 pt (ED-260, ED-261).
class WorkspaceSidebarRow extends StatelessWidget {
  const WorkspaceSidebarRow({
    required this.label,
    required this.onTap,
    required this.touch,
    this.glyph,
    this.trailing,
    this.badge = false,
    this.mark = SidebarMark.none,
    this.indent = false,
    this.semanticLabel,
    this.expanded,
    this.onToggle,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool touch;
  final DotGlyph? glyph;

  /// A count ("3/9", "2") or a key hint ("⌘3") at the row's end.
  final String? trailing;

  /// Draw [trailing] as a tinted count badge (the Inbox's open tasks).
  final bool badge;
  final SidebarMark mark;

  /// A sub-row of Plan, lined up under its label.
  final bool indent;

  /// The row's full name for a screen reader when it differs from
  /// [label] ("Inbox, 3").
  final String? semanticLabel;

  /// A row that folds its sub-rows (Plan): whether they show, and the
  /// chevron's tap; null draws no chevron.
  final bool? expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final on = mark != SidebarMark.none;
    final base = touch ? t.styles.body : t.styles.sidebarItem;
    final ink = mark == SidebarMark.place ? c.accentText : c.ink;
    final style = base.copyWith(
      color: ink,
      fontWeight: on ? FontWeight.w600 : null,
    );
    final fill = switch (mark) {
      SidebarMark.place => c.accentTint,
      SidebarMark.view => c.ink.withValues(alpha: 0.06),
      SidebarMark.none => Colors.transparent,
    };
    return Semantics(
      button: true,
      selected: on,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(DotRadii.sidebarRow),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DotRadii.sidebarRow),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: touch ? DotTouch.android : DotSize.sidebarRowPointer,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start:
                    DotSpace.s +
                    (indent
                        ? DotSize.sidebarGlyph + DotSpace.s + DotSpace.xxs
                        : 0),
                end: DotSpace.s,
              ),
              child: Row(
                spacing: DotSpace.s,
                children: [
                  if (glyph case final g?)
                    DotIcon(g, color: c.accent, size: DotSize.sidebarGlyph),
                  if (mark == SidebarMark.view)
                    Container(
                      width: DotSpace.xs + DotSpace.xxs,
                      height: DotSpace.xs + DotSpace.xxs,
                      decoration: BoxDecoration(
                        color: c.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(child: Text(label, style: style)),
                  if (trailing case final text?) _trailing(t, text),
                  if (onToggle case final toggle?)
                    Semantics(
                      button: true,
                      expanded: expanded,
                      label: label,
                      child: InkResponse(
                        onTap: toggle,
                        radius: DotSize.sidebarRowPointer / 2,
                        child: DotIcon(
                          expanded ?? false
                              ? DotGlyphs.chevronDown
                              : DotGlyphs.chevronRight,
                          color: ink,
                          size: DotSize.sidebarGlyph * 2 / 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trailing(DotTheme t, String text) {
    final c = t.colors;
    if (!badge) return Text(text, style: t.styles.sidebarHint);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.xs + DotSpace.xxs,
        vertical: DotSpace.xxs / 2,
      ),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DotRadii.pill),
      ),
      child: Text(
        text,
        style: t.styles.sidebarHint.copyWith(
          color: c.accentText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
