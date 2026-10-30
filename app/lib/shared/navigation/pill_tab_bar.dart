import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';

/// iPhone compact shell (`Main`): a floating pill tab bar with the round
/// accent add button beside it; pages scroll underneath.
class PillTabShell extends StatelessWidget {
  const PillTabShell({required this.bar, required this.body, super.key});

  final ShellBar bar;
  final Widget body;

  /// Pill and add-button height (`Main`: 60 pt).
  static const double height = 60;

  static const double _margin = DotSpace.l;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // extendBody already adds the floating bar's height to the body's
      // bottom padding, which scroll views honour; no extra clearance.
      body: body,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(_margin, 0, _margin, _margin),
        child: Row(
          spacing: DotSpace.m,
          children: [
            Expanded(child: _Pill(bar: bar)),
            if (bar.onAdd case final onAdd?)
              AddDraggable(
                child: _AddButton(onAdd: onAdd, label: bar.addLabel),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.bar});

  final ShellBar bar;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Container(
      height: PillTabShell.height,
      padding: const EdgeInsets.all(DotSpace.xs),
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(DotRadii.pill),
        border: Border.all(color: c.outline, width: DotSpace.hairline),
        boxShadow: DotElevation.floating,
      ),
      child: Row(
        children: [
          for (final (i, d) in bar.items.indexed)
            Expanded(
              child: _Tab(
                destination: d,
                selected: i == bar.selected,
                onTap: () => bar.onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final ink = selected ? c.accentInk : c.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: t.motion.fast,
          curve: t.motion.curve,
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: selected ? Color.alphaBlend(c.accentTint, c.raised) : null,
          ),
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
                style: (selected ? t.styles.tabLabelActive : t.styles.tabLabel)
                    .copyWith(color: ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onAdd, required this.label});

  final VoidCallback onAdd;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onAdd,
      child: Material(
        color: c.accent,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          onTap: onAdd,
          customBorder: const CircleBorder(),
          child: Container(
            width: PillTabShell.height,
            height: PillTabShell.height,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: DotElevation.floating,
            ),
            child: DotIcon(DotGlyphs.add, color: c.onAccent, active: true),
          ),
        ),
      ),
    );
  }
}
