import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A suggested place for an inbox task, ready to show.
typedef SlotChoice = ({Slot slot, String label});

/// What the schedule sheet resolved to.
sealed class ScheduleChoice {
  const ScheduleChoice();
}

/// One of the suggested slots.
final class SlotPicked extends ScheduleChoice {
  const SlotPicked(this.choice);

  final SlotChoice choice;
}

/// "Pick a time…": choose on the thread instead.
final class PickTime extends ScheduleChoice {
  const PickTime();
}

/// "Schedule Go for a run": up to two free slots today and the first one
/// tomorrow (docs/02 F3 "smart suggestions"), then "Pick a time…".
Future<ScheduleChoice?> showScheduleSheet(
  BuildContext context, {
  required Occurrence item,
  required DateTime today,
  required String Function(Slot slot) rangeText,
}) => showModalBottomSheet<ScheduleChoice>(
  context: context,
  // Above the iPhone's floating tab bar (M4.9: it covered Save).
  useRootNavigator: true,
  builder: (_) =>
      _ScheduleSheet(item: item, today: today, rangeText: rangeText),
);

class _ScheduleSheet extends ConsumerWidget {
  const _ScheduleSheet({
    required this.item,
    required this.today,
    required this.rangeText,
  });

  final Occurrence item;
  final DateTime today;
  final String Function(Slot slot) rangeText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final now = ref.watch(dayRoomProvider(today)).value;
    final next = ref.watch(dayRoomProvider(tomorrow)).value;
    final choices = <SlotChoice>[
      for (final s in now?.slotsFor(item.durationMin, limit: 2) ?? <Slot>[])
        (slot: s, label: l10n.inboxScheduleToday(rangeText(s))),
      for (final s in next?.slotsFor(item.durationMin) ?? <Slot>[])
        (slot: s, label: l10n.inboxScheduleTomorrow(rangeText(s))),
    ];
    final loading = now == null || next == null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DotSpace.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.page),
              child: Text(
                l10n.inboxScheduleTitle(item.title),
                style: t.styles.cardTitle,
              ),
            ),
            const SizedBox(height: DotSpace.s),
            if (!loading && choices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(DotSpace.page),
                child: Text(l10n.inboxScheduleNone, style: t.styles.body),
              ),
            for (final c in choices)
              ListTile(
                minTileHeight: DotTouch.android,
                leading: DotIcon(DotGlyphs.add, color: t.colors.accentInk),
                title: Text(c.label, style: t.styles.body),
                onTap: () => Navigator.of(context).pop(SlotPicked(c)),
              ),
            ListTile(
              minTileHeight: DotTouch.android,
              leading: DotIcon(DotGlyphs.dottedLine, color: t.colors.accentInk),
              title: Text(l10n.inboxPickTime, style: t.styles.body),
              onTap: () => Navigator.of(context).pop(const PickTime()),
            ),
          ],
        ),
      ),
    );
  }
}
