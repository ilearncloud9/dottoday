import 'dart:async';

import 'package:dottoday/core/editing/add_anchor.dart';
import 'package:dottoday/core/editing/add_modes.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The tablets' + menus (E-R2-3, ED-271; G2-8): an Android tablet's +
/// opens Task · Brain dump · Routine; holding the iPad's + shows Brain
/// dump · Routine · Paste a list. Each runs the same command as the keys.
enum AddMenu {
  /// Android tablets, on a tap.
  modes,

  /// iPad, on a hold.
  hold;

  /// The menu a tap on the + opens here, or null when the tap adds.
  static AddMenu? onTap(BuildContext context) =>
      _tablet(context, TargetPlatform.android) ? modes : null;

  /// The menu a hold on the + opens here, or null.
  static AddMenu? onHold(BuildContext context) =>
      _tablet(context, TargetPlatform.iOS) ? hold : null;

  // The containers differ by platform (docs/10 §4); the width class says
  // it is a tablet, never the device.
  static bool _tablet(BuildContext context, TargetPlatform platform) =>
      !webChrome(context) &&
      Theme.of(context).platform == platform &&
      AppLayout.classOf(context) != WidthClass.compact;
}

/// Shows [menu] under the + that [context] belongs to and runs the pick.
Future<void> showAddMenu(BuildContext context, AddMenu menu) async {
  final l10n = context.l10n;
  final box = context.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final at = RelativeRect.fromRect(
    Rect.fromPoints(
      box.localToGlobal(box.size.bottomLeft(Offset.zero), ancestor: overlay),
      box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );
  const task = AppCommandIntent(AppCommand.quickAdd);
  const dump = OpenAddIntent(AddMode.brainDump);
  const routine = OpenAddIntent(AddMode.routine);
  const paste = AppCommandIntent(AppCommand.pasteAsTasks);
  final items = <(Intent, String, DotGlyph)>[
    if (menu == AddMenu.modes) (task, l10n.createTabTask, DotGlyphs.add),
    (dump, l10n.dumpTitle, DotGlyphs.edit),
    (routine, l10n.routineDropTitle, DotGlyphs.repeat),
    if (menu == AddMenu.hold) (paste, l10n.addMenuPasteList, DotGlyphs.sort),
  ];
  final t = DotTheme.of(context);
  final picked = await showMenu<Intent>(
    context: context,
    position: at,
    semanticLabel: l10n.addMenuLabel,
    items: [
      for (final (intent, label, glyph) in items)
        PopupMenuItem(
          value: intent,
          child: Row(
            spacing: DotSpace.m,
            children: [
              DotIcon(glyph, color: t.colors.text),
              Text(label),
            ],
          ),
        ),
    ],
  );
  if (picked == null || !context.mounted) return;
  Actions.maybeInvoke(context, picked);
}

/// Wraps a + button: where Add's popover points ([AddAnchor]), and the
/// tablets' menus, Android's on a tap and the iPad's on a hold; elsewhere
/// a tap adds.
class AddMenuButton extends StatelessWidget {
  const AddMenuButton({required this.onAdd, required this.builder, super.key});

  final VoidCallback onAdd;

  /// The button itself, given what its press does.
  final Widget Function(VoidCallback onPressed) builder;

  @override
  Widget build(BuildContext context) => AddAnchor(
    child: Builder(
      builder: (context) {
        final tap = AddMenu.onTap(context);
        final hold = AddMenu.onHold(context);
        return GestureDetector(
          onLongPress: hold == null
              ? null
              : () => unawaited(showAddMenu(context, hold)),
          child: builder(
            tap == null ? onAdd : () => unawaited(showAddMenu(context, tap)),
          ),
        );
      },
    ),
  );
}
