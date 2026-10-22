import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The menu surface (docs/10 §4 "menu corners"): a raised card with the
/// hairline outline, popover corners on iPhone and M3 menu corners
/// elsewhere (the A4 Time ⋯ menu, the spread's Running late).
MenuStyle dotMenuStyle(BuildContext context) {
  final t = DotTheme.of(context);
  final radius = DotIdiom.of(context) == DotIdiom.cupertino
      ? DotRadii.sheet
      : DotRadii.card;
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(t.colors.raised),
    // The outline carries the edge; a raised M3 shadow read as a grey
    // band against the sheet (§2.3 hairline outline instead).
    elevation: const WidgetStatePropertyAll(0),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shadowColor: WidgetStatePropertyAll(DotElevation.floating.first.color),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: t.colors.outline),
      ),
    ),
  );
}
