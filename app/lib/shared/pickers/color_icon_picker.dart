import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:flutter/material.dart';

/// Diameter of a colour swatch: Android's 48 dp target, which also clears
/// the 44 pt iOS floor.
const double _swatch = kMinInteractiveDimension;

/// Block colour row and icon grid (docs/03 §3.4 "Title & icon/colour row").
///
/// The selection is never shown by colour alone: the chosen swatch carries a
/// check mark and the chosen icon a filled background (03 §4).
class ColorIconPicker extends StatelessWidget {
  const ColorIconPicker({
    required this.color,
    required this.icon,
    required this.onColorChanged,
    required this.onIconChanged,
    super.key,
  });

  final TaskColor color;
  final TaskIcon icon;
  final ValueChanged<TaskColor> onColorChanged;
  final ValueChanged<TaskIcon> onIconChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Heading(l10n.colorPickerLabel),
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.s,
          children: [
            for (final c in TaskColor.values)
              _ColorSwatch(
                color: c,
                selected: c == color,
                onTap: () => onColorChanged(c),
              ),
          ],
        ),
        const SizedBox(height: DotSpace.l),
        _Heading(l10n.iconPickerLabel),
        Wrap(
          spacing: DotSpace.xs,
          runSpacing: DotSpace.xs,
          children: [
            for (final i in TaskIcon.picker)
              IconButton(
                isSelected: i == icon,
                onPressed: () => onIconChanged(i),
                tooltip: taskIconName(l10n, i),
                color: t.tasks[color].ink,
                style: IconButton.styleFrom(
                  backgroundColor: i == icon ? t.tasks[color].tint : null,
                ),
                icon: DotIcon(
                  i.glyph!,
                  color: t.tasks[color].ink,
                  active: i == icon,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: DotSpace.s),
      child: Semantics(
        header: true,
        child: Text(text, style: DotTheme.of(context).styles.rowMeta),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final TaskColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    return Semantics(
      button: true,
      selected: selected,
      label: taskColorName(context.l10n, color),
      child: InkResponse(
        onTap: onTap,
        radius: _swatch / 2,
        child: Container(
          width: _swatch,
          height: _swatch,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: t.tasks[color].tint,
            border: Border.all(
              color: swatch.ink,
              width: selected ? DotSpace.xs / 2 : DotSpace.hairline,
            ),
          ),
          child: selected ? DotIcon(DotGlyphs.check, color: swatch.ink) : null,
        ),
      ),
    );
  }
}
