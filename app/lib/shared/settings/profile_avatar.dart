import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The profile's circle: the name's first letter, or a person glyph
/// without a name (`A-ios-settings`, M6.3). Drawn by Settings' header and
/// the phones' "Settings and account" button (ED-238).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.name, super.key});

  /// The display name, trimmed; empty draws the glyph.
  final String name;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return CircleAvatar(
      radius: DotSize.dayDot / 2,
      backgroundColor: t.colors.accentTint,
      child: name.isEmpty
          ? DotIcon(DotGlyphs.person, color: t.colors.accentInk)
          : Text(
              name.characters.first.toUpperCase(),
              style: t.styles.cardTitle.copyWith(color: t.colors.accentInk),
            ),
    );
  }
}
