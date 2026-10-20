import 'package:flutter/animation.dart';

/// Motion tokens from docs/03-ux-spec.md §1.
///
/// Read via `AppTheme.of(context).motion`, which already accounts for the OS
/// reduced-motion flag — widgets never check the flag themselves.
final class AppMotion {
  const AppMotion({
    required this.fast,
    required this.base,
    required this.slow,
    required this.curve,
  });

  static const standard = AppMotion(
    fast: Duration(milliseconds: 120),
    base: Duration(milliseconds: 200),
    slow: Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );

  /// All durations zero: animations jump straight to their end state.
  static const reduced = AppMotion(
    fast: Duration.zero,
    base: Duration.zero,
    slow: Duration.zero,
    curve: Curves.linear,
  );

  /// Returns [reduced] when the OS asks for reduced motion, else [standard].
  static AppMotion resolve({required bool reduceMotion}) =>
      reduceMotion ? reduced : standard;

  final Duration fast;
  final Duration base;
  final Duration slow;
  final Curve curve;
}
