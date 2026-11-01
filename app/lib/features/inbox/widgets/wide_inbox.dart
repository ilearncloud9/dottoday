import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/completed_group.dart';
import 'package:dottoday/features/inbox/widgets/inbox_add_field.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/features/inbox/widgets/inbox_filters.dart';
import 'package:dottoday/features/inbox/widgets/inbox_fit.dart';
import 'package:dottoday/features/inbox/widgets/inbox_list.dart';
import 'package:dottoday/features/inbox/widgets/one_thing_meta.dart';
import 'package:dottoday/features/inbox/widgets/wide_inbox_header.dart';
import 'package:dottoday/shared/dot/inbox_row.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Mac/web Inbox (docs/10 §5.2 I1 expanded, `A-mac-inbox`, M3e.2):
/// the list with where each task fits, Sort and Auto-plan the week (⇧⌘P),
/// and [panel] ("Drop onto today") beside it. ⌘⏎ on a row places it in
/// its first fitting slot.
class WideInbox extends ConsumerWidget {
  const WideInbox({
    required this.items,
    required this.rooms,
    required this.zone,
    required this.commands,
    required this.fits,
    required this.panel,
    super.key,
  });

  final List<Occurrence> items;

  /// Today (from now) and the six days after it; null while loading.
  final List<DayRoom>? rooms;
  final tz.Location zone;
  final InboxCommands commands;
  final InboxFitText fits;
  final Widget Function(List<Occurrence> shown) panel;

  /// "Drop onto today" (render: 560 of 2000 px at 1280 → 360).
  static const _panelWidth = DotSize.readableColumn * 9 / 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = rooms;
    final fitOf = <String, WeekFit?>{
      for (final o in openItems(items)) o.id: r == null ? null : firstFit(o, r),
    };
    final shown = sortInbox(
      filtered(items, ref.watch(inboxFilterChoiceProvider), r?.first),
      ref.watch(inboxSortChoiceProvider),
      (o) => fitOf[o.id],
    );
    final plan = r == null ? null : () => unawaited(_autoPlan(shown, r));
    return CallbackShortcuts(
      bindings: {
        AppShortcuts.activator(
          defaultTargetPlatform,
          LogicalKeyboardKey.keyP,
          shift: true,
        ): ?plan,
      },
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.l,
            children: [
              WideInboxHeader(items: items, onAutoPlan: plan),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DotSpace.xl,
                  children: [
                    Expanded(child: _list(context, ref, shown, fitOf)),
                    SizedBox(width: _panelWidth, child: panel(shown)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    WidgetRef ref,
    List<Occurrence> shown,
    Map<String, WeekFit?> fitOf,
  ) {
    final oneThingId = ref.watch(todayOneThingIdProvider);
    final done = [
      for (final o in items)
        if (o.status == OccurrenceStatus.done) o,
    ];
    return ListView(
      children: [
        InboxAddField(onSubmit: commands.add),
        const SizedBox(height: DotSpace.m),
        const InboxFilters(),
        const SizedBox(height: DotSpace.m),
        InboxList(
          shown: shown,
          // The user's own order: "Sort: added", unfiltered (M3f.9c).
          canReorder:
              ref.watch(inboxSortChoiceProvider) == InboxSort.added &&
              ref.watch(inboxFilterChoiceProvider) == InboxFilter.all,
          commands: commands,
          row: (o, s) =>
              _row(context, o, fitOf[o.id], s, oneThing: o.id == oneThingId),
          after: (_) => const SizedBox(height: DotSpace.s),
        ),
        if (done.isNotEmpty) ...[
          const SizedBox(height: DotSpace.l),
          CompletedGroup(
            items: done,
            onNotDone: (o) => unawaited(commands.notDone(o)),
            onClear: () => unawaited(commands.clearDone(done)),
          ),
        ],
      ],
    );
  }

  /// A row: drag it onto a gap, or ⌘⏎ to place it where it first fits.
  Widget _row(
    BuildContext context,
    Occurrence o,
    WeekFit? fit,
    InboxRowState s, {
    required bool oneThing,
  }) {
    final l10n = context.l10n;
    final created = tz.TZDateTime.from(o.createdAt, zone);
    void place() {
      if (fit != null) unawaited(commands.place(o, fits.choice(fit)));
    }

    final row = InboxRow(
      title: o.title,
      meta: inboxMetaWithOneThing(
        l10n,
        fits.added(formatDurationShort(l10n, o.durationMin), created),
        oneThing: oneThing,
      ),
      oneThing: oneThing,
      fit: rooms == null ? null : fits.fit(fit),
      titleFirst: true,
      swipe: false,
      color: TaskColor.fromKey(o.colorKey),
      icon: TaskIcon.fromKey(o.iconKey),
      onSchedule: () => unawaited(commands.schedule(o)),
      onTrash: () => unawaited(commands.trash(o)),
      onOpen: s.selected != null
          ? s.toggle
          : () => ProviderScope.containerOf(
              context,
            ).read(editingTaskProvider.notifier).open(o.id),
      selected: s.selected,
      onSelect: s.toggle,
      reorderIndex: s.reorderIndex,
      onMoveUp: s.moveUp,
      onMoveDown: s.moveDown,
    );
    // While picking, rows don't drag onto the thread.
    if (s.selected != null) return row;
    return CallbackShortcuts(
      bindings: {
        AppShortcuts.activator(defaultTargetPlatform, LogicalKeyboardKey.enter):
            place,
      },
      child: InboxDraggable(item: o, child: row),
    );
  }

  /// Places [shown] in its order (the Sort the user picked) across the
  /// week; one Undo.
  Future<void> _autoPlan(List<Occurrence> shown, List<DayRoom> rooms) async {
    final plan = autoPlan(shown, rooms);
    await commands.placeAll(plan.placed, left: plan.unplaced.length);
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
        color: t.colors.raised,
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
      childWhenDragging: Opacity(opacity: TaskAlpha.done, child: child),
      callbacks: DragCallbacks(
        onDragStarted: () {},
        onDragUpdate: (_) {},
        onDragEnd: (_) {},
      ),
      child: child,
    );
  }
}
