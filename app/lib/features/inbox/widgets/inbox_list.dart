import 'dart:async';

import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/inbox/state/inbox_selection.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How one row takes part in picking and ordering (docs/09 M3f.9c).
typedef InboxRowState = ({
  /// Null when not selecting; else whether this row is picked.
  bool? selected,

  /// Picks or unpicks this row (the menu's Select, and a tap while
  /// selecting).
  VoidCallback toggle,

  /// Its place for the drag handle; null when the list can't be reordered.
  int? reorderIndex,
  VoidCallback? moveUp,
  VoidCallback? moveDown,
});

/// The Inbox's open rows: in the user's own order by drag (or Move up /
/// down) when [canReorder] and nobody is picking; a tap picks while
/// selecting. [row] draws a row; [after] goes under row i (the swipe
/// hint, spacing).
class InboxList extends ConsumerWidget {
  const InboxList({
    required this.shown,
    required this.canReorder,
    required this.commands,
    required this.row,
    required this.after,
    super.key,
  });

  final List<Occurrence> shown;
  final bool canReorder;
  final InboxCommands commands;
  final Widget Function(Occurrence o, InboxRowState state) row;
  final Widget Function(int index) after;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picked = ref.watch(inboxSelectionProvider);
    final selection = ref.read(inboxSelectionProvider.notifier);
    final selecting = picked.isNotEmpty;
    final reorder = canReorder && !selecting;
    void move(int from, int to) => unawaited(commands.reorder(shown, from, to));
    final children = [
      for (final (i, o) in shown.indexed)
        Column(
          key: ValueKey(o.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row(o, (
              selected: selecting ? picked.contains(o.id) : null,
              toggle: () => selection.toggle(o.id),
              reorderIndex: reorder ? i : null,
              moveUp: reorder && i > 0 ? () => move(i, i - 1) : null,
              moveDown: reorder && i < shown.length - 1
                  ? () => move(i, i + 1)
                  : null,
            )),
            after(i),
          ],
        ),
    ];
    if (!reorder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorderItem: move,
      children: children,
    );
  }
}
