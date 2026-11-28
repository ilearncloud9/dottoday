import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The profile's circle: the name's first letter, or a person glyph
/// without a name (`A-ios-settings`, M6.3). Drawn by Settings' header and
/// the phones' "Settings and account" button (ED-238).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.name,
    this.size = DotSize.dayDot,
    super.key,
  });

  /// The display name, trimmed; empty draws the glyph.
  final String name;

  /// Its diameter: 44 in Settings' header, 32 in the top row's capsule.
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: t.colors.tonal,
      child: name.isEmpty
          ? DotIcon(
              DotGlyphs.person,
              color: t.colors.accentText,
              // 24 in the 44 circle, as before; about 18 in the 32 one.
              size: size * DotSize.navIcon / DotSize.dayDot,
            )
          : Text(
              name.characters.first.toUpperCase(),
              style: t.styles.cardTitle.copyWith(color: t.colors.accentText),
            ),
    );
  }
}
