import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/features/settings/appearance/app_colour.dart';
import 'package:dottoday/shared/pickers/look/gradient_slider.dart';
import 'package:dottoday/shared/pickers/look/look_hex.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/look/your_colours_row.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edit palette · half sheet (E-G3-9b, ED-161): App colour with its hex
/// (tap to type) and Done, Colour and Shade, all colours and Your colours,
/// and what buttons and links use so text stays readable. Every change
/// re-themes the app at once; the stored colour is never adjusted.
Future<void> showEditPalette(BuildContext context) =>
    showAppSheet<void>(context: context, builder: (_) => const _EditPalette());

class _EditPalette extends ConsumerStatefulWidget {
  const _EditPalette();

  @override
  ConsumerState<_EditPalette> createState() => _EditPaletteState();
}

/// A leaf: the colour while it is dragged, written shortly after, so the
/// app re-themes live without a write for every frame of a drag.
class _EditPaletteState extends ConsumerState<_EditPalette> {
  Color? _colour;
  Timer? _write;

  /// Held from the first pick: the last write may land after dispose.
  ProviderContainer? _container;

  @override
  void dispose() {
    _flush();
    super.dispose();
  }

  void _pick(Color c) {
    _container ??= ref.container;
    setState(() => _colour = c);
    _write?.cancel();
    // The theme's quick beat: a drag writes once it pauses (none under
    // reduced motion, where it writes at once).
    _write = Timer(DotTheme.of(context).motion.fast, _flush);
  }

  void _flush() {
    _write?.cancel();
    _write = null;
    final c = _colour;
    final container = _container;
    if (c == null || container == null) return;
    unawaited(setAppColour(container, colour: c));
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final base = _colour ?? appColourOf(profile);
    final (:hue, :shade) = hueShadeOf(base);
    // The ink this colour gets, from the colour itself: the theme follows
    // only once the pick is written.
    final ink = DotColors.custom(t.colors.brightness, base).accentInk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.xs,
      children: [
        LookHeader(
          title: Text(l10n.settingsAppColour, style: lookTitleStyle(context)),
          trailing: [
            HexChip(colour: base, onColour: _pick),
            LookGlassButton(
              onTap: () => Navigator.of(context).pop(),
              tooltip: l10n.colourIconDone,
              label: l10n.colourIconDone,
            ),
          ],
        ),
        _slider(l10n.lookColourSlider, hueTrack(base), hue, base, withHue),
        _slider(l10n.lookShadeSlider, shadeTrack(base), shade, base, withShade),
        const SizedBox(height: DotSpace.s),
        // Upper case on iPhone, as drawn and as Your colours below.
        Text(
          DotIdiom.of(context) == DotIdiom.cupertino
              ? l10n.lookAllColours.toUpperCase()
              : l10n.lookAllColours,
          style: t.styles.caption,
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            for (final c in TaskColor.values)
              LookSwatch(
                colour: c,
                selected: c.color == base,
                size: DotLook.swatch,
                onTap: () => _pick(c.color),
              ),
          ],
        ),
        const SizedBox(height: DotSpace.s),
        YourColoursRow(
          colour: TaskColor.custom(base),
          onColour: (c) => _pick(c.color),
        ),
        if (ink != base)
          Text(
            l10n.settingsAppColourInk(hexOf(ink), hexOf(base)),
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
      ],
    );
  }

  Widget _slider(
    String label,
    List<Color> track,
    double value,
    Color base,
    Color Function(Color, double) move,
  ) {
    final t = DotTheme.of(context);
    return Row(
      spacing: DotSpace.m,
      children: [
        SizedBox(
          width: DotLook.sliderLabel,
          child: Text(label, style: t.styles.rowMeta),
        ),
        Expanded(
          child: GradientSlider(
            label: label,
            colours: track,
            value: value,
            thumb: base,
            valueText: (v) => hexOf(move(base, v)),
            onChanged: (v) => _pick(move(base, v)),
          ),
        ),
      ],
    );
  }
}
