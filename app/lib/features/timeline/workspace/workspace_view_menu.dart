import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Week ⌄": the Day / 3 days / Week / Month tabs as one pop-up, where the
/// toolbar is short of room for them (E-G4-3-Narrow's 840 toolbar, ED-183,
/// rules §12.3). Drawn on the tabs' own track, the shown view's name in
/// it; the menu marks the shown view with a check, not colour alone.
class ViewMenu extends ConsumerWidget {
  const ViewMenu({
    required this.selected,
    required this.labels,
    required this.onSelect,
    super.key,
  });

  final WorkspaceView selected;
  final Map<WorkspaceView, String> labels;
  final ValueChanged<WorkspaceView> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final name = context.l10n.workspaceViewMenu;
    final h = workspaceControlHeight(context, ref);
    return Semantics(
      label: name,
      value: labels[selected],
      excludeSemantics: true,
      button: true,
      child: PopupMenuButton<WorkspaceView>(
        tooltip: name,
        initialValue: selected,
        onSelected: onSelect,
        itemBuilder: (context) => [
          for (final v in WorkspaceView.values)
            CheckedPopupMenuItem<WorkspaceView>(
              value: v,
              checked: v == selected,
              child: Text(labels[v]!),
            ),
        ],
        child: Container(
          height: h,
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
          decoration: BoxDecoration(
            color: c.ink.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(DotRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              Text(
                labels[selected]!,
                style: t.styles.viewTab.copyWith(
                  color: c.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DotIcon(
                DotGlyphs.chevronDown,
                color: c.ink,
                size: DotSize.sidebarGlyph * 2 / 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
