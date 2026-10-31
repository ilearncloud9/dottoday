import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/overlap_knot.dart';
import 'package:flutter/material.dart';

/// "◌ Free until 7:30 PM · no overlap", or the overlap with the knot mark
/// in both tasks' colours (ADR-0015), under a `ThreadPicker` (docs/10 §3;
/// §6 "warns on overlap"). Display values only. Announced politely when it
/// changes.
class PickerCaption extends StatelessWidget {
  const PickerCaption({
    required this.freeUntil,
    required this.color,
    this.overlapTitle,
    this.overlapColor,
    this.overlapCount = 0,
    super.key,
  });

  /// The task being placed: the knot's first strand.
  final TaskColor color;

  /// The first task it collides with: the knot's second strand.
  final TaskColor? overlapColor;

  /// The formatted end of the free room.
  final String freeUntil;

  /// The first task the slot collides with; null when it is free.
  final String? overlapTitle;
  final int overlapCount;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final busy = overlapTitle;
    final text = busy == null
        ? l10n.addFreeUntil(freeUntil)
        : l10n.addOverlaps(overlapCount, busy, overlapCount - 1);
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [
          if (busy == null)
            DotIcon(
              DotGlyphs.freeRing,
              color: t.colors.muted,
              size: DotSize.rowIcon,
            )
          else
            OverlapKnot(
              first: t.tasks[color].color,
              second: t.tasks[overlapColor ?? color].color,
            ),
          Expanded(
            child: Text(
              text,
              style: busy == null
                  ? t.styles.body.copyWith(color: t.colors.muted)
                  : t.styles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
