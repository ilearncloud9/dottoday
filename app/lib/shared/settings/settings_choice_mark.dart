import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A pick list's mark for [selected]: the iPhone's check, Material's radio
/// button (E-R2-33: Android Sounds "M3 radio buttons for the choice").
/// The row itself takes the tap; the radio only shows the state. A list
/// that takes several ([multiple]) has Material's checkbox instead.
class SettingsChoiceMark extends StatelessWidget {
  const SettingsChoiceMark({
    required this.selected,
    this.multiple = false,
    super.key,
  });

  final bool selected;
  final bool multiple;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    if (DotIdiom.of(context) == DotIdiom.cupertino) {
      return selected
          ? DotIcon(DotGlyphs.check, color: t.colors.accentInk)
          : const SizedBox.shrink();
    }
    if (multiple) {
      return ExcludeSemantics(
        child: IgnorePointer(
          child: Checkbox(value: selected, onChanged: (_) {}),
        ),
      );
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RadioGroup<bool>(
          groupValue: selected,
          onChanged: (_) {},
          child: const Radio<bool>(value: true),
        ),
      ),
    );
  }
}
