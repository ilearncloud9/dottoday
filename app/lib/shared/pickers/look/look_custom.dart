import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/colour_sampler.dart';
import 'package:dottoday/shared/pickers/look/colour_field.dart';
import 'package:dottoday/shared/pickers/look/gradient_slider.dart';
import 'package:dottoday/shared/pickers/look/look_hex.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/look/look_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom colour…, expanded in the Mac and web popover (E-G3-9b "Mac ·
/// Colour popover", ED-156, ED-157): the saturation and brightness field,
/// the hue strip, the hex with the eyedropper, the task as ahead · in
/// progress · done, then Use and save or Cancel; on the Mac, Show
/// Colours… opens the system panel. Nothing lands until Use and save.
class LookCustom extends ConsumerStatefulWidget {
  const LookCustom({
    required this.start,
    required this.icon,
    required this.onUse,
    required this.onCancel,
    super.key,
  });

  final Color start;
  final TaskIcon icon;

  /// Use and save: the colour, for the task and Your colours.
  final ValueChanged<Color> onUse;
  final VoidCallback onCancel;

  @override
  ConsumerState<LookCustom> createState() => _LookCustomState();
}

/// A leaf: the colour being made, kept as HSV so a grey keeps its hue.
class _LookCustomState extends ConsumerState<LookCustom> {
  late var _hsv = HSVColor.fromColor(widget.start);
  var _panel = false;

  // Kept, so dispose can close the panel without reading ref.
  late final ColourSampler _sampler = ref.read(colourSamplerProvider);

  Color get _colour => _hsv.toColor();

  @override
  void dispose() {
    if (_panel) unawaited(_sampler.closePanel());
    super.dispose();
  }

  void _set(HSVColor c) => setState(() => _hsv = c);

  /// A typed or sampled colour; its hue is kept when it is a grey.
  void _fromColour(Color c) {
    final next = HSVColor.fromColor(c);
    _set(next.saturation == 0 ? next.withHue(_hsv.hue) : next);
  }

  Future<void> _sample() async {
    final c = await _sampler.sample();
    if (c != null && mounted) _fromColour(c);
  }

  Future<void> _showPanel() async {
    _panel = true;
    await _sampler.openPanel(_colour, (c) {
      if (mounted) _fromColour(c);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final sampler = ref.watch(colourSamplerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.s,
      children: [
        Text(l10n.lookCustomColour, style: lookPopoverLabel(t)),
        ColourField(value: _hsv, onChanged: _set),
        GradientSlider(
          label: l10n.lookHueSlider,
          colours: [
            for (var i = 0; i < DotLook.hueStops; i++)
              HSVColor.fromAHSV(
                1,
                360 * i / (DotLook.hueStops - 1) % 360,
                1,
                1,
              ).toColor(),
          ],
          value: _hsv.hue / 360,
          thumb: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
          valueText: (v) => hexOf(_hsv.withHue(_hue(v)).toColor()),
          onChanged: (v) => _set(_hsv.withHue(_hue(v))),
          track: DotLook.strip,
          thumbSize: DotLook.stripThumb,
        ),
        Row(
          spacing: DotSpace.s,
          children: [
            Expanded(
              child: HexChip(
                colour: _colour,
                onColour: _fromColour,
                wide: true,
              ),
            ),
            if (sampler.canSample)
              IconButton.outlined(
                tooltip: l10n.lookEyedropper,
                onPressed: () => unawaited(_sample()),
                icon: DotIcon(DotGlyphs.eyedropper, color: t.colors.text),
              ),
          ],
        ),
        LookPreview(colour: TaskColor.custom(_colour), icon: widget.icon),
        Row(
          spacing: DotSpace.s,
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => widget.onUse(_colour),
                child: Text(l10n.lookUseAndSave),
              ),
            ),
            OutlinedButton(
              onPressed: widget.onCancel,
              child: Text(l10n.editorCancel),
            ),
          ],
        ),
        if (sampler.hasPanel)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => unawaited(_showPanel()),
              child: Text(l10n.lookShowColours),
            ),
          ),
      ],
    );
  }

  static double _hue(double v) => (v * 360).clamp(0, 359.9);
}
