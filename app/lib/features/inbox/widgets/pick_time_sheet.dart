import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/inbox/widgets/schedule_sheet.dart';
import 'package:dottoday/shared/dot/picker_caption.dart';
import 'package:dottoday/shared/dot/thread_picker.dart';
import 'package:dottoday/shared/dot/thread_picker_blocks.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// "Pick a time…" for an inbox task (deferred from M3b.8 to M3c.2): today
/// or tomorrow on the `ThreadPicker`, with the free / overlap caption,
/// then Place.
Future<SlotChoice?> showPickTimeSheet(
  BuildContext context, {
  required Occurrence item,
  required DateTime today,
  required String Function(Slot slot) rangeText,
}) => showAppSheet<SlotChoice>(
  context: context,
  title: context.l10n.inboxScheduleTitle(item.title),
  builder: (_) => _PickTime(item: item, today: today, rangeText: rangeText),
);

class _PickTime extends ConsumerStatefulWidget {
  const _PickTime({
    required this.item,
    required this.today,
    required this.rangeText,
  });

  final Occurrence item;
  final DateTime today;
  final String Function(Slot slot) rangeText;

  @override
  ConsumerState<_PickTime> createState() => _PickTimeState();
}

/// A leaf: holds only the day and minute being picked.
class _PickTimeState extends ConsumerState<_PickTime> {
  late DateTime _day = widget.today;
  int? _minute;

  DateTime get _tomorrow =>
      DateTime(widget.today.year, widget.today.month, widget.today.day + 1);

  /// The first free slot, else Wake Up (or now, if later).
  int _initial(DayRoom room, tz.Location zone) {
    final slot = room.slotsFor(widget.item.durationMin).firstOrNull;
    final from =
        slot?.startUtc ??
        (room.fromUtc.isAfter(room.startUtc) ? room.fromUtc : room.startUtc);
    return ClockTime.ofUtc(zone, from).minutesOfDay;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    final room = ref.watch(dayRoomProvider(_day)).value;
    if (profile == null || room == null) {
      return const SizedBox(height: pickerHeight);
    }
    final zone = tz.getLocation(profile.tzId);
    final minute = _minute ??= _initial(room, zone);
    final length = widget.item.durationMin;
    final text = DayTimeText(
      context,
      zone,
      _day,
      use24h: use24hFor(context, profile.settings.use24h),
    );
    final start = ClockTime.fromMinutes(minute).onDate(zone, _day);
    final fit = fitAt(room.blocks, start, length, dayEndUtc: room.endUtc);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        _days(context),
        _picker(room, zone, text, minute, profile.settings.snapMinutes),
        PickerCaption(
          freeUntil: text.utc(fit.freeUntilUtc),
          color: TaskColor.fromKey(widget.item.colorKey),
          overlapTitle: fit.overlaps.firstOrNull?.title,
          overlapColor: switch (fit.overlaps.firstOrNull) {
            final o? => TaskColor.fromKey(o.colorKey),
            null => null,
          },
          overlapCount: fit.overlaps.length,
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_choice(start, length)),
          child: Text(context.l10n.inboxPlace),
        ),
      ],
    );
  }

  Widget _picker(
    DayRoom room,
    tz.Location zone,
    DayTimeText text,
    int minute,
    int snap,
  ) {
    final length = widget.item.durationMin;
    return ThreadPicker(
      blocks: pickerBlocks(room.blocks, zone, _day),
      startMinute: minute,
      durationMin: length,
      color: TaskColor.fromKey(widget.item.colorKey),
      icon: TaskIcon.fromKey(widget.item.iconKey),
      rangeText: (m) => text.range(m, length),
      hourText: text.hour,
      bedMinute: ClockTime.ofUtc(zone, room.endUtc).minutesOfDay,
      bedText: text.bed(room.endUtc),
      snapMinutes: snap,
      onChanged: (m) => setState(() => _minute = m),
    );
  }

  SlotChoice _choice(DateTime start, int length) {
    final slot = Slot(start, start.add(Duration(minutes: length)));
    final l10n = context.l10n;
    final range = widget.rangeText(slot);
    return (
      slot: slot,
      label: _day == widget.today
          ? l10n.inboxScheduleToday(range)
          : l10n.inboxScheduleTomorrow(range),
    );
  }

  Widget _days(BuildContext context) {
    final l10n = context.l10n;
    Widget chip(DateTime day, String label) => ChoiceChip(
      label: Text(label),
      selected: _day == day,
      shape: dotChipShape(context),
      onSelected: (_) => setState(() {
        _day = day;
        _minute = null;
      }),
    );
    return Wrap(
      spacing: DotSpace.s,
      children: [
        chip(widget.today, l10n.sheetToday),
        chip(_tomorrow, l10n.sheetTomorrow),
      ],
    );
  }
}
