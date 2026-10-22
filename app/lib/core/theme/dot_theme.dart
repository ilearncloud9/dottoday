import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:dottoday/core/theme/dot_motion.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'contrast.dart';
export 'dot_colors.dart';
export 'dot_glyphs.dart';
export 'dot_icon.dart';
export 'dot_idiom.dart';
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
  ///
  /// One instance per accent and platform: `MaterialApp` animates between unequal
  /// themes, so a fresh copy on every rebuild would re-run that animation.
  static ThemeData light([DotAccent accent = DotAccent.fallback]) =>
      _cache[(accent, Brightness.light, defaultTargetPlatform)] ??= _build(
        DotColors.light(accent),
      );

  /// Dark [ThemeData] with [accent] (Settings › Look); cached like [light].
  static ThemeData dark([DotAccent accent = DotAccent.fallback]) =>
      _cache[(accent, Brightness.dark, defaultTargetPlatform)] ??= _build(
        DotColors.dark(accent),
      );

  /// Keyed by platform too: ThemeData captures the target platform (and with
  /// it the §4 chrome idiom) when it is built.
  static final _cache = <(DotAccent, Brightness, TargetPlatform), ThemeData>{};

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
  final scheme = _scheme(c, inverse);
  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.surface,
    fontFamily: DotType.fontFamily,
    textTheme: _textTheme(type),
    dividerColor: c.outline,
    // Pill buttons on every platform (`Main`, `A-android-today`).
    filledButtonTheme: FilledButtonThemeData(
      style: _pill(type, c, filled: true),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _pill(type, c)),
    // Sheets and dialogs take the raised surface from the theme, not from
    // the caller, so an open sheet follows a light/dark switch (M3c.6).
    bottomSheetTheme: BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: c.raised,
      modalBackgroundColor: c.raised,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DotRadii.sheet),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.raised,
      surfaceTintColor: Colors.transparent,
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

ButtonStyle _pill(DotType type, DotColors c, {bool filled = false}) =>
    ButtonStyle(
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      minimumSize: const WidgetStatePropertyAll(
        Size(DotTouch.android, DotTouch.android),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: DotSpace.l),
      ),
      textStyle: WidgetStatePropertyAll(type.button),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? c.muted
            : filled
            ? c.onAccent
            : c.text,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? c.outline
            : filled
            ? c.accentFill
            : c.raised,
      ),
      side: filled
          ? null
          : WidgetStatePropertyAll(
              BorderSide(color: c.outline, width: DotSpace.hairline),
            ),
    );

ColorScheme _scheme(DotColors c, DotColors inverse) => ColorScheme(
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
