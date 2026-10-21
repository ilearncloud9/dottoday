import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:dottoday/core/theme/dot_motion.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:flutter/material.dart';

export 'contrast.dart';
export 'dot_colors.dart';
export 'dot_glyphs.dart';
export 'dot_icon.dart';
export 'dot_metrics.dart';
export 'dot_motion.dart';
export 'dot_type.dart';
export 'task_icons.dart';
export 'task_palette.dart';

/// Concept A design tokens as a [ThemeExtension] (docs/10-ui-concept-a.md
/// §2, ADR-0007). The only theme: it lives in `app/lib/core/theme/`.
///
/// ```dart
/// final t = DotTheme.of(context);
/// Container(color: t.colors.raised);
/// Text(title, style: t.styles.rowTitle);
/// AnimatedOpacity(duration: t.motion.base, ...);
/// ```
@immutable
final class DotTheme extends ThemeExtension<DotTheme> {
  const DotTheme({
    required this.colors,
    required this.styles,
    required this.tasks,
    this.motion = DotMotion.standard,
  });

  final DotColors colors;
  final DotType styles;

  /// The 9 task colours resolved for this brightness.
  final TaskPalette tasks;
  final DotMotion motion;

  /// Tokens for [context], with [motion] zeroed when the OS reduced-motion
  /// flag is on.
  static DotTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<DotTheme>();
    assert(theme != null, 'DotTheme missing: use DotTheme.light()/dark().');
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return theme!.copyWith(motion: DotMotion.resolve(reduceMotion: reduce));
  }

  /// Light [ThemeData] with [accent] (Settings › Look).
  static ThemeData light([DotAccent accent = DotAccent.fallback]) =>
      _build(DotColors.light(accent));

  /// Dark [ThemeData] with [accent] (Settings › Look).
  static ThemeData dark([DotAccent accent = DotAccent.fallback]) =>
      _build(DotColors.dark(accent));

  @override
  DotTheme copyWith({
    DotColors? colors,
    DotType? styles,
    TaskPalette? tasks,
    DotMotion? motion,
  }) {
    return DotTheme(
      colors: colors ?? this.colors,
      styles: styles ?? this.styles,
      tasks: tasks ?? this.tasks,
      motion: motion ?? this.motion,
    );
  }

  @override
  DotTheme lerp(DotTheme? other, double t) {
    if (other == null) return this;
    return DotTheme(
      colors: colors.lerp(other.colors, t),
      styles: styles.lerp(other.styles, t),
      tasks: tasks.lerp(other.tasks, t),
      motion: t < 0.5 ? motion : other.motion,
    );
  }
}

ThemeData _build(DotColors c) {
  // Snackbars and tooltips sit on the inverse surface: the other mode's
  // raised surface and text, so their contrast is already tested.
  final inverse = c.isDark ? DotColors.light() : DotColors.dark();
  final type = DotType.withColors(text: c.text, muted: c.muted);
  final scheme = ColorScheme(
    brightness: c.brightness,
    primary: c.accent,
    onPrimary: c.onAccent,
    primaryContainer: Color.alphaBlend(c.accentTint, c.raised),
    onPrimaryContainer: c.accentInk,
    secondary: c.accent,
    onSecondary: c.onAccent,
    // Concept A has no error hue (§2.1); errors are inline text (§5.4).
    error: c.text,
    onError: c.raised,
    surface: c.surface,
    onSurface: c.text,
    onSurfaceVariant: c.muted,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.raised,
    surfaceContainer: c.raised,
    surfaceContainerHigh: c.raised,
    surfaceContainerHighest: c.raised,
    outline: c.outline,
    outlineVariant: c.outline,
    inverseSurface: inverse.raised,
    onInverseSurface: inverse.text,
    inversePrimary: inverse.accentInk,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.surface,
    fontFamily: DotType.fontFamily,
    textTheme: _textTheme(type),
    dividerColor: c.outline,
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DotRadii.sheet),
        ),
      ),
    ),
    extensions: [
      DotTheme(colors: c, styles: type, tasks: TaskPalette.resolve(c)),
    ],
  );
}

TextTheme _textTheme(DotType t) => TextTheme(
  displaySmall: t.pageTitle,
  headlineSmall: t.topBarTitle,
  titleLarge: t.cardTitle,
  titleMedium: t.rowTitle,
  bodyLarge: t.body,
  bodyMedium: t.body,
  bodySmall: t.rowMeta,
  labelLarge: t.button,
  labelMedium: t.rowMeta,
  labelSmall: t.tabLabel,
);
