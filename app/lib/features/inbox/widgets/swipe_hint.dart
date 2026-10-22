import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "← Schedule · Move to Trash →" under the first row, so the swipes are
/// discoverable (`A-ios-inbox`). Arrows follow the reading direction.
class InboxSwipeHint extends StatelessWidget {
  const InboxSwipeHint({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final style = t.styles.rowMeta;
    final arrow = DotSize.rowIcon - DotSpace.xs;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.l,
          vertical: DotSpace.s,
        ),
        child: Row(
          children: [
            DotIcon(
              rtl ? DotGlyphs.arrowRight : DotGlyphs.arrowLeft,
              color: t.colors.muted,
              size: arrow,
            ),
            const SizedBox(width: DotSpace.xs),
            Expanded(child: Text(l10n.inboxSchedule, style: style)),
            Expanded(
              child: Text(
                l10n.inboxTrash,
                style: style,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: DotSpace.xs),
            DotIcon(
              rtl ? DotGlyphs.arrowLeft : DotGlyphs.arrowRight,
              color: t.colors.muted,
              size: arrow,
            ),
          ],
        ),
      ),
    );
  }
}
