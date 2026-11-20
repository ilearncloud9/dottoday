import 'package:flutter/services.dart';

/// The system alert over `dottoday/alert` (owner, native pass): iOS's
/// UIAlertController (ios/Runner `AlertBridge.swift`) and the Mac's NSAlert
/// (macos/Runner `AlertBridge.swift`). Null when no bridge answers (a
/// test, another platform), so the caller draws its own.
/// How a system alert draws a button.
enum NativeAlertStyle { plain, cancel, destructive }

/// One button of [NativeAlert.choose].
final class NativeAlertButton {
  const NativeAlertButton(this.label, this.style);

  final String label;
  final NativeAlertStyle style;

  Map<String, Object?> toWire() => {
    'label': label,
    'style': switch (style) {
      NativeAlertStyle.plain => 'default',
      NativeAlertStyle.cancel => 'cancel',
      NativeAlertStyle.destructive => 'destructive',
    },
  };
}

abstract final class NativeAlert {
  static const _channel = MethodChannel('dottoday/alert');

  /// The chosen button's index, -1 when dismissed, null without a bridge.
  /// [preferred] is the one Return picks.
  static Future<int?> choose({
    required String? title,
    required String? message,
    required List<NativeAlertButton> buttons,
    required int? preferred,
    required String tint,
  }) => _ask<int>('choose', {
    'title': title,
    'message': message,
    'tint': tint,
    'buttons': [for (final b in buttons) b.toWire()],
    'preferred': preferred,
  });

  /// `{ok, text}` from an alert with one text field, or null without a
  /// bridge. [tint] (`#RRGGBB`) colours the buttons on iOS: Dottoday's ink,
  /// never red (ED-336).
  static Future<({bool ok, String text})?> text({
    required String title,
    required String initial,
    required String action,
    required String cancel,
    required String tint,
  }) async {
    final answer = await _ask<Map<Object?, Object?>>('text', {
      'title': title,
      'tint': tint,
      'initial': initial,
      'action': action,
      'cancel': cancel,
    });
    if (answer == null) return null;
    return (ok: answer['ok'] == true, text: answer['text'] as String? ?? '');
  }

  static Future<T?> _ask<T>(String method, Map<String, Object?> args) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
