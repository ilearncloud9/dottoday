import 'dart:ui' show ImageFilter;

import 'package:dottoday/core/editing/add_anchor.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/solid_chrome.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';

/// Android compact shell (ED-125, revised option C): a floating toolbar
/// 16 from the start, 24 above the bottom, with the + beside it, both
/// frosted over the content on Android 12+ ([frosted]) and solid tonal
/// otherwise or with high contrast. The current place sits in a tonal
/// block with its name; Settings stays a tab until M18.7.
class MaterialBarShell extends StatelessWidget {
  const MaterialBarShell({
    required this.bar,
    required this.body,
    this.frosted = false,
    super.key,
  });

  final ShellBar bar;
  final Widget body;
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    final onAdd = bar.onAdd;
    final inset = MediaQuery.paddingOf(context).bottom;
    final glass = frosted && !solidChrome(context);
    return Scaffold(
      body: Stack(
        children: [
          // Content runs under the toolbar; its end clears it.
          ChromeClearance(
            bottom: DotSize.androidBar + DotSize.androidBarBottom + DotSpace.l,
            child: body,
          ),
          if (bar.items.isNotEmpty)
            PositionedDirectional(
              start: DotSpace.l,
              end: onAdd == null
                  ? DotSpace.l
                  : DotSpace.l + DotSize.androidFab + DotSpace.s,
              bottom: inset + DotSize.androidBarBottom,
              height: DotSize.androidBar,
              child: _Toolbar(bar: bar, glass: glass),
            ),
          if (onAdd != null)
            PositionedDirectional(
              end: DotSpace.l,
              bottom: inset + DotSize.androidFabBottom,
              child: AddDraggable(
                child: AddAnchor(
                  child: _Add(onAdd: onAdd, label: bar.addLabel, glass: glass),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// [child] on a [fill] that is frosted over the content when [glass]
/// (24 blur), else the solid colour.
class _Frost extends StatelessWidget {
  const _Frost({
    required this.fill,
    required this.alpha,
    required this.radius,
    required this.shadows,
    required this.glass,
    required this.child,
  });

  final Color fill;
  final double alpha;
  final double radius;
  final List<BoxShadow> shadows;
  final bool glass;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: glass ? fill.withValues(alpha: alpha) : fill,
        borderRadius: shape,
        border: solidOutline(context),
      ),
      child: child,
    );
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: shape, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: shape,
        child: glass
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: ChromeAlpha.blur / 2,
                  sigmaY: ChromeAlpha.blur / 2,
                ),
                child: box,
              )
            : box,
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.bar, required this.glass});

  final ShellBar bar;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return _Frost(
      fill: c.barAndroid,
      alpha: ChromeAlpha.bar,
      radius: DotSize.androidBar / 2,
      shadows: DotElevation.floating,
      glass: glass,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.xs,
          vertical: DotSpace.xs,
        ),
        child: Row(
          children: [
            for (final (i, d) in bar.items.indexed)
              Expanded(child: _item(context, i, d)),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i, ShellDestination d) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final selected = i == bar.selected;
    final ink = selected ? c.onTonalAndroid : c.ink2;
    return Semantics(
      button: true,
      selected: selected,
      label: d.semanticLabel,
      excludeSemantics: true,
      onTap: () => bar.onSelect(i),
      child: Material(
        color: selected ? c.tonalAndroid : Colors.transparent,
        borderRadius: BorderRadius.circular(DotRadii.tile),
        child: InkWell(
          onTap: () => bar.onSelect(i),
          borderRadius: BorderRadius.circular(DotRadii.tile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: DotSpace.xxs,
            children: [
              ShellIcon(destination: d, active: selected, color: ink),
              Text(
                d.label,
                maxLines: 1,
                style: t.styles
                    .androidTab(
                      selected ? t.styles.tabLabelActive : t.styles.tabLabel,
                    )
                    .copyWith(color: ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The + (ED-125, ED-240): 56, radius 16, frosted tonal, named "Add a
/// task".
class _Add extends StatelessWidget {
  const _Add({required this.onAdd, required this.label, required this.glass});

  final VoidCallback onAdd;
  final String label;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return _Frost(
      fill: c.fabAndroid,
      alpha: ChromeAlpha.fab,
      radius: DotRadii.fabAndroid,
      shadows: DotElevation.floating,
      glass: glass,
      child: SizedBox.square(
        dimension: DotSize.androidFab,
        child: IconButton(
          onPressed: onAdd,
          tooltip: label,
          icon: DotIcon(DotGlyphs.add, color: c.onTonalAndroid, active: true),
        ),
      ),
    );
  }
}
