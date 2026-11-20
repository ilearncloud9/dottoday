import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/data/look/your_colours.dart';
import 'package:dottoday/shared/pickers/look/look_custom.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/look/look_popover_icons.dart';
import 'package:dottoday/shared/pickers/look/look_sources.dart';
import 'package:dottoday/shared/pickers/look/your_colours_row.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Mac and web colour and icon popover (E-G3-9b "Mac · Colour
/// popover", E-FullA-v2 inspector; ED-156; owner 4c-3: icons in it):
/// Dottoday colours, Your colours, the Icon row with All icons…, then
/// Custom colour… expanding in place. Picks land at once and it stays
/// open (↵ picks, arrows move, Esc closes). With [onChanged] null it is
/// the colour alone (the select bar), and a pick closes it with the
/// colour.
class LookPopover extends ConsumerStatefulWidget {
  const LookPopover({
    required this.colour,
    required this.icon,
    required this.title,
    required this.onChanged,
    super.key,
  });

  final TaskColor colour;
  final TaskIcon icon;
  final String title;
  final ValueChanged<TaskLook>? onChanged;

  @override
  ConsumerState<LookPopover> createState() => _LookPopoverState();
}

/// A leaf: the look so far, and whether Custom colour… or the library is
/// open.
class _LookPopoverState extends ConsumerState<LookPopover> {
  late var _colour = widget.colour;
  late var _icon = widget.icon;
  var _custom = false;
  var _library = false;

  bool get _colourOnly => widget.onChanged == null;

  void _pickColour(TaskColor c) {
    if (_colourOnly) {
      Navigator.of(context).pop(c);
      return;
    }
    setState(() => _colour = c);
    widget.onChanged!((color: c, icon: _icon));
  }

  void _pickIcon(TaskIcon i) {
    setState(() {
      _icon = i;
      _library = false;
    });
    widget.onChanged?.call((color: _colour, icon: i));
    unawaited(ref.read(recentIconsProvider.notifier).use(i.key));
  }

  /// Use and save: the colour lands and joins Your colours (ED-156).
  void _use(Color c) {
    unawaited(saveYourColour(ProviderScope.containerOf(context), hexOf(c)));
    setState(() => _custom = false);
    _pickColour(TaskColor.custom(c));
  }

  @override
  Widget build(BuildContext context) {
    if (_library) {
      return LookPopoverIcons(
        colour: _colour,
        icon: _icon,
        recent: recentIcons(ref),
        onIcon: _pickIcon,
        onBack: () => setState(() => _library = false),
      );
    }
    return Shortcuts(
      // The web maps arrows to scrolling; here they move between choices.
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(
          TraversalDirection.left,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(
          TraversalDirection.right,
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
          TraversalDirection.up,
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
          TraversalDirection.down,
        ),
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DotLook.popoverPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.xs,
          children: _sections(context),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return [
      Text(l10n.lookDottodayColours, style: lookPopoverLabel(t)),
      _grid([
        for (final c in TaskColor.values)
          LookSwatch(
            colour: c,
            selected: c == _colour,
            autofocus: c == _colour,
            size: DotLook.popoverDot,
            target: DotTouch.min,
            onTap: () => _pickColour(c),
          ),
      ]),
      YourColoursRow(colour: _colour, onColour: _pickColour, pointer: true),
      // While Custom colour… is open the popover is the board's: colours
      // and the custom panel, without the icon row.
      if (!_colourOnly && !_custom) ...[
        Divider(color: t.colors.hairline, height: DotSpace.m),
        _IconRow(
          colour: _colour,
          icon: _icon,
          title: widget.title,
          onIcon: _pickIcon,
          onAll: () => setState(() => _library = true),
        ),
      ],
      Divider(color: t.colors.hairline, height: DotSpace.m),
      if (_custom)
        LookCustom(
          start: _colour.color,
          icon: _icon,
          onUse: _use,
          onCancel: () => setState(() => _custom = false),
        )
      else
        OutlinedButton(
          onPressed: () => setState(() => _custom = true),
          child: Text(l10n.lookCustomColourOpen),
        ),
    ];
  }

  /// Six to a row, spread across the popover (E-G3-9b).
  Widget _grid(List<Widget> swatches) => Column(
    children: [
      for (var i = 0; i < swatches.length; i += DotLook.swatchColumns)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: swatches.sublist(
            i,
            (i + DotLook.swatchColumns).clamp(0, swatches.length),
          ),
        ),
    ],
  );
}

/// Icon: the current one, what the title suggests and the recent ones,
/// then All icons… (owner, 4c-3).
class _IconRow extends ConsumerWidget {
  const _IconRow({
    required this.colour,
    required this.icon,
    required this.title,
    required this.onIcon,
    required this.onAll,
  });

  final TaskColor colour;
  final TaskIcon icon;
  final String title;
  final ValueChanged<TaskIcon> onIcon;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final shown = <TaskIcon>{
      icon,
      ...suggestedIcons(context, title),
      ...recentIcons(ref),
    }.take(DotLook.swatchColumns);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.lookIcon, style: lookPopoverLabel(t))),
            TextButton(onPressed: onAll, child: Text(l10n.lookAllIconsOpen)),
          ],
        ),
        Row(
          spacing: DotSpace.s,
          children: [
            for (final i in shown)
              LookIconCircle(
                icon: i,
                colour: colour,
                selected: i == icon,
                size: DotLook.popoverIcon,
                onTap: () => onIcon(i),
              ),
          ],
        ),
      ],
    );
  }
}
