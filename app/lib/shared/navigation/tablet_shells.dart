import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_rail.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/dot_sidebar.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';

/// Expanded windows (E-R2-1, ED-267): the sidebar of places beside the
/// content. Its button folds it to the rail and the rail's brings it
/// back, for this session (a view choice, nothing is stored).
class SidebarShell extends StatefulWidget {
  const SidebarShell({
    required this.bar,
    required this.body,
    this.vibrant = false,
    super.key,
  });

  final ShellBar bar;
  final Widget body;

  /// The Mac's material shows through the sidebar (ED-130): the shell
  /// paints only the content opaque, the sidebar its tint.
  final bool vibrant;

  @override
  State<SidebarShell> createState() => _SidebarShellState();
}

class _SidebarShellState extends State<SidebarShell> {
  var _folded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_folded) {
      return DotRailShell(
        bar: widget.bar,
        body: widget.body,
        menu: (
          glyph: DotGlyphs.sidebar,
          label: l10n.navShowSidebar,
          onTap: () => setState(() => _folded = false),
        ),
      );
    }
    final c = DotTheme.of(context).colors;
    final vibrant = widget.vibrant;
    return Scaffold(
      backgroundColor: vibrant ? Colors.transparent : null,
      body: Row(
        children: [
          SizedBox(
            width: DotSize.sidebar,
            child: DotSidebar(
              bar: widget.bar,
              vibrant: vibrant,
              onToggle: () => setState(() => _folded = true),
            ),
          ),
          VerticalDivider(width: DotSpace.hairline, color: c.outline),
          Expanded(
            child: vibrant
                ? ColoredBox(color: c.surface, child: widget.body)
                : widget.body,
          ),
        ],
      ),
    );
  }
}

/// The places in a drawer over the content: the Android rail's menu and
/// the iPad's sidebar button at medium width (E-R2-1 1c, 3b).
Widget placesDrawer(BuildContext context, ShellBar bar) => Drawer(
  width: DotSize.sidebar,
  backgroundColor: DotTheme.of(context).colors.canvas,
  child: Builder(
    builder: (context) =>
        DotSidebar(bar: bar, onPicked: () => Navigator.of(context).pop()),
  ),
);

/// iPad at medium width (E-R2-1 1b, ED-171): the top tabs with the main
/// places, the sidebar button at the start (the full list, Settings at
/// its foot), and add at the end. Flutter here; the native bar replaces
/// it in M18.6.
class TopTabsShell extends StatelessWidget {
  const TopTabsShell({required this.bar, required this.body, super.key});

  final ShellBar bar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final onAdd = bar.onAdd;
    return Scaffold(
      drawer: placesDrawer(context, bar),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.s,
                vertical: DotSpace.xs,
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: l10n.navShowSidebar,
                      icon: DotIcon(DotGlyphs.sidebar, color: t.colors.ink2),
                    ),
                  ),
                  Expanded(
                    child: Center(child: _TopTabs(bar: bar)),
                  ),
                  if (onAdd != null)
                    AddDraggable(
                      child: IconButton.filled(
                        onPressed: onAdd,
                        tooltip: bar.addLabel,
                        style: IconButton.styleFrom(
                          backgroundColor: t.colors.accent,
                        ),
                        icon: DotIcon(
                          DotGlyphs.add,
                          color: t.colors.onAccent,
                          active: true,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: DotTouch.min),
                ],
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// The main places as a capsule of tabs; the current one on the card
/// colour in bold, the rest 600 in ink2 (check + weight, never colour
/// alone, E-G4-7-States D).
class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.bar});

  final ShellBar bar;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Container(
      padding: const EdgeInsets.all(DotSpace.xxs + 1),
      decoration: ShapeDecoration(color: c.tile, shape: const StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, d) in bar.items.indexed)
            if (!d.foot) _tab(context, i, d),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, int i, ShellDestination d) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final selected = i == bar.selected;
    return Semantics(
      button: true,
      selected: selected,
      label: d.semanticLabel,
      excludeSemantics: true,
      onTap: () => bar.onSelect(i),
      child: Material(
        color: selected ? c.raised : Colors.transparent,
        shape: const StadiumBorder(),
        elevation: selected ? 1 : 0,
        shadowColor: c.shadow,
        child: InkWell(
          onTap: () => bar.onSelect(i),
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: DotTouch.min - DotSpace.xs - DotSpace.xxs,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
              child: Center(
                widthFactor: 1,
                // Words only, as iPadOS's top tabs (E-R2-1 1b).
                child: Text(
                  d.label,
                  style: selected
                      ? DotType.emphasis(
                          t.styles.chip.copyWith(color: c.accentInk),
                          bold: true,
                          italic: false,
                        )
                      : t.styles.chip.copyWith(
                          color: c.ink2,
                          fontWeight: FontWeight.w600,
                          fontVariations: const [FontVariation.weight(600)],
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
