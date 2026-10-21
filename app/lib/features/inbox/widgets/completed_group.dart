import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';

/// "✓ Completed · 12", folded until tapped (`A-ios-inbox`, 10 §5.3
/// "Completed group expanded").
class CompletedGroup extends StatelessWidget {
  const CompletedGroup({required this.items, super.key});

  final List<Occurrence> items;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Theme(
      // No dividers: the group sits on the page like the rows above it.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.hairline),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.xxs),
            child: DotIcon(
              DotGlyphs.check,
              color: c.raised,
              size: DotSize.rowIcon - DotSpace.xs,
              active: true,
            ),
          ),
        ),
        title: Text(
          context.l10n.inboxCompleted(items.length),
          style: t.styles.cardTitle.copyWith(color: c.muted),
        ),
        children: [
          for (final o in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                o.title,
                style: t.styles.body.copyWith(
                  color: c.muted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
