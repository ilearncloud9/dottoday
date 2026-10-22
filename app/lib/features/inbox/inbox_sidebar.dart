import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/inbox_add_field.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/features/inbox/widgets/wide_inbox.dart';
import 'package:dottoday/shared/dot/inbox_row.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// [child] with the Inbox as a 300 px sidebar at the expanded width (docs/10
/// §4 "Inbox as a 300 px sidebar on Today", `A-mac-week-alt3-board`):
/// drag a row onto a free gap to plan it (M3e.2). It shows once [child]
/// keeps the expanded width beside it (a window of ~1 140 px with the
/// rail); narrower windows get [child] alone. Composed at the app root, so no feature imports another.
class InboxSidebarFrame extends StatelessWidget {
  const InboxSidebarFrame({required this.child, super.key});

  final Widget child;

  static const width = 300.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      // Only when what is beside it stays expanded: a narrower Today would
      // fall back to the pager, a narrower Week would scroll sideways.
      if (box.maxWidth - width < WidthClass.expandedFrom) return child;
      final c = DotTheme.of(context).colors;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: width,
            // Its own surface: the field and ink need a Material, whatever
            // the shell around it provides.
            child: Material(color: c.surface, child: const _Sidebar()),
          ),
          VerticalDivider(width: DotSpace.hairline, color: c.outline),
          Expanded(child: child),
        ],
      );
    },
  );
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider).value;
    final today = ref.watch(inboxTodayProvider).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (items == null || today == null || profile == null) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final zone = tz.getLocation(profile.tzId);
    final use24h = use24hFor(context, profile.settings.use24h);
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final commands = InboxCommands(
      context,
      today: today,
      timeText: time,
      rangeText: (s) => l10n.threadTimeRange(time(s.startUtc), time(s.endUtc)),
    );
    final open = openItems(items).toList();
    return ListView(
      padding: const EdgeInsets.all(DotSpace.l),
      children: [
        _Header(count: open.length),
        const SizedBox(height: DotSpace.m),
        InboxAddField(onSubmit: commands.add),
        const SizedBox(height: DotSpace.m),
        for (final o in open)
          Padding(
            key: ValueKey(o.id),
            padding: const EdgeInsets.only(bottom: DotSpace.s),
            child: _row(context, o, commands),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, Occurrence o, InboxCommands commands) =>
      InboxDraggable(
        item: o,
        child: InboxRow(
          title: o.title,
          meta: formatDurationShort(context.l10n, o.durationMin),
          swipe: false,
          color: TaskColor.fromKey(o.colorKey),
          icon: TaskIcon.fromKey(o.iconKey),
          onSchedule: () => unawaited(commands.schedule(o)),
          onTrash: () => unawaited(commands.trash(o)),
          onOpen: () => ProviderScope.containerOf(
            context,
          ).read(editingTaskProvider.notifier).open(o.id),
        ),
      );
}

/// "Inbox · 4 unscheduled" (`A-mac-week-alt3-board`).
class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(l10n.navInbox, style: t.styles.cardTitle),
          ),
        ),
        Text(l10n.inboxUnscheduledCount(count), style: t.styles.rowMeta),
      ],
    );
  }
}
