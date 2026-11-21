import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/drop_today_panel.dart';
import 'package:dottoday/features/inbox/widgets/inbox_body.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/features/inbox/widgets/inbox_fit.dart';
import 'package:dottoday/features/inbox/widgets/inbox_selection_bar.dart';
import 'package:dottoday/features/inbox/widgets/inbox_task_row.dart';
import 'package:dottoday/features/inbox/widgets/wide_inbox.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Inbox (E-R2-13, ED-295): what has no time yet, a quick-add field,
/// filters and Sort, the next free slot, each task with where it fits and
/// Place, and what is already done. Minimal (docs/14 §3 `inboxExtras` Hidden) draws
/// the list with the next free slot, swipe and Place only, at every width.
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
    final extras = watchOnScreen(ref, FeatureId.inboxExtras);
    final rooms = ref.watch(inboxWeekRoomsProvider(today)).value;
    final rows = InboxRowContext(
      commands: commands,
      fits: InboxFitText(
        context,
        today: today,
        timeText: time,
        rangeText: commands.rangeText,
      ),
      zone: zone,
      weekKnown: rooms != null,
      oneThingId: ref.watch(todayOneThingIdProvider),
    );
    final narrow = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: InboxBody(
          items: items,
          room: room,
          rooms: rooms,
          extras: extras,
          rows: rows,
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
              extras &&
                  AppLayout.classOf(context, width: box.maxWidth) ==
                      WidthClass.expanded
              ? _wide(context, ref, items, rooms, zone, time, rows)
              : narrow,
        ),
      ),
    );
  }

  /// Mac/web and expanded tablets (M3e.2, E-R2-13): the list with fits
  /// beside "Drop onto today".
  Widget _wide(
    BuildContext context,
    WidgetRef ref,
    List<Occurrence> items,
    List<DayRoom>? rooms,
    tz.Location zone,
    String Function(DateTime utc) time,
    InboxRowContext rows,
  ) {
    final l10n = context.l10n;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    return WideInbox(
      items: items,
      rooms: rooms,
      rows: rows,
      panel: (shown) => rooms == null
          ? const SizedBox.shrink()
          : DropTodayPanel(
              room: rooms.first,
              items: shown,
              zone: zone,
              nowUtc: now,
              commands: rows.commands,
              format: ThreadFormat(
                time: time,
                range: l10n.threadTimeRange,
                duration: (m) => formatDurationShort(l10n, m),
              ),
            ),
    );
  }
}
