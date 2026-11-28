import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/glass_capsule.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:flutter/material.dart';

/// The 12 Dottoday colours in one swipeable row (E-Phones "Colour and
/// icon, compact"): on a card in the compact sheet, on glass when pinned
/// over All icons. A custom [selected] colour leads the row, so it is
/// always in view and picked.
class PaletteRow extends StatefulWidget {
  const PaletteRow({
    required this.selected,
    required this.onPick,
    this.glass = false,
    super.key,
  });

  final TaskColor selected;
  final ValueChanged<TaskColor> onPick;

  /// Pinned over the icon library (Liquid Glass, ED-086).
  final bool glass;

  @override
  State<PaletteRow> createState() => _PaletteRowState();
}

/// A leaf: scrolls the picked colour into view once.
class _PaletteRowState extends State<PaletteRow> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Opens with the picked colour in view (the board's row shows six).
  void _reveal() {
    final i = TaskColor.values.indexOf(widget.selected);
    if (!mounted || i < 0 || !_scroll.hasClients) return;
    const step = DotLook.paletteDot + DotLook.paletteGap;
    final target = (i - 2) * step;
    _scroll.jumpTo(target.clamp(0, _scroll.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final colours = [
      if (widget.selected.isCustom) widget.selected,
      ...TaskColor.values,
    ];
    final row = Semantics(
      label: context.l10n.lookPaletteLabel,
      container: true,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.s + DotSpace.xxs,
          vertical: DotSpace.xs + DotSpace.xxs,
        ),
        // The ring draws outside each dot.
        clipBehavior: Clip.none,
        child: Row(
          // The drawn 14 between dots, less the targets' extra width.
          spacing: DotLook.paletteGap - (DotTouch.android - DotLook.paletteDot),
          children: [
            for (final c in colours)
              LookSwatch(
                colour: c,
                selected: c == widget.selected,
                onTap: () => widget.onPick(c),
              ),
          ],
        ),
      ),
    );
    const shape = BorderRadius.all(Radius.circular(DotLook.paletteRadius));
    if (widget.glass) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: DotElevation.capsule(t.colors),
        ),
        child: GlassCapsule(
          child: ClipRRect(borderRadius: shape, child: row),
        ),
      );
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: shape,
        color: t.colors.card,
        border: Border.all(color: t.colors.hairline, width: DotSpace.hairline),
      ),
      child: row,
    );
  }
}
