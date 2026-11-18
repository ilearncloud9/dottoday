import 'dart:ui';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The iPhone's glass capsule (ED-034): Sync and the profile share one in
/// Today's top row, and "‹ Today" is one of its own. Flutter's
/// approximation of Liquid Glass, as E-Phones draws it: a blur, a light
/// top-to-bottom fill and a bright top edge. With Increase Contrast it is
/// a solid card with an outline (rules §12.4).
class GlassCapsule extends StatelessWidget {
  const GlassCapsule({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    const shape = BorderRadius.all(Radius.circular(DotSize.capsule / 2));
    final solid = MediaQuery.highContrastOf(context);
    final fill = BoxDecoration(
      borderRadius: shape,
      color: solid ? c.card : null,
      gradient: solid
          ? null
          : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.glassTop, c.glassBottom],
            ),
      border: solid
          ? Border.all(color: c.outline)
          : Border(top: BorderSide(color: c.glassEdge)),
    );
    final body = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DotSize.capsule),
      child: DecoratedBox(decoration: fill, child: child),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: DotElevation.capsule(c),
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: solid
            ? body
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: ChromeAlpha.glassBlur / 2,
                  sigmaY: ChromeAlpha.glassBlur / 2,
                ),
                child: body,
              ),
      ),
    );
  }
}
