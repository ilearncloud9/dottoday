import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';

/// Android / web compact shell (`A-android-today`): Material 3
/// NavigationBar and the rounded-square add FAB above it.
class MaterialBarShell extends StatelessWidget {
  const MaterialBarShell({required this.bar, required this.body, super.key});

  final ShellBar bar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final onAdd = bar.onAdd;
    return Scaffold(
      body: ChromeClearance(bottom: DotSpace.fabClearance, child: body),
      floatingActionButton: onAdd == null
          ? null
          : AddDraggable(
              child: FloatingActionButton(
                onPressed: onAdd,
                tooltip: bar.addLabel,
                backgroundColor: c.accent,
                foregroundColor: c.onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DotRadii.fabAndroid),
                ),
                child: DotIcon(DotGlyphs.add, color: c.onAccent, active: true),
              ),
            ),
      // No tabs (minimal layout): the FAB alone.
      bottomNavigationBar: bar.items.isEmpty ? null : _bar(t, c),
    );
  }

  Widget _bar(DotTheme t, DotColors c) => NavigationBar(
    // No entry for this page here (Week at phone width): nothing lit.
    selectedIndex: bar.selected < 0 ? 0 : bar.selected,
    indicatorColor: bar.selected < 0
        ? Colors.transparent
        : Color.alphaBlend(c.accentTint, c.raised),
    backgroundColor: c.raised,
    surfaceTintColor: Colors.transparent,
    onDestinationSelected: bar.onSelect,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (s) => t.styles
          .androidTab(
            s.contains(WidgetState.selected)
                ? t.styles.tabLabelActive
                : t.styles.tabLabel,
          )
          .copyWith(color: s.contains(WidgetState.selected) ? c.text : c.muted),
    ),
    destinations: [
      for (final (i, d) in bar.items.indexed)
        NavigationDestination(
          icon: ShellIcon(destination: d, active: false, color: c.muted),
          selectedIcon: ShellIcon(
            destination: d,
            active: i == bar.selected,
            color: c.accent,
          ),
          label: d.label,
        ),
    ],
  );
}
