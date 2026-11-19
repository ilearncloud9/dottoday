import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/schedule/planned_colors.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/pickers/when/when_bar_card.dart';
import 'package:dottoday/shared/pickers/when/when_parts.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// What the When picker is placing [task] for (ED-099).
enum WhenMode {
  /// Move: the task is on a day; it keeps its length.
  move,

  /// Schedule: an Inbox task gets a day and time.
  schedule,
}

/// The one When picker (G2-12 Q2, ED-099; M19.4 part 4b) for Inbox
/// Schedule, Move and Move To…: free-time suggestions first (Place), then
/// day chips (Today, Tomorrow, the next two days, Date…) and the day bar
/// for the exact time, then "Move to 4:30 PM" / "Place at 4:30 PM". A sheet
/// on phones; from medium width a popover from [anchor] with a typed time
/// field too. Returns the picked start, or null; nothing is written here.
Future<DateTime?> showWhenPicker(
  BuildContext context, {
  required Occurrence task,
  required WhenMode mode,
  required DateTime today,
  Rect? anchor,
}) {
  final body = WhenPicker(task: task, mode: mode, today: today);
  if (AppLayout.classOf(context) == WidthClass.compact) {
    return showModalBottomSheet<DateTime>(
      context: context,
      // Above the iPhone's floating tab bar (M4.9).
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => body,
    );
  }
  return showAnchoredPopover<DateTime>(
    context: context,
    anchor: anchor,
    width: DotSize.addPopover,
    builder: (_) => body,
  );
}

/// The picker's body: the sheet's and the popover's.
class WhenPicker extends ConsumerStatefulWidget {
  const WhenPicker({
    required this.task,
    required this.mode,
    required this.today,
    super.key,
  });

  final Occurrence task;
  final WhenMode mode;
  final DateTime today;

  @override
  ConsumerState<WhenPicker> createState() => _WhenPickerState();
}

/// A leaf: the day and minute being picked.
class _WhenPickerState extends ConsumerState<WhenPicker> {
  late DateTime _day = _taskDay ?? widget.today;
  int? _minute;

  Occurrence get _task => widget.task;
  int get _length => _task.durationMin;

  /// The task's own day, when it has one (Move).
  DateTime? get _taskDay {
    final start = _task.startUtc;
    if (start == null) return null;
    final l = tz.TZDateTime.from(start, tz.getLocation(_task.tzId));
    return DateTime(l.year, l.month, l.day);
  }

  /// The day as the task would find it: its own time free (Move).
  DayRoom? _room(DateTime day) =>
      ref.watch(dayRoomProvider(day)).value?.without(_task.id);

  /// Where the ring starts: Move keeps the task's own time on any day
  /// (docs/03 §3.2 "same times"); Schedule starts at the first free slot,
  /// else Wake Up (or now, if later).
  int _initial(DayRoom room, tz.Location zone) {
    final start = _task.startUtc;
    if (start != null && widget.mode == WhenMode.move) {
      return ClockTime.ofUtc(zone, start).minutesOfDay;
    }
    final slot = room.slotsFor(_length).firstOrNull;
    final from =
        slot?.startUtc ??
        (room.fromUtc.isAfter(room.startUtc) ? room.fromUtc : room.startUtc);
    return ClockTime.ofUtc(zone, from).minutesOfDay;
  }

  void _pick(DateTime day) => setState(() {
    _day = day;
    _minute = null;
  });

  Future<void> _date() async {
    final container = ProviderScope.containerOf(context);
    final picked = await showMonthDayPicker(
      context,
      initial: _day,
      today: widget.today,
      firstDayOfWeek:
          ref.read(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1,
      plannedFor: (m) => plannedColors(container, m),
    );
    if (picked != null && mounted) _pick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    final room = _room(_day);
    if (profile == null || room == null) {
      return const SizedBox(height: DotSize.dayBar * 4);
    }
    final zone = tz.getLocation(profile.tzId);
    final text = DayTimeText(
      context,
      zone,
      _day,
      use24h: use24hFor(context, profile.settings.use24h),
    );
    final minute = _minute ??= _initial(room, zone);
    final start = ClockTime.fromMinutes(minute).onDate(zone, _day);
    void place() => Navigator.of(context).pop(start);
    // The Mac and a mouse-driven browser: a typed time and ↵ (ED-099).
    final pointer = !watchTouchContent(context, ref);
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.enter): place},
      // Focus starts in the picker, so ↵ places and the arrows reach the
      // bar once it is focused (ED-099 "Return places; Esc closes").
      child: Focus(
        autofocus: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            DotSpace.page,
            0,
            DotSpace.page,
            DotSpace.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.m,
            children: [
              WhenHeader(task: _task, mode: widget.mode, today: widget.today),
              WhenSuggestions(
                today: widget.today,
                rooms: (_room(widget.today), _room(_tomorrow)),
                length: _length,
                zone: zone,
                use24h: use24hFor(context, profile.settings.use24h),
                onPlace: (s) => Navigator.of(context).pop(s),
              ),
              WhenDays(
                today: widget.today,
                day: _day,
                onDay: _pick,
                onDate: () => unawaited(_date()),
              ),
              WhenBarCard(
                room: room,
                zone: zone,
                day: _day,
                text: text,
                task: _task,
                minute: minute,
                typed: pointer,
                onMinute: (m) => setState(() => _minute = m),
              ),
              WhenButton(
                label: widget.mode == WhenMode.move
                    ? context.l10n.whenMoveTo(text.at(minute))
                    : context.l10n.whenPlaceAt(text.at(minute)),
                keyCap: pointer,
                onPressed: place,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime get _tomorrow =>
      DateTime(widget.today.year, widget.today.month, widget.today.day + 1);
}
