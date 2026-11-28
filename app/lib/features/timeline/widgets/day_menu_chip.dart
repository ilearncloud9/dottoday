import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/solid_chrome.dart';
import 'package:flutter/material.dart';

/// "Day ▾" floating over a phone's day (E-Phones, ED-093, ED-124): the
/// Day menu's button, above the tab bar's end on the iPhone and its start
/// on Android (E-Phones frames 1 and 5).
class DayMenuChip extends StatelessWidget {
  const DayMenuChip({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: DotTouch.android),
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
      decoration: BoxDecoration(
        color: t.colors.raised,
        border: solidOutline(context),
        borderRadius: BorderRadius.circular(DotRadii.pill),
        boxShadow: DotElevation.capsule(t.colors),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.xs,
        children: [
          Text(context.l10n.workspaceDay, style: t.styles.button),
          DotIcon(
            DotGlyphs.chevronDown,
            color: t.colors.text,
            size: DotSize.rowIcon,
          ),
        ],
      ),
    );
  }
}
