import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A key drawn as the boards' light key cap: "n" on the web's Add, "t"
/// and "/" in the web's sidebars (E-R2-30). [color] is the outline and the
/// letter; the secondary ink when null. Decorative: the row it sits in
/// names its key for a screen reader, or the key is in the ? list.
class KeyCap extends StatelessWidget {
  const KeyCap(this.cap, {this.color, super.key});

  final String cap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ink = color ?? t.colors.secondary;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DotRadii.field),
          border: Border.all(color: ink),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.xs),
          child: Text(cap, style: t.styles.rowMeta.copyWith(color: ink)),
        ),
      ),
    );
  }
}
