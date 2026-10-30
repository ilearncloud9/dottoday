import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';

/// Medium and expanded shell (`A-mac-today-alt1-spread`): a left rail of
/// 16-radius tiles, Settings pinned to the bottom, hairline divider.
class DotRailShell extends StatelessWidget {
  const DotRailShell({required this.bar, required this.body, super.key});

  final ShellBar bar;
  final Widget body;

  /// Rail width (`A-mac-*`: ≈ 77 pt).
  static const double width = 80;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final items = bar.items;
    // The last destination (Settings) sits at the foot of the rail.
    final top = items.length - 1;
    return Scaffold(
      body: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
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
                      if (bar.onAdd case final onAdd?)
                        AddDraggable(
                          child: _RailAdd(onAdd: onAdd, label: bar.addLabel),
                        ),
                      for (var i = 0; i < top; i++) _tile(i),
                      const Spacer(),
                      _tile(top),
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
      child: Material(
        color: selected
            ? Color.alphaBlend(c.accentTint, c.surface)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(DotRadii.railItem),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DotRadii.railItem),
          child: SizedBox(
            width: _size,
            height: _size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: DotSpace.xxs,
              children: [
                ShellIcon(
                  destination: destination,
                  active: selected,
                  color: selected ? c.accent : c.text,
                ),
                Text(
                  destination.label,
                  maxLines: 1,
                  style: t.styles
                      .androidTab(
                        selected ? t.styles.tabLabelActive : t.styles.tabLabel,
                      )
                      .copyWith(color: selected ? c.accentInk : c.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      child: IconButton.filled(
        onPressed: onAdd,
        tooltip: label,
        style: IconButton.styleFrom(
          backgroundColor: c.accent,
          minimumSize: const Size.square(DotTouch.android + DotSpace.s),
        ),
        icon: DotIcon(DotGlyphs.add, color: c.onAccent, active: true),
      ),
    );
  }
}
