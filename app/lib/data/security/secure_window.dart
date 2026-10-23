import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_window.g.dart';

/// Android's FLAG_SECURE while the app lock is on (docs/06 §2, M5.8): no
/// screenshots, and a blank card in Recents. MainActivity.kt sets the flag.
/// Elsewhere the lock screen's own cover hides the app switcher snapshot.
class SecureWindow {
  const SecureWindow([this._channel = const MethodChannel('dottoday/secure')]);

  final MethodChannel _channel;

  Future<void> set({required bool secure}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('set', secure);
  }
}

@Riverpod(keepAlive: true)
SecureWindow secureWindow(Ref ref) => const SecureWindow();
