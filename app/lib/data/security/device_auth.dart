import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// The device's own check — face, fingerprint or the device passcode
/// (docs/06 §2, M5.8). A port so the lock is tested without a device.
abstract interface class DeviceAuth {
  /// Whether this device can ask at all (a passcode, at least).
  Future<bool> available();

  /// Asks; true when the person passed. [reason] is shown by the OS.
  Future<bool> authenticate(String reason);

  /// Whether the OS prompt is up. It can pause the app (Android's PIN
  /// screen), which must not count as leaving it.
  bool get asking;
}

/// [DeviceAuth] on `local_auth`: biometrics or the device passcode.
final class LocalDeviceAuth implements DeviceAuth {
  LocalDeviceAuth([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  var asking = false;

  @override
  Future<bool> available() => _auth.isDeviceSupported();

  @override
  Future<bool> authenticate(String reason) async {
    asking = true;
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on Object catch (e) {
      if (e is! LocalAuthException && e is! PlatformException) rethrow;
      // Cancelled, locked out or not set up: still locked; the lock screen
      // offers to try again.
      return false;
    } finally {
      asking = false;
    }
  }
}
