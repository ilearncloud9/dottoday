import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Search or run ⌘K" (k on the web): opens the palette (M20.2 part 3).
class SearchField extends ConsumerWidget {
  const SearchField({
    required this.label,
    required this.onTap,
    this.hint,
    this.compact = false,
    super.key,
  });

  final String label;
  final String? hint;
  final VoidCallback onTap;

  /// Its icon and key cap only, named for a screen reader (a narrow
  /// toolbar).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final h = workspaceControlHeight(context, ref);
    if (compact) {
      return Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            // E-G4-3-Narrow: sized to the icon and ⌘K (ED-170, ED-183).
            child: Container(
              constraints: BoxConstraints(minWidth: h + DotSpace.xs),
              height: h,
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
              decoration: workspacePill(t.colors),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: DotSpace.s,
                children: [
                  DotIcon(
                    DotGlyphs.search,
                    color: t.colors.ink2,
                    size: DotSize.sidebarGlyph * 5 / 6,
                  ),
                  if (hint case final k?)
                    ExcludeSemantics(
                      child: Text(k, style: t.styles.sidebarHint),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            height: h,
            constraints: const BoxConstraints(
              minWidth: DotSize.workspaceSearch,
            ),
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
            decoration: workspacePill(t.colors),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DotSpace.s,
              children: [
                DotIcon(
                  DotGlyphs.search,
                  color: t.colors.ink2,
                  size: DotSize.sidebarGlyph * 5 / 6,
                ),
                Text(
                  label,
                  style: t.styles.sidebarItem.copyWith(color: t.colors.ink2),
                ),
                if (hint case final h?) Text(h, style: t.styles.sidebarHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
