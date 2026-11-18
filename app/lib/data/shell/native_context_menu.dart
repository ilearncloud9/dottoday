import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show SingleActivator;

/// One item of the Mac's system menu, as `ContextMenuBridge.swift` reads it.
final class NativeMenuItem {
  const NativeMenuItem({
    required this.label,
    this.symbol,
    this.enabled = true,
    this.shortcut,
  });

  final String label;

  /// An SF Symbol name (ED-260).
  final String? symbol;
  final bool enabled;

  /// The key hint beside the label; NSMenu draws it (⌘⌫ and so on).
  final SingleActivator? shortcut;

  Map<String, Object?> toWire() {
    final key = shortcut;
    return {
      'label': label,
      'symbol': symbol,
      'enabled': enabled,
      if (key != null) ...{
        'key': _keyName(key.trigger),
        'command': key.meta,
        'shift': key.shift,
        'option': key.alt,
        'control': key.control,
      },
    };
  }

  /// The key equivalents the Mac menu shows; other keys show no hint.
  static String? _keyName(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.backspace) return 'backspace';
    if (key == LogicalKeyboardKey.enter) return 'enter';
    final label = key.keyLabel;
    return label.length == 1 ? label.toLowerCase() : null;
  }
}

/// The outcome of asking the Mac for its menu.
sealed class NativeMenuResult {
  const NativeMenuResult();
}

/// The system menu was shown; [index] is the chosen item, or null.
final class NativeMenuShown extends NativeMenuResult {
  const NativeMenuShown(this.index);
  final int? index;
}

/// No native menu here (tests, a build without the bridge).
final class NativeMenuMissing extends NativeMenuResult {
  const NativeMenuMissing();
}

/// The Mac's NSMenu over `dottoday/context_menu` (macos/Runner
/// `ContextMenuBridge.swift`, ED-239, CR-098).
abstract final class NativeContextMenu {
  static const _channel = MethodChannel('dottoday/context_menu');

  /// Pops the system menu at [at] (Flutter's logical coordinates, from
  /// the window's top-left) and waits for the choice.
  static Future<NativeMenuResult> show(
    Offset at,
    List<NativeMenuItem> items,
  ) async {
    try {
      final index = await _channel.invokeMethod<int>('show', {
        'x': at.dx,
        'y': at.dy,
        'items': [for (final i in items) i.toWire()],
      });
      return NativeMenuShown(index);
    } on MissingPluginException {
      return const NativeMenuMissing();
    } on PlatformException {
      return const NativeMenuMissing();
    }
  }
}
