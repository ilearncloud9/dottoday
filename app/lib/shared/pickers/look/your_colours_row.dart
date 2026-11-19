import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/your_colours.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// YOUR COLOURS (E-Phones-3, ED-221): the account's own colours, newest
/// first, synced; + saves the colour in use; Edit lets a tap remove one
/// (tasks keep it, ED-220).
class YourColoursRow extends ConsumerStatefulWidget {
  const YourColoursRow({
    required this.colour,
    required this.onColour,
    super.key,
  });

  final TaskColor colour;
  final ValueChanged<TaskColor> onColour;

  @override
  ConsumerState<YourColoursRow> createState() => _YourColoursRowState();
}

/// A leaf: whether Edit is on.
class _YourColoursRowState extends ConsumerState<YourColoursRow> {
  var _editing = false;

  ProviderContainer get _container => ProviderScope.containerOf(context);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final saved = [
      for (final hex
          in ref.watch(currentProfileProvider).value?.yourColours ??
              const <String>[])
        TaskColor.fromKey(hex),
    ];
    final current = hexOf(widget.colour.color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.lookYourColours.toUpperCase(),
                style: t.styles.caption,
              ),
            ),
            if (saved.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _editing = !_editing),
                child: Text(_editing ? l10n.colourIconDone : l10n.lookEdit),
              ),
          ],
        ),
        Wrap(
          spacing: DotSpace.xs,
          children: [
            for (final c in saved)
              LookSwatch(
                colour: c,
                size: DotLook.swatch,
                selected: !_editing && c == widget.colour,
                label: _editing ? l10n.lookRemoveColour(c.key) : null,
                onTap: _editing
                    ? () => unawaited(removeYourColour(_container, c.key))
                    : () => widget.onColour(c),
              ),
            // Only a colour of one's own is saved; the 12 are always above.
            if (!_editing &&
                widget.colour.isCustom &&
                !saved.any((c) => c.key == current))
              _AddButton(
                onTap: () => unawaited(saveYourColour(_container, current)),
              ),
          ],
        ),
      ],
    );
  }
}

/// + : saves the colour in use.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: context.l10n.lookAddColour,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: DotTouch.android,
          child: Center(
            child: Container(
              width: DotLook.swatch,
              height: DotLook.swatch,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.colors.muted,
                  width: DotLook.outline,
                ),
              ),
              child: DotIcon(DotGlyphs.add, color: t.colors.text),
            ),
          ),
        ),
      ),
    );
  }
}
