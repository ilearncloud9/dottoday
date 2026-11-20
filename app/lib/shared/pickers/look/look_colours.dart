import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/colour_sampler.dart';
import 'package:dottoday/shared/pickers/look/gradient_slider.dart';
import 'package:dottoday/shared/pickers/look/look_hex.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/look/look_preview.dart';
import 'package:dottoday/shared/pickers/look/your_colours_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All colours · half sheet (E-Phones-3, ED-156, ED-161): the hex beside
/// the title (tap to type), the task as ahead · in progress · done, Colour
/// and Shade, the 12 Dottoday colours and Your colours. Every change is
/// [onColour] at once, so the task above recolours live.
class LookColours extends StatelessWidget {
  const LookColours({
    required this.colour,
    required this.icon,
    required this.onColour,
    required this.onDone,
    super.key,
  });

  final TaskColor colour;
  final TaskIcon icon;
  final ValueChanged<TaskColor> onColour;
  final VoidCallback onDone;

  void _custom(Color c) => onColour(TaskColor.custom(c));

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final base = colour.color;
    final (:hue, :shade) = hueShadeOf(base);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LookHeader(
          title: Text(l10n.lookAllColours, style: lookTitleStyle(context)),
          trailing: [
            HexChip(colour: base, onColour: _custom),
            LookGlassButton(
              onTap: onDone,
              tooltip: l10n.colourIconDone,
              label: l10n.colourIconDone,
            ),
          ],
        ),
        LookPreview(colour: colour, icon: icon),
        const SizedBox(height: DotSpace.xs),
        _Labelled(
          label: l10n.lookColourSlider,
          child: GradientSlider(
            label: l10n.lookColourSlider,
            colours: hueTrack(base),
            value: hue,
            thumb: base,
            valueText: (v) => hexOf(withHue(base, v)),
            onChanged: (v) => _custom(withHue(base, v)),
          ),
        ),
        _Labelled(
          label: l10n.lookShadeSlider,
          child: GradientSlider(
            label: l10n.lookShadeSlider,
            colours: shadeTrack(base),
            value: shade,
            thumb: base,
            valueText: (v) => hexOf(withShade(base, v)),
            onChanged: (v) => _custom(withShade(base, v)),
          ),
        ),
        const SizedBox(height: DotSpace.s),
        Text(l10n.lookDottodayColours.toUpperCase(), style: t.styles.caption),
        _Grid(
          children: [
            for (final c in TaskColor.values)
              LookSwatch(
                colour: c,
                selected: c == colour,
                size: DotLook.swatch,
                onTap: () => onColour(c),
              ),
          ],
        ),
        const SizedBox(height: DotSpace.s),
        YourColoursRow(colour: colour, onColour: onColour),
        // iOS's own colour picker, with its grid, spectrum and eyedropper
        // (owner, native pass).
        Consumer(
          builder: (context, ref, _) {
            final sampler = ref.watch(colourSamplerProvider);
            if (!sampler.hasSystemPicker || !iosApp(context)) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                // A 48 target, as every touch control here.
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, DotTouch.android),
                ),
                onPressed: () async {
                  final c = await sampler.pickSystem(colour.color);
                  if (c != null) _custom(c);
                },
                child: Text(l10n.lookMoreColours),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// "Colour" / "Shade" beside its slider.
class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      spacing: DotSpace.s + DotSpace.xxs,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: DotLook.sliderLabel),
          child: ExcludeSemantics(
            child: Text(
              label,
              style: t.styles.inspectorLabel.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Six to a row, spread across the width (E-Phones-3).
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < children.length; i += DotLook.swatchColumns)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var k = i; k < i + DotLook.swatchColumns; k++)
              if (k < children.length)
                children[k]
              else
                const SizedBox.square(dimension: DotTouch.android),
          ],
        ),
    ],
  );
}
