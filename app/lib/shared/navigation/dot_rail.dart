import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/add_menu.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';

/// The rail (E-R2-1): Android and web at medium width, and the folded
/// sidebar when expanded. A [menu] button on top opens the full list (the
/// Android drawer) or shows the sidebar again; then add, the places, and
/// the foot places (Settings) at the bottom.
class DotRailShell extends StatelessWidget {
  const DotRailShell({
    required this.bar,
    required this.body,
    this.menu,
    this.drawer,
    super.key,
  });

  final ShellBar bar;
  final Widget body;

  /// The top button: its glyph, its name and what it does.
  final ({DotGlyph glyph, String label, VoidCallback? onTap})? menu;

  /// The list the menu opens over the content (the Android drawer); null
  /// when the menu does something else.
  final Widget? drawer;

  /// Rail width (`A-mac-*`: ≈ 77 pt).
  static const double width = 80;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final items = bar.items;
    final menu = this.menu;
    return Scaffold(
      drawer: drawer,
      body: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              // E-R2-1 3b: the rail on the sunk surface.
              color: c.sunk,
              border: BorderDirectional(
                end: BorderSide(color: c.outline, width: DotSpace.hairline),
              ),
            ),
            child: SafeArea(
              right: false,
              child: SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: DotSpace.l),
                  child: Column(
                    spacing: DotSpace.s,
                    children: [
                      if (menu != null)
                        Builder(
                          builder: (context) => IconButton(
                            onPressed:
                                menu.onTap ??
                                () => Scaffold.of(context).openDrawer(),
                            tooltip: menu.label,
                            icon: DotIcon(menu.glyph, color: c.ink2),
                          ),
                        ),
                      if (bar.onAdd case final onAdd?)
                        AddDraggable(
                          child: _RailAdd(onAdd: onAdd, label: bar.addLabel),
                        ),
                      for (final (i, d) in items.indexed)
                        if (!d.foot) _tile(i),
                      const Spacer(),
                      for (final (i, d) in items.indexed)
                        if (d.foot) _tile(i),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _tile(int i) => _RailTile(
    destination: bar.items[i],
    selected: i == bar.selected,
    onTap: () => bar.onSelect(i),
  );
}

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      // M3 rail (E-R2-1 3b): a pill behind the current place's icon, its
      // name under it in bold (never colour alone).
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.railItem),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: DotSpace.xs,
            children: [
              Container(
                width: _pill.width,
                height: _pill.height,
                decoration: ShapeDecoration(
                  color: selected ? c.tonalAndroid : Colors.transparent,
                  shape: const StadiumBorder(),
                ),
                child: Center(
                  child: ShellIcon(
                    destination: destination,
                    active: selected,
                    color: selected ? c.onTonalAndroid : c.ink2,
                  ),
                ),
              ),
              Text(
                destination.label,
                maxLines: 1,
                style: t.styles
                    .androidTab(
                      selected ? t.styles.tabLabelActive : t.styles.tabLabel,
                    )
                    .copyWith(color: selected ? c.text : c.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The M3 rail's active indicator.
  static const _pill = Size(56, 32);
}

class _RailAdd extends StatelessWidget {
  const _RailAdd({required this.onAdd, required this.label});

  final VoidCallback onAdd;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: DotSpace.s),
      // The M3 FAB on the rail: a rounded square in the tonal colour.
      child: AddMenuButton(
        onAdd: onAdd,
        builder: (onPressed) => IconButton.filled(
          onPressed: onPressed,
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: c.tonalAndroid,
            minimumSize: const Size.square(DotTouch.android + DotSpace.s),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DotRadii.fabAndroid),
            ),
          ),
          icon: DotIcon(DotGlyphs.add, color: c.onTonalAndroid, active: true),
        ),
      ),
    );
  }
}
