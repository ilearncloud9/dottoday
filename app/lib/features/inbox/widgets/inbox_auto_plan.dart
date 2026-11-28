import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The key of Auto-plan's ⇧⌘P.
const _key = 'P'; // l10n-ignore: a key cap, not words

/// Places [shown] in its order (the Sort picked) across the week of
/// [rooms]; one Undo (ED-150).
Future<void> autoPlanInbox(
  InboxCommands commands,
  List<Occurrence> shown,
  List<DayRoom> rooms,
) async {
  final plan = autoPlan(shown, rooms);
  await commands.placeAll(plan.placed, left: plan.unplaced.length);
}

/// "Auto-plan the week" under the list (E-R2-13), with ⇧⌘P on the Mac
/// and the web; disabled while the week loads.
class InboxAutoPlanButton extends StatelessWidget {
  const InboxAutoPlanButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final keys = touchApp(context)
        ? null
        : AppShortcuts.label(defaultTargetPlatform, _key, shift: true);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(DotTouch.android),
        foregroundColor: t.colors.ink,
        textStyle: t.styles.button,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.s,
        children: [
          Flexible(child: Text(context.l10n.inboxAutoPlan)),
          if (keys != null)
            ExcludeSemantics(child: Text(keys, style: t.styles.rowMeta)),
        ],
      ),
    );
  }
}

/// Runs [autoPlanInbox] from a button.
VoidCallback? autoPlanAction(
  InboxCommands commands,
  List<Occurrence> shown,
  List<DayRoom>? rooms,
) => switch (rooms) {
  null => null,
  final r => () => unawaited(autoPlanInbox(commands, shown, r)),
};
