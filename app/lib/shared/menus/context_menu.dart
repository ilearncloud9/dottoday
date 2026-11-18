import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/data/shell/native_context_menu.dart';
import 'package:flutter/material.dart';

/// One choice in a right-click or long-press menu.
@immutable
final class ContextMenuEntry<T> {
  const ContextMenuEntry({
    required this.value,
    required this.label,
    this.symbol,
    this.shortcut,
    this.enabled = true,
  });

  /// What [showContextMenu] returns when this is chosen.
  final T value;
  final String label;

  /// An SF Symbol name, drawn only by the Mac's native menu (ED-260:
  /// SF Symbols in native chrome only).
  final String? symbol;

  /// The key hint shown beside the label on Mac (e.g. ⌘⌫, ED-336). The
  /// key itself is bound where the action lives, not by the menu.
  final SingleActivator? shortcut;
  final bool enabled;
}

/// Shows [entries] at [at] (global position) and returns the chosen
/// value, or null when dismissed. The Mac app uses the system menu
/// (NSMenu, ED-239, CR-098); everything else, and a Mac build without
/// the bridge, uses Flutter's menu.
Future<T?> showContextMenu<T>(
  BuildContext context, {
  required Offset at,
  required List<ContextMenuEntry<T>> entries,
}) async {
  if (macApp(context)) {
    final native = await NativeContextMenu.show(at, [
      for (final e in entries)
        NativeMenuItem(
          label: e.label,
          symbol: e.symbol,
          enabled: e.enabled,
          shortcut: e.shortcut,
        ),
    ]);
    if (native case NativeMenuShown(:final index)) {
      return index == null ? null : entries[index].value;
    }
  }
  if (!context.mounted) return null;
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromLTRB(at.dx, at.dy, at.dx, at.dy),
    items: [
      for (final e in entries)
        PopupMenuItem(value: e.value, enabled: e.enabled, child: Text(e.label)),
    ],
  );
}
