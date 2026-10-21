import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/completed_group.dart';
import 'package:dottoday/features/inbox/widgets/inbox_add_field.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/features/inbox/widgets/inbox_filters.dart';
import 'package:dottoday/features/inbox/widgets/inbox_header.dart';
import 'package:dottoday/shared/dot/inbox_row.dart';
import 'package:dottoday/shared/dot/next_free_slot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
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

  /// A readable column on wide windows (Mac/web get the sidebar in M3e).
  static const _maxWidth = DotSize.readableColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider).value;
    final today = ref.watch(inboxTodayProvider).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (items == null || today == null || profile == null) {
      return const Scaffold(key: _key);
    }
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
    return Scaffold(
      key: _key,
      body: SafeArea(
        child: Align(
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
        for (final o in shown) ...[
          InboxRow(
            key: ValueKey(o.id),
            title: o.title,
            meta: formatDurationShort(l10n, o.durationMin),
            color: TaskColor.fromKey(o.colorKey),
            icon: TaskIcon.fromKey(o.iconKey),
            onSchedule: () => unawaited(commands.schedule(o)),
            onTrash: () => unawaited(commands.trash(o)),
            onOpen: () => unawaited(context.push(AppRoutes.task(o.id))),
          ),
          if (o == shown.first)
            const _SwipeHint()
          else
            const SizedBox(height: DotSpace.s),
        ],
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
        if (done.isNotEmpty) ...[
          const SizedBox(height: DotSpace.l),
          CompletedGroup(items: done),
        ],
      ],
    );
  }
}

/// "← Schedule · Move to Trash →" under the first row, so the swipes are
/// discoverable (`A-ios-inbox`). Arrows follow the reading direction.
class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final style = t.styles.rowMeta;
    final arrow = DotSize.rowIcon - DotSpace.xs;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.l,
          vertical: DotSpace.s,
        ),
        child: Row(
          children: [
            DotIcon(
              rtl ? DotGlyphs.arrowRight : DotGlyphs.arrowLeft,
              color: t.colors.muted,
              size: arrow,
            ),
            const SizedBox(width: DotSpace.xs),
            Text(l10n.inboxSchedule, style: style),
            const Spacer(),
            Text(l10n.inboxTrash, style: style),
            const SizedBox(width: DotSpace.xs),
            DotIcon(
              rtl ? DotGlyphs.arrowLeft : DotGlyphs.arrowRight,
              color: t.colors.muted,
              size: arrow,
            ),
          ],
        ),
      ),
    );
  }
}
