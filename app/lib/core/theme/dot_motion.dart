import 'package:flutter/animation.dart';

/// Motion tokens of Concept A (docs/10-ui-concept-a.md §2.4): 180–240 ms,
/// standard ease-out.
///
/// Read via `DotTheme.of(context).motion`, which already accounts for the OS
/// reduced-motion flag; widgets never check the flag themselves.
final class DotMotion {
  const DotMotion({
    required this.fast,
    required this.base,
    required this.slow,
    required this.curve,
  });

  static const standard = DotMotion(
    fast: Duration(milliseconds: 180),
    base: Duration(milliseconds: 200),
    slow: Duration(milliseconds: 240),
    curve: Curves.easeOut,
  );

  /// All durations zero: animations jump straight to their end state.
  static const reduced = DotMotion(
    fast: Duration.zero,
    base: Duration.zero,
    slow: Duration.zero,
    curve: Curves.linear,
  );

  /// Returns [reduced] when the OS asks for reduced motion, else [standard].
  static DotMotion resolve({required bool reduceMotion}) =>
      reduceMotion ? reduced : standard;

  /// Whether every duration is zero (reduced motion is on).
  bool get isReduced => base == Duration.zero;

  final Duration fast;
  final Duration base;
  final Duration slow;
  final Curve curve;
}
