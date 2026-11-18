import 'dart:async';
import 'dart:convert';

import 'package:dottoday/app_menus.dart';
import 'package:dottoday/data/shell/native_key_menus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Hands the app's menus to iPadOS and Android (R2-10, ED-095): the iPad
/// shows them in its menu bar while ⌘ is held and runs them from their key
/// commands; Android lists the ones with keys in its Keyboard Shortcuts
/// Helper (Meta+/). Text-editing items stay the system's own there. Sent
/// again only when the list changes (a language or layout switch).
class NativeKeyMenus extends StatefulWidget {
  const NativeKeyMenus({required this.menus, required this.child, super.key});

  final List<AppMenu> menus;
  final Widget child;

  /// [menus] as the channel carries them: `kind`, `label` and `groups` of
  /// `{id, label, key, shift}`; `key` is the key's character ("n", "1",
  /// "[", "/", ","), absent when the item has none.
  static List<Map<String, Object?>> wire(List<AppMenu> menus) => [
    for (final (m, menu) in menus.indexed)
      {
        'kind': menu.kind.name,
        'label': menu.label,
        'groups': [
          for (final (g, group) in menu.groups.indexed)
            [
              for (final (i, c) in group.indexed)
                if (!c.textEdit)
                  {
                    'id': '$m.$g.$i',
                    'label': c.label,
                    if (c.key case final key?) 'key': keyName(key),
                    'shift': c.shift,
                    if (c.alt) 'alt': true,
                  },
            ],
        ],
      },
  ];

  /// The character a key command takes for [key].
  static String keyName(LogicalKeyboardKey key) => key.keyLabel.toLowerCase();

  @override
  State<NativeKeyMenus> createState() => _NativeKeyMenusState();
}

class _NativeKeyMenusState extends State<NativeKeyMenus> {
  String? _sent;

  @override
  Widget build(BuildContext context) {
    final wire = NativeKeyMenus.wire(widget.menus);
    final text = jsonEncode(wire);
    if (text != _sent) {
      _sent = text;
      unawaited(NativeKeyMenusChannel.set(wire, _select));
    }
    return widget.child;
  }

  /// Runs the command [id] names in the current menus.
  void _select(String id) {
    final [m, g, i] = [for (final n in id.split('.')) int.parse(n)];
    widget.menus[m].groups[g][i].onSelected?.call();
  }
}
