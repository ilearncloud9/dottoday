import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/glass_capsule.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:flutter/material.dart';

/// The sheets' title style: Manrope 20/700 on iPhone, the Android sheet
/// title there (E-Phones-3's Android frames).
TextStyle lookTitleStyle(BuildContext context) {
  final t = DotTheme.of(context);
  return DotIdiom.of(context) == DotIdiom.cupertino
      ? t.styles.lookTitle
      : t.styles.sheetTitleAndroid;
}

/// The pickers' title row (E-Phones, E-Phones-3): [title] (a widget, so
/// All icons can lead with its dot), then [trailing] (⋯, a hex, Done).
class LookHeader extends StatelessWidget {
  const LookHeader({required this.title, required this.trailing, super.key});

  final Widget title;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: DotLook.header,
    child: Row(
      spacing: DotSpace.s,
      children: [
        Expanded(child: Semantics(header: true, child: title)),
        ...trailing,
      ],
    ),
  );
}

/// A glass header button (E-Phones): ⋯ as a circle, Done as a pill.
class LookGlassButton extends StatelessWidget {
  const LookGlassButton({
    required this.onTap,
    required this.tooltip,
    this.glyph,
    this.label,
    super.key,
  });

  final VoidCallback onTap;
  final String tooltip;
  final DotGlyph? glyph;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final text = label;
    // Android mirrors the iPhone's sheet with its own components (owner,
    // 4c-2): a tonal ⋯ and a filled Done, as E-Phones-3's Android frames.
    if (DotIdiom.of(context) == DotIdiom.material) {
      return text == null
          ? IconButton.filledTonal(
              onPressed: onTap,
              tooltip: tooltip,
              icon: DotIcon(glyph!, color: t.colors.ink),
            )
          : FilledButton(onPressed: onTap, child: Text(text));
    }
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // 44 / 48 to touch; the glass is drawn 40 high, as on the board.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: DotTouch.android,
              minHeight: DotTouch.android,
            ),
            child: Center(
              child: SizedBox(
                height: DotLook.headerButton,
                width: text == null ? DotLook.headerButton : null,
                child: GlassCapsule(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: text == null ? 0 : DotSpace.m,
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: text == null
                          ? DotIcon(glyph!, color: t.colors.ink)
                          : Text(
                              text,
                              style: t.styles.button.copyWith(
                                color: t.colors.accentText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One colour as a radio (E-Phones palette, E-Phones-3 swatches): a
/// [size] circle in a 48 target (44 on the board; Android's 48 holds on
/// every touch platform); when [selected] a gap, a ring in the
/// colour and a tick, so the choice is never colour alone. A custom
/// colour under 3:1 on its surface gets a neutral outline (CR-155).
class LookSwatch extends StatelessWidget {
  const LookSwatch({
    required this.colour,
    required this.selected,
    required this.onTap,
    this.size = DotLook.paletteDot,
    this.target = DotTouch.android,
    this.label,
    this.autofocus = false,
    super.key,
  });

  final TaskColor colour;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  /// The tap target: 48 on touch, the popover's 44 for a pointer.
  final double target;

  /// Takes the keys when its popover opens (the picked colour, ED-156).
  final bool autofocus;

  /// Overrides the colour's spoken name (Your colours' "Remove …").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final s = t.tasks[colour];
    final faint =
        colour.isCustom &&
        contrastRatio(s.color, t.colors.card) < DotLook.outlineBelow;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: label ?? taskColorName(context.l10n, colour),
      excludeSemantics: true,
      onTap: onTap,
      // Focusable, so a keyboard moves through the colours and ↵ picks.
      child: InkResponse(
        onTap: onTap,
        autofocus: autofocus,
        radius: target / 2,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: size < target ? target : size,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.color,
                border: faint
                    ? Border.all(
                        color: t.colors.hairlineStrong,
                        width: DotLook.outline,
                      )
                    : null,
                boxShadow: selected ? lookRing(t, s.color) : null,
              ),
              child: selected
                  ? DotIcon(DotGlyphs.check, color: s.check, active: true)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// A section label in the Mac and web popover ("Dottoday colours",
/// "Your colours", "Icon"; E-G3-9b): sentence case, semibold.
TextStyle lookPopoverLabel(DotTheme t) => t.styles.inspectorLabel.copyWith(
  color: t.colors.ink,
  fontWeight: FontWeight.w600,
);

/// The selected ring: a gap in the card, then [colour] (E-Phones).
/// The outer ring paints first, so the gap stays on top of it.
List<BoxShadow> lookRing(DotTheme t, Color colour) => [
  BoxShadow(color: colour, spreadRadius: DotLook.ringGap + DotLook.ringWidth),
  BoxShadow(color: t.colors.card, spreadRadius: DotLook.ringGap),
];

/// One icon as a circle (E-Phones): the task's colour with its ring when
/// [selected], a card with a hairline otherwise.
class LookIconCircle extends StatelessWidget {
  const LookIconCircle({
    required this.icon,
    required this.colour,
    required this.selected,
    required this.onTap,
    this.size = DotLook.icon,
    super.key,
  });

  final TaskIcon icon;
  final TaskColor colour;
  final bool selected;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final s = t.tasks[colour];
    final glyph = icon.glyph;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: taskIconName(context.l10n, icon),
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: size / 2,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? s.color : t.colors.card,
            border: selected
                ? null
                : Border.all(
                    color: t.colors.hairline,
                    width: DotSpace.hairline,
                  ),
            boxShadow: selected ? lookRing(t, s.color) : null,
          ),
          child: glyph == null
              ? null
              : DotIcon(
                  glyph,
                  color: selected ? s.check : t.colors.ink,
                  size: DotLook.glyph,
                  active: selected,
                ),
        ),
      ),
    );
  }
}
