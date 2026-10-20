import 'package:flutter/painting.dart';

/// Semantic colour roles from docs/03-ux-spec.md §1.
///
/// The only file allowed to contain raw hex values; everything else reads
/// roles through `AppTheme.of(context).colors`.
final class AppColors {
  const AppColors({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const light = AppColors(
    surface: Color(0xFFFAFAF8),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF1F1EE),
    onSurface: Color(0xFF1A1A1C),
    onSurfaceMuted: Color(0xFF6B6B70),
    outline: Color(0xFFE2E2DE),
    accent: Color(0xFF3B6CF6),
    onAccent: Color(0xFFFFFFFF),
    success: Color(0xFF1F9D55),
    warning: Color(0xFFD98A00),
    danger: Color(0xFFD33F49),
  );

  static const dark = AppColors(
    surface: Color(0xFF121214),
    surfaceRaised: Color(0xFF1C1C20),
    surfaceSunken: Color(0xFF0C0C0E),
    onSurface: Color(0xFFF2F2F0),
    onSurfaceMuted: Color(0xFF9A9AA0),
    outline: Color(0xFF2C2C32),
    accent: Color(0xFF7FA0FF),
    onAccent: Color(0xFF0B1020),
    success: Color(0xFF4CCB86),
    warning: Color(0xFFFFB547),
    danger: Color(0xFFFF6B73),
  );

  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color outline;
  final Color accent;
  final Color onAccent;
  final Color success;

  /// Overdue state. Deliberately amber, never red — overdue is normal.
  final Color warning;

  /// Destructive actions only.
  final Color danger;

  /// Interpolates every role; used by theme animations.
  AppColors lerp(AppColors other, double t) {
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      onSurface: l(onSurface, other.onSurface),
      onSurfaceMuted: l(onSurfaceMuted, other.onSurfaceMuted),
      outline: l(outline, other.outline),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
    );
  }
}
