import 'package:dottoday/core/theme/app_colors.dart';
import 'package:dottoday/core/theme/app_motion.dart';
import 'package:dottoday/core/theme/app_typography.dart';
import 'package:dottoday/core/theme/block_palette.dart';
import 'package:flutter/material.dart';

export 'app_colors.dart';
export 'app_motion.dart';
export 'app_spacing.dart';
export 'app_typography.dart';
export 'block_icons.dart';
export 'block_palette.dart';

/// Dottoday design tokens as a [ThemeExtension] (docs/03-ux-spec.md §1).
///
/// ```dart
/// final t = AppTheme.of(context);
/// Container(color: t.colors.surfaceRaised);
/// AnimatedOpacity(duration: t.motion.base, ...);
/// ```
@immutable
final class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({
    required this.colors,
    required this.typography,
    required this.blocks,
    this.motion = AppMotion.standard,
  });

  final AppColors colors;
  final AppTypography typography;

  /// User-selectable block colours for this brightness.
  final BlockPalette blocks;
  final AppMotion motion;

  /// Tokens for [context], with [motion] zeroed when the OS reduced-motion
  /// flag is on.
  static AppTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>();
    assert(theme != null, 'AppTheme missing: use AppTheme.light()/dark().');
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return theme!.copyWith(motion: AppMotion.resolve(reduceMotion: reduce));
  }

  static ThemeData light() =>
      _build(Brightness.light, AppColors.light, BlockPalette.light);

  static ThemeData dark() =>
      _build(Brightness.dark, AppColors.dark, BlockPalette.dark);

  @override
  AppTheme copyWith({
    AppColors? colors,
    AppTypography? typography,
    BlockPalette? blocks,
    AppMotion? motion,
  }) {
    return AppTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      blocks: blocks ?? this.blocks,
      motion: motion ?? this.motion,
    );
  }

  @override
  AppTheme lerp(AppTheme? other, double t) {
    if (other == null) return this;
    return AppTheme(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      blocks: blocks.lerp(other.blocks, t),
      motion: t < 0.5 ? motion : other.motion,
    );
  }
}

ThemeData _build(Brightness brightness, AppColors c, BlockPalette blocks) {
  // Snackbars and tooltips sit on the inverse surface: the other mode's
  // raised surface, text and accent, so their contrast is already tested.
  final inverse = brightness == Brightness.light
      ? AppColors.dark
      : AppColors.light;
  final type = AppTypography.withColor(c.onSurface);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.accent,
    onPrimary: c.onAccent,
    secondary: c.accent,
    onSecondary: c.onAccent,
    error: c.danger,
    onError: c.onAccent,
    surface: c.surface,
    onSurface: c.onSurface,
    onSurfaceVariant: c.onSurfaceMuted,
    surfaceContainerLowest: c.surfaceSunken,
    surfaceContainer: c.surfaceRaised,
    outline: c.outline,
    outlineVariant: c.outline,
    inverseSurface: inverse.surfaceRaised,
    onInverseSurface: inverse.onSurface,
    inversePrimary: inverse.accent,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.surface,
    fontFamily: AppTypography.fontFamily,
    textTheme: _textTheme(type),
    extensions: [AppTheme(colors: c, typography: type, blocks: blocks)],
  );
}

TextTheme _textTheme(AppTypography t) => TextTheme(
  displaySmall: t.display,
  titleLarge: t.title,
  bodyLarge: t.body,
  bodyMedium: t.body,
  labelLarge: t.label,
  labelMedium: t.label,
);
