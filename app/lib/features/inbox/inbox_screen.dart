import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/completed_group.dart';
import 'package:dottoday/features/inbox/widgets/drop_today_panel.dart';
import 'package:dottoday/features/inbox/widgets/inbox_add_field.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/features/inbox/widgets/inbox_filters.dart';
import 'package:dottoday/features/inbox/widgets/inbox_fit.dart';
import 'package:dottoday/features/inbox/widgets/inbox_header.dart';
import 'package:dottoday/features/inbox/widgets/inbox_list.dart';
import 'package:dottoday/features/inbox/widgets/inbox_selection_bar.dart';
import 'package:dottoday/features/inbox/widgets/swipe_hint.dart';
import 'package:dottoday/features/inbox/widgets/wide_inbox.dart';
import 'package:dottoday/shared/dot/inbox_row.dart';
import 'package:dottoday/shared/dot/next_free_slot.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Inbox (docs/10 §5.2 I1, `A-ios-inbox`): what has no time yet, a
/// quick-add field, filters, the next free slot that fits something, and
/// what is already done.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  static const _key = ValueKey('route:inbox');

  /// A readable column on medium windows; expanded is [WideInbox].
  static const _maxWidth = DotSize.readableColumn;

  /// What the Inbox needs before it can draw (docs/09 M3f.9b).
  static List<AsyncValue<Object?>> _inputs(WidgetRef ref) => [
    ref.watch(inboxItemsProvider),
    ref.watch(inboxTodayProvider),
    ref.watch(currentProfileProvider),
  ];

  /// Try again (docs/09 M3f.9b).
  static void _retry(WidgetRef ref) => ref
    ..invalidate(inboxItemsProvider)
    ..invalidate(inboxTodayProvider)
    ..invalidate(currentProfileProvider);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (waitFor(_key, _inputs(ref), onRetry: () => _retry(ref)) case final w?) {
      return w;
    }
    final items = ref.watch(inboxItemsProvider).requireValue;
    final today = ref.watch(inboxTodayProvider).requireValue;
    final profile = ref.watch(currentProfileProvider).requireValue;
    final room = ref.watch(dayRoomProvider(today)).value;
    final zone = tz.getLocation(profile.tzId);
    final use24h = use24hFor(context, profile.settings.use24h);
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final commands = InboxCommands(
      context,
      today: today,
      timeText: time,
      rangeText: (s) =>
          context.l10n.threadTimeRange(time(s.startUtc), time(s.endUtc)),
    );
    final narrow = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: _Body(
          items: items,
          room: room,
          filter: ref.watch(inboxFilterChoiceProvider),
          commands: commands,
        ),
      ),
    );
    return Scaffold(
      key: _key,
      bottomNavigationBar: SafeArea(
        child: InboxSelectionBar(
          items: items,
          today: today,
          commands: commands,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) =>
              WidthClass.of(box.maxWidth) == WidthClass.expanded
              ? _wide(context, ref, items, today, zone, time, commands)
              : narrow,
        ),
      ),
    );
  }

  /// Mac/web (M3e.2): the list with fits beside "Drop onto today".
  Widget _wide(
    BuildContext context,
    WidgetRef ref,
    List<Occurrence> items,
    DateTime today,
    tz.Location zone,
    String Function(DateTime utc) time,
    InboxCommands commands,
  ) {
    final l10n = context.l10n;
    final rooms = ref.watch(inboxWeekRoomsProvider(today)).value;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    return WideInbox(
      items: items,
      rooms: rooms,
      zone: zone,
      commands: commands,
      fits: InboxFitText(
        context,
        today: today,
        timeText: time,
        rangeText: commands.rangeText,
      ),
      panel: (shown) => rooms == null
          ? const SizedBox.shrink()
          : DropTodayPanel(
              room: rooms.first,
              items: shown,
              zone: zone,
              nowUtc: now,
              commands: commands,
              format: ThreadFormat(
                time: time,
                range: l10n.threadTimeRange,
                duration: (m) => formatDurationShort(l10n, m),
              ),
            ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.items,
    required this.room,
    required this.filter,
    required this.commands,
  });

  final List<Occurrence> items;
  final DayRoom? room;
  final InboxFilter filter;
  final InboxCommands commands;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final work = inboxWork(items);
    final shown = filtered(items, filter, room);
    final next = room == null ? null : nextFreeSlot(items, room!);
    final done = [
      for (final o in items)
        if (o.status == OccurrenceStatus.done) o,
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.xl,
        DotSpace.page,
        DotSpace.xxl,
      ),
      children: [
        InboxHeader(count: work.count, minutes: work.minutes),
        const SizedBox(height: DotSpace.l),
        InboxAddField(onSubmit: commands.add),
        const SizedBox(height: DotSpace.m),
        const InboxFilters(),
        const SizedBox(height: DotSpace.m),
        if (work.count == 0 || shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DotSpace.xl),
            child: Text(
              work.count == 0 ? l10n.inboxEmpty : l10n.inboxNoMatch,
              style: t.styles.body.copyWith(color: t.colors.muted),
              textAlign: TextAlign.center,
            ),
          ),
        InboxList(
          shown: shown,
          // The user's own order: the stored one, unfiltered (M3f.9c).
          canReorder: filter == InboxFilter.all,
          commands: commands,
          row: (o, s) => InboxRow(
            title: o.title,
            meta: formatDurationShort(l10n, o.durationMin),
            color: TaskColor.fromKey(o.colorKey),
            icon: TaskIcon.fromKey(o.iconKey),
            onSchedule: () => unawaited(commands.schedule(o)),
            onTrash: () => unawaited(commands.trash(o)),
            onOpen: s.selected == null
                ? () => unawaited(context.push(AppRoutes.task(o.id)))
                : s.toggle,
            selected: s.selected,
            onSelect: s.toggle,
            reorderIndex: s.reorderIndex,
            onMoveUp: s.moveUp,
            onMoveDown: s.moveDown,
          ),
          after: (i) => i == 0
              ? const InboxSwipeHint()
              : const SizedBox(height: DotSpace.s),
        ),
        if (next != null) ...[
          const SizedBox(height: DotSpace.s),
          NextFreeSlot(
            text: l10n.inboxNextSlot(
              commands.rangeText(next.slot),
              next.item.title,
            ),
            placeLabel: l10n.inboxPlace,
            onPlace: () => unawaited(
              commands.place(next.item, (
                slot: next.slot,
                label: l10n.inboxScheduleToday(commands.rangeText(next.slot)),
              )),
            ),
          ),
        ],
        ..._completed(done),
      ],
    );
  }

  List<Widget> _completed(List<Occurrence> done) => [
    if (done.isNotEmpty) ...[
      const SizedBox(height: DotSpace.l),
      CompletedGroup(
        items: done,
        onNotDone: (o) => unawaited(commands.notDone(o)),
        onClear: () => unawaited(commands.clearDone(done)),
      ),
    ],
  ];
}
