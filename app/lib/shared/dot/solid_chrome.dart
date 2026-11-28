import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// Carries the system's Reduce Transparency down the tree (ED-248 C):
/// Flutter does not report it, so the app reads it per platform
/// (`reduceTransparencyProvider`) and places this above its routes.
class ReduceTransparencyScope extends InheritedWidget {
  const ReduceTransparencyScope({
    required this.on,
    required super.child,
    super.key,
  });

  final bool on;

  @override
  bool updateShouldNotify(ReduceTransparencyScope old) => old.on != on;
}

/// Whether floating glass is painted solid (ED-248 C, E-G4-7-States D4):
/// with Reduce Transparency or Increase Contrast on.
bool solidChrome(BuildContext context) {
  final scope = context
      .dependOnInheritedWidgetOfExactType<ReduceTransparencyScope>();
  return (scope?.on ?? false) ||
      (MediaQuery.maybeHighContrastOf(context) ?? false);
}

/// The 1.5 outline glass takes when it is solid, in the secondary colour
/// (5.5:1 light, 8.5:1 dark); null otherwise.
Border? solidOutline(BuildContext context) => solidChrome(context)
    ? Border.all(
        color: DotTheme.of(context).colors.muted,
        width: DotSize.solidOutline,
      )
    : null;
