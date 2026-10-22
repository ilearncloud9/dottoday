/// Whether the OS lets Dottoday post notifications (docs/03 §3.8).
enum PermissionState { granted, denied, notAsked }

/// The OS notification permission (docs/09 M3f.8); the platform
/// implementations land with the scheduler in M5.1 / M5.3.
abstract interface class NotificationPermission {
  Future<PermissionState> status();

  /// Asks the OS (once; afterwards only Settings can change it).
  Future<PermissionState> request();

  /// Opens the system settings for Dottoday; false where that can't be
  /// done, so the UI says where to go instead.
  Future<bool> openSettings();
}
