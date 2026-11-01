import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's own haptic taps, weakest first (docs/12 §2.6).
enum HapticTick {
  /// A hover or lift: the drag picks a task up, a target lights up.
  selection,

  /// A small confirmation: a task ticked done, an action applied.
  light,

  /// A landing: a drop on the thread, a day, the Inbox tab or the Trash.
  medium,
}

/// Whether the app's haptics play (Settings › Sounds › Haptics in app,
/// docs/12 §2.6). The root fills it from `Settings.inAppHapticsEnabled`
/// so a plain widget can ask through [AppHaptics] without a `ref`.
class HapticsScope extends InheritedWidget {
  const HapticsScope({required this.enabled, required super.child, super.key});

  final bool enabled;

  @override
  bool updateShouldNotify(HapticsScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// Every in-app haptic goes through here, so the one switch covers them
/// all. The OS's own vibration (a notification, the keyboard) is not ours
/// and is not affected.
abstract final class AppHaptics {
  /// Whether haptics are on for [context]; on outside a [HapticsScope].
  /// Read in callbacks without depending on the scope.
  static bool enabledOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<HapticsScope>()?.enabled ?? true;

  /// Plays [tick] unless the switch is off.
  static void play(BuildContext context, HapticTick tick) {
    if (enabledOf(context)) fire(tick);
  }

  /// [play] for code that has a `ref` but no live context (after a write):
  /// the same switch, read from the profile.
  static void playFor(WidgetRef ref, HapticTick tick) {
    final settings = ref.read(currentProfileProvider).value?.settings;
    if (settings?.inAppHapticsEnabled ?? true) fire(tick);
  }

  /// The app's own haptics bridge (iOS Core Haptics, Android Vibrator),
  /// not Flutter's HapticFeedback: that one goes through the system's
  /// touch feedback, which System Haptics (iOS) and Touch feedback
  /// (Android) switch off, so the in-app switch alone decides.
  @visibleForTesting
  static const channel = MethodChannel('dottoday/haptics');

  /// Plays [tick] with no check: only for a caller that already asked
  /// [enabledOf] (a gesture recognizer has no context of its own).
  static void fire(HapticTick tick) {
    // A Mac and the web have no bridge (no haptics); the missing plugin
    // there is expected, so the call's outcome is not waited on.
    channel.invokeMethod<bool>('play', tick.name).ignore();
  }
}
