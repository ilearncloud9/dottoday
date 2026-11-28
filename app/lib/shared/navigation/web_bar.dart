import 'package:dottoday/core/editing/add_anchor.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';

/// Compact web (E-MobileWeb, ED-172): its own solid bar on the page
/// colour with a hairline, labelled icons and the web focus ring; never
/// the iOS glass bar or the Android toolbar. "+ Add" sits above it at the
/// end. The browser's own Back and gestures stay the browser's.
class WebBarShell extends StatelessWidget {
  const WebBarShell({required this.bar, required this.body, super.key});

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
              child: AddAnchor(
                child: FloatingActionButton.extended(
                  onPressed: onAdd,
                  tooltip: bar.addLabel,
                  backgroundColor: c.accent,
                  foregroundColor: c.onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DotRadii.webAdd),
                  ),
                  icon: DotIcon(DotGlyphs.add, color: c.onAccent, active: true),
                  label: Text(
                    context.l10n.addAdd,
                    style: t.styles.button.copyWith(color: c.onAccent),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: bar.items.isEmpty
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                color: c.ground,
                border: Border(top: BorderSide(color: c.hairlineStrong)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: DotSize.webBar,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DotSpace.xs + DotSpace.xxs,
                    ),
                    child: Row(
                      children: [
                        for (final (i, d) in bar.items.indexed)
                          Expanded(child: _item(context, i, d)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _item(BuildContext context, int i, ShellDestination d) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final selected = i == bar.selected;
    final label = selected
        ? DotType.emphasis(
            t.styles.tabLabelActive.copyWith(color: c.accentText),
            bold: true,
            italic: false,
          )
        : t.styles.tabLabel.copyWith(color: c.ink2);
    return Semantics(
      button: true,
      selected: selected,
      label: d.semanticLabel,
      excludeSemantics: true,
      onTap: () => bar.onSelect(i),
      child: InkWell(
        onTap: () => bar.onSelect(i),
        borderRadius: BorderRadius.circular(DotRadii.webIndicator),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: DotSpace.xxs + 1,
            children: [
              Container(
                width: DotSize.webBarIndicator.width,
                height: DotSize.webBarIndicator.height,
                decoration: BoxDecoration(
                  color: selected ? c.tonal : null,
                  borderRadius: BorderRadius.circular(DotRadii.webIndicator),
                ),
                child: Center(
                  child: ShellIcon(
                    destination: d,
                    active: selected,
                    color: selected ? c.accentText : c.ink2,
                  ),
                ),
              ),
              Text(d.label, maxLines: 1, style: label),
            ],
          ),
        ),
      ),
    );
  }
}
