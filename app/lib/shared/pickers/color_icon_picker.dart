import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
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

  final BlockColor color;
  final BlockIcon icon;
  final ValueChanged<BlockColor> onColorChanged;
  final ValueChanged<BlockIcon> onIconChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Heading(l10n.colorPickerLabel),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final c in BlockColor.values)
              _ColorSwatch(
                color: c,
                selected: c == color,
                onTap: () => onColorChanged(c),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        _Heading(l10n.iconPickerLabel),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final i in BlockIcon.values)
              IconButton(
                isSelected: i == icon,
                onPressed: () => onIconChanged(i),
                tooltip: blockIconName(l10n, i),
                color: t.blocks[color].strong,
                style: IconButton.styleFrom(
                  backgroundColor: i == icon
                      ? t.blocks.fill(color, t.colors.surfaceRaised)
                      : null,
                ),
                icon: Icon(i.icon),
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
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.s),
      child: Semantics(
        header: true,
        child: Text(text, style: AppTheme.of(context).typography.label),
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

  final BlockColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final swatch = t.blocks[color];
    return Semantics(
      button: true,
      selected: selected,
      label: blockColorName(context.l10n, color),
      child: InkResponse(
        onTap: onTap,
        radius: _swatch / 2,
        child: Container(
          width: _swatch,
          height: _swatch,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: t.blocks.fill(color, t.colors.surfaceRaised),
            border: Border.all(
              color: swatch.strong,
              width: selected ? AppSpacing.xs / 2 : AppSpacing.hairline,
            ),
          ),
          child: selected
              ? ExcludeSemantics(child: Icon(Icons.check, color: swatch.strong))
              : null,
        ),
      ),
    );
  }
}
