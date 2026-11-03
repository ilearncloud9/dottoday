import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:flutter/material.dart';

/// The tiles in one row, or — when a label's longest word would not fit
/// its tile at the current text size — two per row, or one: a label never
/// breaks mid-word (accessibility-as-code; found by the M16 goldens).
class SheetTileGrid extends StatelessWidget {
  const SheetTileGrid({required this.tiles, super.key});

  final List<SheetTile> tiles;

  @override
  Widget build(BuildContext context) {
    final style = DotTheme.of(context).styles.button;
    return LayoutBuilder(
      builder: (context, box) {
        bool fits(int perRow) {
          final width =
              (box.maxWidth - DotSpace.s * (perRow - 1)) / perRow -
              2 * DotSpace.xs;
          return tiles.every(
            (t) => longestWordFits(context, t.label, style, width),
          );
        }

        final perRow = [tiles.length, 2, 1].firstWhere(fits, orElse: () => 1);
        return Column(
          spacing: DotSpace.s,
          children: [
            for (var i = 0; i < tiles.length; i += perRow)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.s,
                children: [
                  for (final t in tiles.skip(i).take(perRow))
                    Expanded(child: t),
                  // A short last row keeps the tiles' width.
                  for (
                    var k = tiles.skip(i).take(perRow).length;
                    k < perRow;
                    k++
                  )
                    const Spacer(),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// One action tile of the task sheet: glyph over label, [filled] for the
/// main action, muted and inert without [onTap].
class SheetTile extends StatelessWidget {
  const SheetTile({
    required this.glyph,
    required this.label,
    this.onTap,
    this.filled = false,
    super.key,
  });

  final DotGlyph glyph;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final enabled = onTap != null;
    final ink = filled ? c.onAccent : (enabled ? c.text : c.muted);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: filled ? c.accentFill : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.card),
          side: filled ? BorderSide.none : BorderSide(color: c.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotSize.rowDot * 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: DotSpace.xs,
                children: [
                  DotIcon(glyph, color: ink, active: filled),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: t.styles.button.copyWith(color: ink),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
