import 'package:flutter/services.dart';

/// The iPad's ⌘-hold menu bar and Android's Keyboard Shortcuts Helper
/// (R2-10, ED-095) over `dottoday/key_menus`: ios/Runner
/// `KeyMenusBridge.swift` builds UIKit menus with key commands from the
/// list; android `KeyMenus.kt` lists the commands that have keys. A
/// command chosen there comes back as `select` with its id.
abstract final class NativeKeyMenusChannel {
  static const _channel = MethodChannel('dottoday/key_menus');

  /// Sends [menus] (see `NativeKeyMenus` for the shape); [onSelect] runs
  /// for the id the system sends back. Missing native side: nothing.
  static Future<void> set(
    List<Map<String, Object?>> menus,
    void Function(String id) onSelect,
  ) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'select') onSelect(call.arguments as String);
    });
    try {
      await _channel.invokeMethod<void>('set', menus);
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
