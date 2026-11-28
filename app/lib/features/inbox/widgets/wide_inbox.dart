import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/shortcuts/single_keys.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/completed_group.dart';
import 'package:dottoday/features/inbox/widgets/inbox_add_field.dart';
import 'package:dottoday/features/inbox/widgets/inbox_auto_plan.dart';
import 'package:dottoday/features/inbox/widgets/inbox_filters.dart';
import 'package:dottoday/features/inbox/widgets/inbox_header.dart';
import 'package:dottoday/features/inbox/widgets/inbox_list.dart';
import 'package:dottoday/features/inbox/widgets/inbox_task_row.dart';
import 'package:dottoday/shared/dot/next_free_slot.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The wide Inbox (E-R2-13 expanded, M3e.2): the header, then the list
/// (Add, filters with Sort, the next free slot, rows with where each fits
/// and Place, Completed, Auto-plan the week ⇧⌘P) beside [panel] ("Drop
/// onto today"). Dragging a row goes to the day, so the order changes
/// from the row's menu (Move up / Move down); ⌘⏎ on a row places it.
class WideInbox extends ConsumerWidget {
  const WideInbox({
    required this.items,
    required this.rooms,
    required this.rows,
    required this.panel,
    super.key,
  });

  final List<Occurrence> items;

  /// Today (from now) and the six days after it; null while loading.
  final List<DayRoom>? rooms;
  final InboxRowContext rows;
  final Widget Function(List<Occurrence> shown) panel;

  /// "Drop onto today" (render: 560 of 2000 px at 1280 → 360).
  static const _panelWidth = DotSize.readableColumn * 9 / 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = rooms;
    final fitOf = <String, WeekFit?>{
      for (final o in openItems(items)) o.id: r == null ? null : firstFit(o, r),
    };
    final filter = ref.watch(inboxFilterChoiceProvider);
    final sort = ref.watch(inboxSortChoiceProvider);
    final shown = sortInbox(
      filtered(items, filter, r?.first),
      sort,
      (o) => fitOf[o.id],
    );
    final plan = autoPlanAction(rows.commands, shown, r);
    final work = inboxWork(items);
    // ⇧⌘P auto-plans (web p, a single key; ED-095).
    return CallbackShortcuts(
      bindings: {
        if (!webChrome(context))
          AppShortcuts.activator(
            defaultTargetPlatform,
            LogicalKeyboardKey.keyP,
            shift: true,
          ): ?plan,
      },
      child: SingleKeys(
        bindings: {const SingleActivator(LogicalKeyboardKey.keyP): ?plan},
        child: Focus(
          autofocus: true,
          // Catches keys only; adds nothing for screen readers.
          includeSemantics: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              DotSpace.xxl + DotSpace.s,
              DotSpace.xl,
              DotSpace.xl,
              DotSpace.xl,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.xl,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      InboxHeader(count: work.count, minutes: work.minutes),
                      const SizedBox(height: DotSpace.m),
                      InboxAddField(onSubmit: rows.commands.add),
                      const SizedBox(height: DotSpace.m),
                      const InboxFilterRow(),
                      ..._slot(context, r),
                      const SizedBox(height: DotSpace.m),
                      InboxList(
                        shown: shown,
                        // The user's own order: "Sort: added", unfiltered.
                        canReorder:
                            sort == InboxSort.added &&
                            filter == InboxFilter.all,
                        commands: rows.commands,
                        row: (o, s) => _row(context, o, fitOf[o.id], s),
                        after: (_) => const SizedBox(height: DotSpace.s),
                      ),
                      ..._end(shown, plan),
                    ],
                  ),
                ),
                SizedBox(width: _panelWidth, child: panel(shown)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Next free slot today: …" over the rows.
  List<Widget> _slot(BuildContext context, List<DayRoom>? r) {
    final next = r == null ? null : nextFreeSlot(items, r.first);
    if (next == null) return const [];
    return [
      const SizedBox(height: DotSpace.m),
      NextFreeSlot(
        text: context.l10n.inboxNextSlot(
          rows.commands.rangeText(next.slot),
          next.item.title,
        ),
      ),
    ];
  }

  /// "Completed · 2" and "Auto-plan the week".
  List<Widget> _end(List<Occurrence> shown, VoidCallback? plan) {
    final done = [
      for (final o in items)
        if (o.status == OccurrenceStatus.done) o,
    ];
    final commands = rows.commands;
    return [
      if (done.isNotEmpty)
        CompletedGroup(
          items: done,
          onNotDone: (o) => unawaited(commands.notDone(o)),
          onClear: () => unawaited(commands.clearDone(done)),
        ),
      if (shown.isNotEmpty) ...[
        const SizedBox(height: DotSpace.m),
        InboxAutoPlanButton(onPressed: plan),
      ],
    ];
  }

  /// A row: drag it onto a gap, or ⌘⏎ to place it where it first fits.
  Widget _row(
    BuildContext context,
    Occurrence o,
    WeekFit? fit,
    InboxRowState s,
  ) {
    final row = rows.row(
      context,
      o,
      fit,
      s,
      onOpen: () => ProviderScope.containerOf(
        context,
      ).read(editingTaskProvider.notifier).open(o.id),
      swipe: false,
      holdToReorder: false,
    );
    // While picking, rows don't drag onto the thread.
    if (s.selected != null) return row;
    return CallbackShortcuts(
      bindings: {
        AppShortcuts.activator(
          defaultTargetPlatform,
          LogicalKeyboardKey.enter,
        ): () =>
            rows.place(o, fit),
      },
      child: InboxDraggable(item: o, child: row),
    );
  }
}

/// An inbox row lifted onto the thread: a mouse drags at once, touch
/// after the hold (M3e.1); the data is the task's id.
class InboxDraggable extends StatelessWidget {
  const InboxDraggable({required this.item, required this.child, super.key});

  final Occurrence item;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final color = TaskColor.fromKey(item.colorKey);
    return HoldOrMouseDraggable<String>(
      data: item.id,
      feedback: Material(
        color: t.colors.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: t.tasks[color].ink,
            width: DotSize.smallDotOutline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.l,
            vertical: DotSpace.s,
          ),
          child: Text(item.title, style: t.styles.rowTitle),
        ),
      ),
      // The same shape lifted or not, so the row keeps its state (its
      // hold, which opens the menu when it ends where it began).
      childWhenDragging: Opacity(opacity: TaskAlpha.done, child: child),
      callbacks: DragCallbacks(
        onDragStarted: () {},
        onDragUpdate: (_) {},
        onDragEnd: (_) {},
      ),
      child: Opacity(opacity: 1, child: child),
    );
  }
}
