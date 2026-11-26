import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/flow/onb_buttons.dart';
import 'package:flutter/material.dart';

/// A chip to show: its key, words, colour, icon, and whether picked.
typedef FillChip = ({
  String id,
  String title,
  Color color,
  DotGlyph? glyph,
  bool picked,
});

/// The chips (`.rchips`): centred, wrapping, 8 apart. Each is a filter
/// chip read as "Gym, not selected"; unpicked ones are off once five are
/// picked. [dotKeys] mark each chip's dot, where its flight starts.
class FillsChips extends StatelessWidget {
  const FillsChips({
    required this.chips,
    required this.full,
    required this.dotKeys,
    required this.onTap,
    super.key,
  });

  final List<FillChip> chips;
  final bool full;
  final Map<String, GlobalKey> dotKeys;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: context.l10n.onboardingFillsGroup,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: OnbSize.chipGap,
        runSpacing: OnbSize.chipGap,
        children: [
          for (final c in chips)
            _Chip(
              chip: c,
              dotKey: dotKeys[c.id],
              enabled: c.picked || !full,
              onTap: () => onTap(c.id),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.chip,
    required this.dotKey,
    required this.enabled,
    required this.onTap,
  });

  final FillChip chip;
  final GlobalKey? dotKey;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final cc = chip.color;
    final on = chip.picked;
    final line = OnbSky.of(c.isDark ? Brightness.dark : Brightness.light).line;
    return Opacity(
      opacity: enabled ? 1 : OnbSize.chipOff,
      child: OnbPress(
        enabled: enabled,
        scale: OnbSize.chipPressScale,
        duration: OnbMotion.chipPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OnbSize.chip / 2),
            boxShadow: [
              BoxShadow(
                color: OnbSky.black.withValues(alpha: OnbSize.chipShadowAlpha),
                offset: const Offset(0, OnbSize.chipShadowY),
                blurRadius: OnbSize.chipShadowBlur,
                spreadRadius: OnbSize.chipShadowSpread,
              ),
            ],
          ),
          // No ink: the chip only presses in (`.rchip:active`).
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: c.raised.withValues(alpha: 0),
              hoverColor: c.raised.withValues(alpha: 0),
            ),
            child: FilterChip(
              selected: on,
              showCheckmark: false,
              onSelected: enabled ? (_) => onTap() : null,
              // 46 drawn, 48 to tap (Android's target); the rows sit 2 further
              // apart than the prototype's 8.
              materialTapTargetSize: MaterialTapTargetSize.padded,
              visualDensity: VisualDensity.standard,
              // The card colour picked or not (`.rchip` background); the
              // app's chip theme would tint it.
              color: WidgetStatePropertyAll(c.raised),
              side: BorderSide(
                color: on ? cc : line,
                width: on ? OnbSize.chipPickedRing : 1,
              ),
              shape: const StadiumBorder(),
              padding: const EdgeInsetsDirectional.fromSTEB(
                OnbSize.chipStart,
                (OnbSize.chip - OnbSize.chipDot) / 2,
                OnbSize.chipEnd,
                (OnbSize.chip - OnbSize.chipDot) / 2,
              ),
              labelPadding: const EdgeInsetsDirectional.only(
                start: OnbSize.chipGap,
                top: OnbSize.chipWordsPad,
                bottom: OnbSize.chipWordsPad,
              ),
              avatarBoxConstraints: const BoxConstraints.tightFor(
                width: OnbSize.chipDot,
                height: OnbSize.chipDot,
              ),
              avatar: FillsChipDot(
                key: dotKey,
                color: cc,
                glyph: on ? DotGlyphs.check : chip.glyph,
                filled: on,
              ),
              label: Text(chip.title, style: t.styles.onbChip),
            ),
          ),
        ),
      ),
    );
  }
}

/// A chip's dot (`.rchip .rd`): 34, a 3 ring in its colour, the icon in
/// it; picked, filled with ✓ in the card colour.
class FillsChipDot extends StatelessWidget {
  const FillsChipDot({
    required this.color,
    required this.glyph,
    this.filled = false,
    super.key,
  });

  final Color color;
  final DotGlyph? glyph;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final glyph = this.glyph ?? DotGlyphs.onbDot;
    return AnimatedContainer(
      duration: OnbMotion.chipFill,
      width: OnbSize.chipDot,
      height: OnbSize.chipDot,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : c.raised,
        border: Border.all(color: color, width: OnbSize.chipRing),
      ),
      child: Center(
        child: DotIcon(
          glyph,
          color: filled ? c.raised : color,
          size: OnbSize.chipIcon,
          bold: true,
        ),
      ),
    );
  }
}
