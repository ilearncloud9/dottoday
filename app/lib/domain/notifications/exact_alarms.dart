/// Whether reminders may fire at the exact minute (docs/07 Android,
/// docs/09 M5.6). Android 12+ gates exact alarms behind "Alarms &
/// reminders"; without it reminders still arrive, possibly a few minutes
/// late (inexact), and Settings says why. Elsewhere it is always allowed.
abstract interface class ExactAlarms {
  /// True when exact timing is allowed (or not gated on this platform).
  Future<bool> allowed();

  /// Opens the system screen where the user can allow it.
  Future<void> request();
}
