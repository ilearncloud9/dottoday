/// Whether the OS may delay or drop Dottoday's background work to save
/// battery (docs/09 M6.5.5, 11 A0). Only Android exposes it; the
/// notification health panel reads it on every launch and resume and offers
/// the system list to exempt Dottoday. Elsewhere it is never restricted.
abstract interface class BatteryOptimization {
  /// True when battery optimisation applies to Dottoday.
  Future<bool> restricted();

  /// Opens the system's battery-optimisation list.
  Future<void> openSettings();
}

/// Platforms without the setting (iOS, macOS, the web, tests).
final class NoBatteryOptimization implements BatteryOptimization {
  const NoBatteryOptimization();

  @override
  Future<bool> restricted() async => false;

  @override
  Future<void> openSettings() async {}
}
