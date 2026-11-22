import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/shell/native_context_menu.dart';
import 'package:dottoday/shared/menus/flutter_menu.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:flutter/material.dart';

export 'package:dottoday/shared/menus/flutter_menu.dart' show showFlutterMenu;

/// One choice in a menu: a right-click or long-press menu, a ⋯ button's,
/// a pop-up's.
@immutable
final class ContextMenuEntry<T> {
  const ContextMenuEntry({
    required this.value,
    required this.label,
    this.symbol,
    this.glyph,
    this.shortcut,
    this.enabled = true,
    this.checked,
    this.divided = false,
    this.header,
    this.children = const [],
  });

  /// A titled group starts here (ED-093's Time · Plan · Day · Layout).
  final String? header;

  /// Its submenu: the system's own on the Mac and iOS, a second menu on
  /// Android, chips in the row on the web (E-FullA-v2's Need more time).
  /// The entry's own [value] is never returned when it has children.
  final List<ContextMenuEntry<T>> children;

  /// What [showContextMenu] returns when this is chosen.
  final T value;
  final String label;

  /// An SF Symbol name, drawn only by the Mac's and iOS's own menus
  /// (ED-260: SF Symbols in native chrome only).
  final String? symbol;

  /// The app's icon for it in Flutter's menu (Android, the web).
  final DotGlyph? glyph;

  /// The key hint shown beside the label on Mac (e.g. ⌘⌫, ED-336). The
  /// key itself is bound where the action lives, not by the menu.
  final SingleActivator? shortcut;
  final bool enabled;

  /// Set for a pop-up's choices (R2-40, ED-346): ticked when true. Null
  /// in a plain menu, which has no ticks.
  final bool? checked;

  /// A line before this entry: it starts a new group.
  final bool divided;
}

/// Shows [entries] at [at] (global position) and returns the chosen
/// value, or null when dismissed. The Mac app and the iPhone and iPad
/// apps use the system menu (NSMenu, ED-239, CR-098; UIMenu from iOS
/// 17.4, owner 4d: each platform's own), headers and submenus included;
/// Android keeps Material's menu, the web Flutter's, and a build without
/// the bridge falls back to it ([showFlutterMenu]).
Future<T?> showContextMenu<T>(
  BuildContext context, {
  required Offset at,
  required List<ContextMenuEntry<T>> entries,
  String? semanticLabel,
}) async {
  if (macApp(context) || iosApp(context)) {
    final chosen = <T>[];
    NativeMenuItem native(ContextMenuEntry<T> e) {
      final index = e.children.isEmpty ? chosen.length : -1;
      if (e.children.isEmpty) chosen.add(e.value);
      return NativeMenuItem(
        label: e.label,
        index: index,
        symbol: e.symbol,
        enabled: e.enabled,
        shortcut: e.shortcut,
        checked: e.checked ?? false,
        divided: e.divided,
        header: e.header,
        children: [for (final c in e.children) native(c)],
      );
    }

    final shown = await NativeContextMenu.show(at, [
      for (final e in entries) native(e),
    ]);
    if (shown case NativeMenuShown(:final index)) {
      return index == null ? null : chosen[index];
    }
  }
  if (!context.mounted) return null;
  return showFlutterMenu(
    context,
    at: at,
    entries: entries,
    semanticLabel: semanticLabel,
  );
}

/// A ⋯ or pop-up button whose menu is [showContextMenu]'s, under the
/// button (owner, 4d: the system's own menu on the Mac and iOS). [icon]
/// is an icon button; [child] is drawn as it is. [entries] is read when
/// it opens, so ticks are current.
class DotMenuButton<T> extends StatelessWidget {
  const DotMenuButton({
    required this.tooltip,
    required this.entries,
    required this.onSelected,
    this.icon,
    this.child,
    super.key,
  }) : assert(
         icon != null || child != null,
         'an icon or a child', // l10n-ignore: assert message
       );

  final String tooltip;
  final List<ContextMenuEntry<T>> Function() entries;
  final ValueChanged<T> onSelected;
  final Widget? icon;
  final Widget? child;

  Future<void> _open(BuildContext button) async {
    final rect = globalRectOf(button);
    final rtl = Directionality.of(button) == TextDirection.rtl;
    final at = rect == null
        ? Offset.zero
        : (rtl ? rect.bottomRight : rect.bottomLeft);
    final picked = await showContextMenu<T>(button, at: at, entries: entries());
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) => Builder(
    builder: (button) {
      void open() => _open(button).ignore();
      if (child case final c?) {
        return Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: open,
            borderRadius: BorderRadius.circular(DotRadii.pill),
            child: c,
          ),
        );
      }
      return IconButton(tooltip: tooltip, onPressed: open, icon: icon!);
    },
  );
}
