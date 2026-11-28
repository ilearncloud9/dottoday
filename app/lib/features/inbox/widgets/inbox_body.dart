import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
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
import 'package:dottoday/features/inbox/widgets/swipe_hint.dart';
import 'package:dottoday/shared/dot/next_free_slot.dart';
import 'package:dottoday/shared/states/state_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Inbox on phones and medium windows (E-R2-13, ED-295): the header,
/// Add, the filters with Sort, the next free slot, the rows with where
/// each fits and Place, then Completed and Auto-plan the week. Minimal
/// (docs/14 §3 `inboxExtras` Hidden) keeps the next free slot, swipe and
/// Place only.
class InboxBody extends ConsumerWidget {
  const InboxBody({
    required this.items,
    required this.room,
    required this.rooms,
    required this.extras,
    required this.rows,
    super.key,
  });

  final List<Occurrence> items;

  /// Today's free time from now; null while loading.
  final DayRoom? room;

  /// Today and the six days after it; null while loading.
  final List<DayRoom>? rooms;

  /// Filters, Sort, swipe hint, Completed and Auto-plan (docs/14 §3).
  final bool extras;
  final InboxRowContext rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = rooms;
    // No filter or sort in minimal, so nothing stored hides or reorders.
    final filter = extras
        ? ref.watch(inboxFilterChoiceProvider)
        : InboxFilter.all;
    final sort = extras ? ref.watch(inboxSortChoiceProvider) : InboxSort.added;
    final fitOf = <String, WeekFit?>{
      for (final o in openItems(items)) o.id: r == null ? null : firstFit(o, r),
    };
    final shown = sortInbox(
      filtered(items, filter, room),
      sort,
      (o) => fitOf[o.id],
    );
    final work = inboxWork(items);
    final next = room == null ? null : nextFreeSlot(items, room!);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.xl,
        DotSpace.page,
        DotSpace.xxl,
      ),
      children: [
        InboxHeader(count: work.count, minutes: work.minutes),
        const SizedBox(height: DotSpace.m),
        InboxAddField(onSubmit: rows.commands.add),
        if (extras) ...[
          const SizedBox(height: DotSpace.m),
          const InboxFilterRow(),
        ],
        if (next != null) ...[
          const SizedBox(height: DotSpace.m),
          NextFreeSlot(
            text: l10n.inboxNextSlot(
              rows.commands.rangeText(next.slot),
              next.item.title,
            ),
          ),
        ],
        const SizedBox(height: DotSpace.m),
        ..._empty(context, work.count, shown.isEmpty),
        InboxList(
          shown: shown,
          // The user's own order: "Sort: added", unfiltered (M3f.9c).
          canReorder: sort == InboxSort.added && filter == InboxFilter.all,
          commands: rows.commands,
          row: (o, s) => rows.row(
            context,
            o,
            fitOf[o.id],
            s,
            onOpen: () => openTask(context, o.id),
          ),
          after: (i) => i == 0 && extras
              ? const InboxSwipeHint()
              : const SizedBox(height: DotSpace.s),
        ),
        if (extras) ..._end(shown, r),
      ],
    );
  }

  /// The state kit's empty Inbox (E-G4-7-States A5); a filter that shows
  /// nothing keeps its one quiet line.
  List<Widget> _empty(BuildContext context, int count, bool none) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    if (count == 0) {
      return [
        StateMessage(
          glyph: DotGlyphs.inbox,
          title: l10n.inboxEmpty,
          body: l10n.inboxEmptyBody,
        ),
      ];
    }
    if (!none) return const [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: DotSpace.xl),
        child: Text(
          l10n.inboxNoMatch,
          style: t.styles.body.copyWith(color: t.colors.secondary),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  /// "Completed · 2" and "Auto-plan the week".
  List<Widget> _end(List<Occurrence> shown, List<DayRoom>? r) {
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
        InboxAutoPlanButton(onPressed: autoPlanAction(commands, shown, r)),
      ],
    ];
  }
}
