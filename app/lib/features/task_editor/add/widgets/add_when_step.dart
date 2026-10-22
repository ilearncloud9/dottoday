import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_when_parts.dart';
import 'package:dottoday/shared/dot/picker_caption.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_picker.dart';
import 'package:dottoday/shared/dot/thread_picker_blocks.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// Add step 2 "When" (docs/10 §5.2 A2, `A-ios-add-when`): the task, the
/// `ThreadPicker` with its free / overlap caption, duration chips, "Lands
/// on …", and Add / Add another.
class AddWhenStep extends StatelessWidget {
  const AddWhenStep({
    required this.state,
    required this.room,
    required this.presets,
    required this.use24h,
    required this.snapMinutes,
    required this.onStart,
    required this.onDuration,
    required this.onAdd,
    required this.onAnother,
    this.onEditDay,
    this.timeMenu,
    this.durationMenu,
    super.key,
  });

  final AddFlowState state;

  /// The draft's day: its tasks, Wake Up and Bedtime.
  final DayRoom room;
  final List<int> presets;
  final bool use24h;
  final int snapMinutes;
  final ValueChanged<int> onStart;
  final ValueChanged<int> onDuration;
  final VoidCallback onAdd;
  final VoidCallback onAnother;

  /// "Edit" on the Lands-on row: change the day.
  final VoidCallback? onEditDay;

  /// The ⋯ beside TIME (M3c.4) and DURATION (M3c.3).
  final Widget? timeMenu;
  final Widget? durationMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _fields(context)),
        _Footer(onAdd: onAdd, onAnother: onAnother),
      ],
    );
  }

  Widget _fields(BuildContext context) {
    final draft = state.draft;
    final zone = tz.getLocation(draft.tzId);
    final l10n = context.l10n;
    // All-day items take no time on the thread (the all-day strip).
    final range = draft.allDay
        ? l10n.addAllDay
        : DayTimeText(
            context,
            zone,
            draft.day,
            use24h: use24h,
          ).range(draft.startMinute ?? 0, draft.length);
    final fit = draft.allDay
        ? SlotFit(overlaps: const [], freeUntilUtc: room.endUtc)
        : fitAt(
            room.blocks,
            draft.startUtc!,
            draft.length,
            dayEndUtc: room.endUtc,
          );
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.page,
        vertical: DotSpace.l,
      ),
      children: [
        _identity(context, range),
        const SizedBox(height: DotSpace.xl),
        AddCaption(l10n.addTimeCaption, trailing: timeMenu),
        const SizedBox(height: DotSpace.s),
        if (!draft.allDay) ...[
          ..._time(context, zone, fit),
          const SizedBox(height: DotSpace.xl),
          AddCaption(l10n.addDurationCaption, trailing: durationMenu),
          const SizedBox(height: DotSpace.s),
          DurationRow(
            presets: presets,
            value: draft.length,
            onChanged: onDuration,
          ),
          const SizedBox(height: DotSpace.l),
        ],
        LandsOn(
          colour: TaskColor.fromKey(draft.color),
          day: relativeDayName(context, draft.day, draft.today),
          range: range,
          fit: fit,
          onEdit: onEditDay,
          allDay: draft.allDay,
        ),
      ],
    );
  }

  /// The picker and its free / overlap caption.
  List<Widget> _time(BuildContext context, tz.Location zone, SlotFit fit) {
    final text = DayTimeText(context, zone, state.draft.day, use24h: use24h);
    return [
      _picker(text, zone),
      const SizedBox(height: DotSpace.m),
      PickerCaption(
        freeUntil: text.utc(fit.freeUntilUtc),
        overlapTitle: fit.overlaps.firstOrNull?.title,
        overlapCount: fit.overlaps.length,
      ),
    ];
  }

  Widget _identity(BuildContext context, String range) {
    final t = DotTheme.of(context);
    final draft = state.draft;
    final l10n = context.l10n;
    final title = draft.title.isEmpty ? l10n.inboxUntitled : draft.title;
    return Row(
      spacing: DotSpace.l,
      children: [
        TaskDot(
          color: TaskColor.fromKey(draft.color),
          icon: TaskIcon.fromKey(draft.icon),
          state: DotState.upcoming,
          label: title,
          size: DotSize.dayDot,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.styles.topBarTitle),
              Text(
                draft.allDay
                    ? l10n.alertJoin(
                        relativeDayName(context, draft.day, draft.today),
                        range,
                      )
                    : l10n.addWhenSummary(
                        relativeDayName(context, draft.day, draft.today),
                        range,
                        formatDurationShort(l10n, draft.length),
                      ),
                style: t.styles.body.copyWith(color: t.colors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _picker(DayTimeText text, tz.Location zone) {
    final draft = state.draft;
    return ThreadPicker(
      blocks: pickerBlocks(room.blocks, zone, draft.day),
      startMinute: draft.startMinute ?? 0,
      durationMin: draft.length,
      color: TaskColor.fromKey(draft.color),
      icon: TaskIcon.fromKey(draft.icon),
      rangeText: (m) => text.range(m, draft.length),
      hourText: text.hour,
      bedMinute: ClockTime.ofUtc(zone, room.endUtc).minutesOfDay,
      bedText: text.bed(room.endUtc),
      snapMinutes: snapMinutes,
      onChanged: onStart,
    );
  }
}

/// "+ Add" and "Add another", pinned under the fields.
class _Footer extends StatelessWidget {
  const _Footer({required this.onAdd, required this.onAnother});

  final VoidCallback onAdd;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.page,
        DotSpace.l,
      ),
      child: Row(
        spacing: DotSpace.m,
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: DotIcon(DotGlyphs.add, color: t.colors.onAccent),
              label: Text(l10n.addAdd),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: onAnother,
              child: Text(l10n.addAnother),
            ),
          ),
        ],
      ),
    );
  }
}
