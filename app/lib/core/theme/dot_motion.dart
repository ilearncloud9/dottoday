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
    required this.spring,
    this.reveal = Duration.zero,
    this.pulse = Duration.zero,
  });

  static const standard = DotMotion(
    fast: Duration(milliseconds: 180),
    base: Duration(milliseconds: 200),
    slow: Duration(milliseconds: 240),
    curve: Curves.easeOut,
    spring: Curves.easeOutBack,
    reveal: Duration(seconds: 2),
    pulse: Duration(milliseconds: 1200),
  );

  /// All durations zero: animations jump straight to their end state.
  static const reduced = DotMotion(
    fast: Duration.zero,
    base: Duration.zero,
    slow: Duration.zero,
    curve: Curves.linear,
    spring: Curves.linear,
  );

  /// Returns [reduced] when the OS asks for reduced motion, else [standard].
  static DotMotion resolve({required bool reduceMotion}) =>
      reduceMotion ? reduced : standard;

  /// Whether every duration is zero (reduced motion is on).
  bool get isReduced => base == Duration.zero;

  final Duration fast;
  final Duration base;
  final Duration slow;

  /// How long a one-time reveal accent holds before it fades over [slow]
  /// (docs/13 §4.3); zero under reduced motion, where nothing is drawn.
  final Duration reveal;

  /// One breath of the listening dot (`MicButton`, M14.5); zero under
  /// reduced motion, where the dot holds still.
  final Duration pulse;
  final Curve curve;

  /// The month pull-open's rubber band (§2.4): a slight overshoot.
  final Curve spring;
}
