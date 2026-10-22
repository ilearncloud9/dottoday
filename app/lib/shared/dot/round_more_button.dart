import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The round ⋯ beside a caption (`A-ios-add-when`), tinted while its
/// menu is open.
class RoundMoreButton extends StatelessWidget {
  const RoundMoreButton({
    required this.tooltip,
    required this.onTap,
    this.open = false,
    this.focusNode,
    super.key,
  });

  /// For a menu anchored here (`MenuAnchor.childFocusNode`), so arrow
  /// keys move from the button into its menu.
  final FocusNode? focusNode;

  final String tooltip;
  final VoidCallback onTap;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return IconButton(
      focusNode: focusNode,
      onPressed: onTap,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: open ? t.colors.accentTint : null,
        side: open ? BorderSide.none : BorderSide(color: t.colors.outline),
      ),
      icon: DotIcon(
        DotGlyphs.more,
        color: open ? t.colors.accentInk : t.colors.muted,
        size: DotSize.rowIcon,
        active: true,
      ),
    );
  }
}
