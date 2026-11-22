import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show SingleActivator;

/// One item of the system menu, as `ContextMenuBridge.swift` (Mac, iOS)
/// reads it. [index] is what the menu answers when it is chosen; an item
/// with [children] opens them as a submenu instead.
final class NativeMenuItem {
  const NativeMenuItem({
    required this.label,
    this.index = -1,
    this.symbol,
    this.enabled = true,
    this.shortcut,
    this.checked = false,
    this.divided = false,
    this.header,
    this.children = const [],
  });

  /// The answer when chosen (its place among the menu's entries).
  final int index;

  /// A titled group starts here (the Day menu's Time · Plan · Day ·
  /// Layout, ED-093): NSMenu's section header, an inline UIMenu's title.
  final String? header;

  /// A submenu (Need more time ▸ +5 / +15 / +30).
  final List<NativeMenuItem> children;

  /// A separator before this item (a new group).
  final bool divided;

  final String label;

  /// Ticked: the pop-up's current choice (R2-40, ED-346).
  final bool checked;

  /// An SF Symbol name (ED-260).
  final String? symbol;
  final bool enabled;

  /// The key hint beside the label; NSMenu draws it (⌘⌫ and so on).
  final SingleActivator? shortcut;

  Map<String, Object?> toWire() {
    final key = shortcut;
    return {
      'label': label,
      'index': index,
      'header': ?header,
      if (children.isNotEmpty)
        'children': [for (final c in children) c.toWire()],
      'symbol': symbol,
      'enabled': enabled,
      'checked': checked,
      'divided': divided,
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

/// The system menu over `dottoday/context_menu`: the Mac's NSMenu
/// (macos/Runner `ContextMenuBridge.swift`, ED-239, CR-098) and iOS's
/// pull-down UIMenu from 17.4 (ios/Runner `ContextMenuBridge.swift`, M19.4
/// part 4d). It answers the chosen index, or -1 when dismissed.
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
      // -1: shown and dismissed. No answer at all is no bridge (a test, an
      // older iOS): Flutter's menu then.
      if (index == null) return const NativeMenuMissing();
      return NativeMenuShown(index < 0 ? null : index);
    } on MissingPluginException {
      return const NativeMenuMissing();
    } on PlatformException {
      return const NativeMenuMissing();
    }
  }
}
