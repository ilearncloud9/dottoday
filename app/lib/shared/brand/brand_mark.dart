import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// The Dottoday mark (ED-011): the Today ring with its filled centre, in
/// the accent. [size] across; the ring and the centre keep the board's
/// proportions (E-R2-24 §3: 96 across, a 9 ring, a 34 centre; ED-497).
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = BrandMarkSize.lock, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = DotTheme.of(context).colors.accent;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: size * BrandMarkSize.ring),
        ),
        child: Container(
          width: size * BrandMarkSize.centre,
          height: size * BrandMarkSize.centre,
          decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
        ),
      ),
    );
  }
}
