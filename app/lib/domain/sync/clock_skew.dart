import 'package:dottoday/domain/sync/hlc.dart';

/// How far this device's clock is from the server's (docs/09 M6.5.7,
/// 11 A0). Only offsets beyond [HybridLogicalClock.maxDrift] matter: a fast clock makes
/// the server refuse pushes (ADR-0002) and reminders fire early; a slow one
/// makes them late. Within the bound there is nothing to say.
///
/// ```dart
/// ClockSkew.of(const Duration(minutes: 7))?.fast; // true
/// ClockSkew.of(const Duration(minutes: 2)); // null: fine
/// ```
final class ClockSkew {
  const ClockSkew._(this.offset);

  /// Device time minus server time, when it is beyond [HybridLogicalClock.maxDrift]; null
  /// when the clock is close enough (or [offset] is unknown).
  static ClockSkew? of(Duration? offset) =>
      offset == null || offset.abs() <= HybridLogicalClock.maxDrift
      ? null
      : ClockSkew._(offset);

  /// Device minus server: positive = this clock is fast.
  final Duration offset;

  /// Pushes would be refused (more than 5 min in the future).
  bool get fast => offset > Duration.zero;

  /// Whole minutes off, for "Your clock is 7 min fast".
  int get minutes => (offset.abs().inSeconds / 60).round();

  @override
  bool operator ==(Object other) =>
      other is ClockSkew && other.offset == offset;

  @override
  int get hashCode => offset.hashCode;
}
