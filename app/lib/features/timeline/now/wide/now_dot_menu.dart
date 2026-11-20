import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/selection_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/sheet_actions.dart';
import 'package:dottoday/features/timeline/widgets/when_move.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A right-click on a horizon dot in the Mac and web Now pane (E-Minimal
/// frame 1): the system's own menu on the Mac, Flutter's on the web.
/// Open, Mark Done, Move To…, Focus; Duplicate; Move to Trash, each with
/// Undo where it changes the day. The key hints are the ones the Mac's
/// menus show (ED-336); the keys themselves live with each action.
Future<void> showNowDotMenu(
  BuildContext context,
  WidgetRef ref,
  Occurrence o,
  Offset at,
) async {
  final l10n = context.l10n;
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final undo = container.read(undoServiceProvider);
  void report(Future<Result<UndoToken, AppFailure>> write, String message) =>
      unawaited(
        write.then(
          (r) => reportUndoable(
            messenger,
            l10n,
            undo,
            r,
            message: (_) => message,
            tokenOf: (t) => t,
          ),
        ),
      );
  final run = await showContextMenu<VoidCallback>(
    context,
    at: at,
    semanticLabel: o.title,
    entries: [
      ContextMenuEntry(
        value: () => openTask(context, o.id),
        label: l10n.nowDotOpen,
      ),
      ContextMenuEntry(
        value: () => unawaited(markDone(context, ref, o)),
        label: l10n.nowDotMarkDone,
      ),
      ContextMenuEntry(
        value: () => unawaited(pickMoveTask(context, ref, o)),
        label: l10n.nowDotMoveTo,
        enabled: !o.pinned,
        shortcut: const SingleActivator(
          LogicalKeyboardKey.keyM,
          meta: true,
          shift: true,
        ),
      ),
      ContextMenuEntry(
        value: () => openFocus(context, o.id),
        label: l10n.focusTitle,
      ),
      ContextMenuEntry(
        value: () =>
            report(duplicateAll(container, [o]), l10n.snackManyDuplicated(1)),
        label: l10n.selectionDuplicate,
        divided: true,
      ),
      ContextMenuEntry(
        value: () =>
            report(trashAll(container, [o]), l10n.snackTrashed(o.title)),
        label: l10n.inboxTrash,
        divided: true,
        shortcut: const SingleActivator(
          LogicalKeyboardKey.backspace,
          meta: true,
        ),
      ),
    ],
  );
  run?.call();
}
