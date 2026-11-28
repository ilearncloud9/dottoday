import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/look/palette_row.dart';
import 'package:flutter/material.dart';

/// Colour and icon, compact (E-Phones, ED-086; ⋯ ED-161): the swipeable
/// palette, then Current, Suggested and Recent icons, then All icons.
class LookCompact extends StatelessWidget {
  const LookCompact({
    required this.colour,
    required this.icon,
    required this.suggested,
    required this.recent,
    required this.onColour,
    required this.onIcon,
    required this.onAllColours,
    required this.onAllIcons,
    required this.onDone,
    super.key,
  });

  final TaskColor colour;
  final TaskIcon icon;
  final List<TaskIcon> suggested;
  final List<TaskIcon> recent;
  final ValueChanged<TaskColor> onColour;
  final ValueChanged<TaskIcon> onIcon;
  final VoidCallback onAllColours;
  final VoidCallback onAllIcons;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final quickSuggested = suggested.where((i) => i != icon).take(2).toList();
    final quickRecent = recent
        .where((i) => i != icon && !quickSuggested.contains(i))
        .take(1)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LookHeader(
          title: Text(l10n.colourIconTitle, style: lookTitleStyle(context)),
          trailing: [
            LookGlassButton(
              onTap: onAllColours,
              tooltip: l10n.lookAllColours,
              glyph: DotGlyphs.more,
            ),
            LookGlassButton(
              onTap: onDone,
              tooltip: l10n.colourIconDone,
              label: l10n.colourIconDone,
            ),
          ],
        ),
        PaletteRow(selected: colour, onPick: onColour),
        const SizedBox(height: DotSpace.l),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotLook.paletteGap,
            children: [
              _Labelled(
                label: l10n.lookCurrent,
                below: true,
                children: [
                  LookIconCircle(
                    icon: icon,
                    colour: colour,
                    selected: true,
                    onTap: onAllIcons,
                    size: DotLook.current,
                  ),
                ],
              ),
              Container(
                width: DotSpace.hairline,
                height: DotLook.current,
                color: t.colors.hairline,
              ),
              if (quickSuggested.isNotEmpty)
                _Labelled(
                  label: l10n.lookSuggested,
                  children: [for (final i in quickSuggested) _quick(i, colour)],
                ),
              if (quickRecent.isNotEmpty)
                _Labelled(
                  label: l10n.lookRecent,
                  children: [for (final i in quickRecent) _quick(i, colour)],
                ),
            ],
          ),
        ),
        const SizedBox(height: DotSpace.l),
        _AllIconsButton(onTap: onAllIcons),
        Padding(
          padding: const EdgeInsets.only(top: DotSpace.s),
          child: Text(
            l10n.lookHint,
            textAlign: TextAlign.center,
            style: t.styles.inspectorLabel,
          ),
        ),
      ],
    );
  }

  Widget _quick(TaskIcon i, TaskColor c) => LookIconCircle(
    icon: i,
    colour: c,
    selected: false,
    onTap: () => onIcon(i),
  );
}

/// A small label over (or under) its icons.
class _Labelled extends StatelessWidget {
  const _Labelled({
    required this.label,
    required this.children,
    this.below = false,
  });

  final String label;
  final List<Widget> children;
  final bool below;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final text = Text(label, style: t.styles.inspectorLabel);
    return Column(
      crossAxisAlignment: below
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      spacing: DotSpace.xs + DotSpace.xxs,
      children: [
        if (!below) text,
        Row(spacing: DotSpace.s + DotSpace.xxs, children: children),
        if (below) text,
      ],
    );
  }
}

/// "All icons · search 525": a card pill in the accent's ink.
class _AllIconsButton extends StatelessWidget {
  const _AllIconsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final style = t.styles.button.copyWith(
      color: t.colors.accentText,
      fontWeight: FontWeight.w600,
    );
    return Material(
      color: t.colors.card,
      shape: StadiumBorder(
        side: BorderSide(color: t.colors.hairline, width: DotSpace.hairline),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: DotLook.allIcons,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: DotSpace.s,
            children: [
              DotIcon(DotGlyphs.search, color: t.colors.accentText),
              Flexible(
                child: Text(
                  context.l10n.lookAllIcons(TaskIcon.picker.length.toString()),
                  style: style,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
