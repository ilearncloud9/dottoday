import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/inbox_add_field.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/features/inbox/widgets/one_thing_meta.dart';
import 'package:dottoday/features/inbox/widgets/wide_inbox.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Plan panel's Capture and Inbox (E-FullA-v2, ED-184): the field
/// (with a time it lands on the day, without it waits here) and the open
/// Inbox tasks, each dragged onto a day to plan it (M3e.2). [capture]
/// draws the field; [rows] the tasks.
class InboxPlanSection extends ConsumerWidget {
  const InboxPlanSection({this.capture = false, this.rows = false, super.key});

  final bool capture;
  final bool rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider).value;
    final today = ref.watch(inboxTodayProvider).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (items == null || today == null || profile == null) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final t = DotTheme.of(context);
    final zone = tz.getLocation(profile.tzId);
    final use24h = use24hFor(context, profile.settings.use24h);
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final commands = InboxCommands(
      context,
      today: today,
      timeText: time,
      rangeText: (s) => l10n.threadTimeRange(time(s.startUtc), time(s.endUtc)),
    );
    final oneThing = ref.watch(todayOneThingIdProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        if (capture) ...[
          InboxAddField(onSubmit: commands.add, compact: true),
          Text(l10n.planPanelCaptureHint, style: t.styles.rowMeta),
        ],
        if (rows)
          for (final o in openItems(items))
            KeyedSubtree(
              key: ValueKey(o.id),
              child: _row(context, o, oneThing: o.id == oneThing),
            ),
      ],
    );
  }

  Widget _row(BuildContext context, Occurrence o, {required bool oneThing}) =>
      InboxDraggable(
        item: o,
        child: _Card(
          title: o.title,
          meta: inboxMetaWithOneThing(
            context.l10n,
            formatDurationShort(context.l10n, o.durationMin),
            oneThing: oneThing,
          ),
          color: TaskColor.fromKey(o.colorKey),
          icon: TaskIcon.fromKey(o.iconKey),
          onOpen: () => ProviderScope.containerOf(
            context,
          ).read(editingTaskProvider.notifier).open(o.id),
        ),
      );
}

/// An Inbox task in the panel (E-FullA-v2): its ring, the title over its
/// length; drag it onto a day to plan it, tap to open it.
class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.meta,
    required this.color,
    required this.icon,
    required this.onOpen,
  });

  final String title;
  final String meta;
  final TaskColor color;
  final TaskIcon icon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: context.l10n.statusHintJoin(title, meta),
      excludeSemantics: true,
      onTap: onOpen,
      child: Material(
        color: t.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.card),
          side: BorderSide(color: t.colors.hairline),
        ),
        child: InkWell(
          onTap: onOpen,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DotRadii.card),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.s + DotSpace.xxs),
            child: Row(
              spacing: DotSpace.s + DotSpace.xxs,
              children: [
                TaskDot(
                  color: color,
                  icon: icon,
                  state: DotState.upcoming,
                  label: title,
                  size: DotSize.pickerDot + DotSpace.s + DotSpace.xxs,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.styles.cardTitle),
                      Text(meta, style: t.styles.rowMeta),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The number of open Inbox tasks, for the section's heading.
int openInboxCount(WidgetRef ref) =>
    openItems(ref.watch(inboxItemsProvider).value ?? const []).length;
