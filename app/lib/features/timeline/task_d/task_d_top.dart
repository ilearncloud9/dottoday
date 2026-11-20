import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/editor/editor_leave.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Option D's top row (E-Phones, ED-086): ⋯ and Done on the iPhone;
/// Android adds ← and "Edit task" (E-Phones "Android · Task editor").
/// Done saves (asking the scope of a repeating task) and closes.
class TaskDTopBar extends StatelessWidget {
  const TaskDTopBar({
    required this.task,
    required this.leave,
    required this.onDone,
    required this.onBreakDown,
    this.onBack,
    super.key,
  });

  final TaskView task;
  final EditorLeave leave;
  final VoidCallback onDone;
  final VoidCallback onBreakDown;

  /// Android's ←: closes the tablets' panel; null pops the sheet.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final android = DotIdiom.of(context) == DotIdiom.material;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.xs,
        0,
        DotSpace.page,
        DotSpace.s,
      ),
      child: Row(
        spacing: DotSpace.s,
        children: [
          if (android) ...[
            IconButton(
              tooltip: l10n.sheetClose,
              onPressed:
                  onBack ?? () => unawaited(Navigator.of(context).maybePop()),
              icon: DotIcon(DotGlyphs.arrowLeft, color: t.colors.text),
            ),
            Expanded(
              child: Text(l10n.editorCaption, style: t.styles.topBarTitle),
            ),
          ] else
            const Spacer(),
          TaskDMenu(task: task, leave: leave, onBreakDown: onBreakDown),
          if (android)
            FilledButton(onPressed: onDone, child: Text(l10n.sheetDone))
          else
            TextButton(onPressed: onDone, child: Text(l10n.sheetDone)),
        ],
      ),
    );
  }
}

enum _Item { breakDown, inbox, delete }

/// ⋯ (ED-086 "Sound, Pin, Travel time and Delete in More and in ⋯"):
/// Break it down (kept from the old editor's steps header, owner M19.4),
/// Move to inbox and Delete task. Sound, Travel time and Pinned are the
/// More card's, below.
class TaskDMenu extends ConsumerWidget {
  const TaskDMenu({
    required this.task,
    required this.leave,
    required this.onBreakDown,
    super.key,
  });

  final TaskView task;
  final EditorLeave leave;

  /// Saves, closes the sheet and opens the proposal over the day: an open
  /// draft would miss the length the steps give it (M10.4).
  final VoidCallback onBreakDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final o = task.occurrence;
    final android = DotIdiom.of(context) == DotIdiom.material;
    return DotMenuButton<_Item>(
      tooltip: l10n.createMore,
      icon: DotIcon(
        android ? DotGlyphs.moreVertical : DotGlyphs.more,
        color: t.colors.text,
      ),
      onSelected: (item) => switch (item) {
        _Item.breakDown => onBreakDown(),
        _Item.inbox => unawaited(leave.toInbox(context, ref)),
        _Item.delete => unawaited(leave.delete(context, ref)),
      },
      entries: () => [
        ContextMenuEntry(value: _Item.breakDown, label: l10n.breakdownAction),
        if (o.startUtc != null)
          ContextMenuEntry(value: _Item.inbox, label: l10n.editorMoveToInbox),
        ContextMenuEntry(
          value: _Item.delete,
          label: l10n.editorDelete,
          symbol: 'trash', // l10n-ignore: SF Symbol name
          divided: true,
        ),
      ],
    );
  }
}
