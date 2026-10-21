import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Whether a click should add to the selection rather than open: Shift,
/// ⌘ or Ctrl held (docs/03 §3.2 desktop multi-select).
bool selectModifierHeld() {
  final k = HardwareKeyboard.instance;
  return k.isShiftPressed || k.isMetaPressed || k.isControlPressed;
}

/// A task row in or out of multi-select (docs/03 §3.2, R-05).
///
/// Out of it, screen readers get a "Select" action (R-12). In it, a tap
/// anywhere on the row toggles it, and a ring at the end shows the state:
/// empty, or filled with a check — never colour alone.
class SelectableTaskRow extends StatelessWidget {
  const SelectableTaskRow({
    required this.selecting,
    required this.selected,
    required this.label,
    required this.onSelect,
    required this.child,
    super.key,
  });

  final bool selecting;
  final bool selected;

  /// The row's screen-reader label while selecting.
  final String label;
  final VoidCallback onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!selecting) {
      return Semantics(
        container: true,
        customSemanticsActions: {
          CustomSemanticsAction(label: context.l10n.selectAction): onSelect,
        },
        child: child,
      );
    }
    final c = DotTheme.of(context).colors;
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onSelect,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelect,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? c.accentTint : null,
            borderRadius: BorderRadius.circular(DotRadii.card),
          ),
          child: Stack(
            children: [
              AbsorbPointer(child: child),
              PositionedDirectional(
                end: 0,
                top: 0,
                child: _Check(selected: selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Container(
      width: DotTouch.min,
      height: DotTouch.min,
      alignment: Alignment.center,
      // Opaque, so the done circle under it never shows through.
      color: selected ? Color.alphaBlend(c.accentTint, c.raised) : c.raised,
      child: Container(
        width: DotSize.rowIcon + DotSpace.s,
        height: DotSize.rowIcon + DotSpace.s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? c.accentFill : c.raised,
          border: selected
              ? null
              : Border.all(color: c.outline, width: DotSize.smallDotOutline),
        ),
        child: selected
            ? DotIcon(
                DotGlyphs.check,
                color: c.onAccent,
                size: DotSize.rowIcon - DotSpace.xs,
                active: true,
              )
            : null,
      ),
    );
  }
}
