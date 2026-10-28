import 'package:dottoday/domain/thinking/thinking_backend.dart';

/// Whose on-device model this platform would use, so copy can name the
/// right setting (docs/09 M14.1): Apple Intelligence on iPhone and Mac,
/// Gemini Nano on Android, the browser's built-in model on the web.
enum ThinkingVendor {
  /// Apple Foundation Models on an iPhone or iPad ("iPhone Settings").
  appleIos,

  /// Apple Foundation Models on a Mac ("System Settings").
  appleMac,

  /// Gemini Nano through AICore.
  google,

  /// Chrome's built-in Prompt API.
  chrome,

  /// A platform with no on-device model path (Linux, Windows, tests).
  none,
}

/// What Settings › Privacy and the proposal sheets show about the model:
/// its [availability] on this device and the [vendor] behind it.
///
/// ```dart
/// const s = ThinkingStatus(
///   availability: ThinkingAvailability.notEnabled,
///   vendor: ThinkingVendor.appleIos,
/// );
/// s.path; // ThinkingPath.rules
/// s.offersNudge; // true: turning on Apple Intelligence would help
/// ```
final class ThinkingStatus {
  const ThinkingStatus({required this.availability, required this.vendor});

  final ThinkingAvailability availability;
  final ThinkingVendor vendor;

  /// The path a request takes now: the model only when it is ready.
  ThinkingPath get path => availability == ThinkingAvailability.available
      ? ThinkingPath.onDevice
      : ThinkingPath.rules;

  /// Whether a gentle "turn it on / it's getting ready" hint may show
  /// (D4): never where the device can't run the model.
  bool get offersNudge =>
      vendor != ThinkingVendor.none && availability.canBecomeAvailable;

  @override
  bool operator ==(Object other) =>
      other is ThinkingStatus &&
      other.availability == availability &&
      other.vendor == vendor;

  @override
  int get hashCode => Object.hash(availability, vendor);
}
