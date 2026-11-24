import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/theme/tokens.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// THEME (E-G3-9b, ED-161): Auto · Light · Dark as thumbnails of the app's
/// own grounds, the chosen one outlined in the accent with its label in a
/// pill. Applies at once (03 §3.7).
class ThemeGroup extends StatelessWidget {
  const ThemeGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String label(ThemePreference p) => switch (p) {
      ThemePreference.system => l10n.settingsThemeAuto,
      ThemePreference.light => l10n.settingsThemeLight,
      ThemePreference.dark => l10n.settingsThemeDark,
    };
    // On a Mac/web form: "Theme:" and the three thumbnails (ED-452).
    if (settingsFormAt(context)) {
      return SettingsGroup(
        caption: l10n.settingsTheme,
        formBreak: false,
        children: [
          FormLine(
            label: l10n.settingsTheme,
            child: Wrap(
              spacing: DotSpace.l,
              runSpacing: DotSpace.s,
              children: [
                for (final p in ThemePreference.values)
                  _Thumb(
                    preference: p,
                    label: label(p),
                    selected: p == settings.theme,
                  ),
              ],
            ),
          ),
        ],
      );
    }
    return SettingsGroup(
      caption: l10n.settingsTheme,
      children: [
        Padding(
          padding: const EdgeInsets.all(DotSpace.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // An equal share each, so long names wrap under their
              // thumbnail instead of pushing past the card.
              for (final p in ThemePreference.values)
                Expanded(
                  child: _Thumb(
                    preference: p,
                    label: switch (p) {
                      ThemePreference.system => l10n.settingsThemeAuto,
                      ThemePreference.light => l10n.settingsThemeLight,
                      ThemePreference.dark => l10n.settingsThemeDark,
                    },
                    selected: p == settings.theme,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.preference,
    required this.label,
    required this.selected,
  });

  final ThemePreference preference;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final edge = selected ? t.colors.accentInk : t.colors.outline;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(DotRadii.card),
        onTap: () =>
            changeSettings(context, (s) => s.copyWith(theme: preference)),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.s,
            children: [
              Container(
                width: DotSize.themeThumbWidth,
                height: DotSize.themeThumbHeight,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DotRadii.choice),
                  border: Border.all(
                    color: edge,
                    width: selected
                        ? DotSize.smallDotOutline
                        : DotSpace.hairline,
                  ),
                ),
                child: CustomPaint(painter: _Ground(preference)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DotRadii.card),
                  border: selected ? Border.all(color: edge) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DotSpace.s,
                    vertical: DotSpace.xxs,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: t.styles.rowMeta.copyWith(
                      color: selected ? t.colors.accentInk : t.colors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The light card, the dark card, or Auto's diagonal half of each.
class _Ground extends CustomPainter {
  const _Ground(this.preference);

  final ThemePreference preference;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = DotPalette.light.card;
    final dark = Paint()..color = DotPalette.dark.ground;
    final all = Offset.zero & size;
    switch (preference) {
      case ThemePreference.light:
        canvas.drawRect(all, light);
      case ThemePreference.dark:
        canvas.drawRect(all, dark);
      case ThemePreference.system:
        canvas
          ..drawRect(all, light)
          ..drawPath(
            Path()
              ..moveTo(size.width, 0)
              ..lineTo(size.width, size.height)
              ..lineTo(0, size.height)
              ..close(),
            dark,
          );
    }
  }

  @override
  bool shouldRepaint(_Ground old) => old.preference != preference;
}
