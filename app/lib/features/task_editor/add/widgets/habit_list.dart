import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// "SUGGESTIONS · from your habits" (`A-ios-add-what`): habits matching
/// the title; tapping one takes its title, time, length, colour and icon.
/// The one the title names is ticked.
class HabitList extends StatelessWidget {
  const HabitList({
    required this.habits,
    required this.selected,
    required this.use24h,
    required this.onPick,
    super.key,
  });

  final List<HabitSuggestion> habits;
  final HabitSuggestion? selected;
  final bool use24h;
  final ValueChanged<HabitSuggestion> onPick;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        const _Caption(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.colors.raised,
            borderRadius: BorderRadius.circular(DotRadii.card),
            border: Border.all(color: t.colors.outline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DotRadii.card),
            child: Column(
              children: [
                for (final (i, h) in habits.indexed) ...[
                  if (i > 0) Divider(height: 1, color: t.colors.outline),
                  _HabitRow(
                    habit: h,
                    selected: identical(h, selected),
                    meta: habitMeta(context, h, use24h: use24h),
                    onTap: () => onPick(h),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "SUGGESTIONS" with "from your habits" at the end.
class _Caption extends StatelessWidget {
  const _Caption();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    // Wraps at large text sizes instead of overflowing (§5.4, 200 %).
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DotSpace.s,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.addSuggestions.toUpperCase(),
            style: t.styles.caption,
          ),
        ),
        Text(l10n.addFromHabits, style: t.styles.rowMeta),
      ],
    );
  }
}

/// "usually 5:00 – 6:00 PM · 1 h", or "no set time · 1 h".
String habitMeta(
  BuildContext context,
  HabitSuggestion h, {
  required bool use24h,
}) {
  final l10n = context.l10n;
  final length = formatDurationShort(l10n, h.durationMin);
  final start = h.minuteOfDay;
  if (start == null) return l10n.addHabitNoTime(length);
  String at(int minutes) {
    final m = minutes % Duration.minutesPerDay;
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: m ~/ 60, minute: m % 60),
      alwaysUse24HourFormat: use24h,
    );
  }

  final range = l10n.threadTimeRange(at(start), at(start + h.durationMin));
  return l10n.addHabitUsual(range, length);
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.habit,
    required this.selected,
    required this.meta,
    required this.onTap,
  });

  final HabitSuggestion habit;
  final bool selected;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final colour = TaskColor.fromKey(habit.colorKey);
    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.addHabitLabel(habit.title, meta),
      excludeSemantics: true,
      child: Material(
        color: selected ? t.colors.accentTint : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DotSpace.l,
              vertical: DotSpace.m,
            ),
            child: _content(t, colour),
          ),
        ),
      ),
    );
  }

  Widget _content(DotTheme t, TaskColor colour) => Row(
    spacing: DotSpace.m,
    children: [
      TaskDot(
        color: colour,
        icon: TaskIcon.fromKey(habit.iconKey),
        state: DotState.upcoming,
        label: habit.title,
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habit.title, style: t.styles.rowTitle),
            Text(meta, style: t.styles.rowMeta),
          ],
        ),
      ),
      _MiniThread(colour: colour),
      SizedBox.square(
        dimension: DotSize.liveDot - DotSpace.s,
        child: selected ? const _Tick() : null,
      ),
    ],
  );
}

/// A sliver of thread with the habit's segment on it (decorative).
class _MiniThread extends StatelessWidget {
  const _MiniThread({required this.colour});

  final TaskColor colour;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    Widget dots() => Column(
      spacing: DotSpace.xxs,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: DotSize.freeLine,
            height: DotSize.freeLine,
            color: t.colors.hairline,
          ),
      ],
    );
    return ExcludeSemantics(
      child: Column(
        spacing: DotSpace.xxs,
        children: [
          dots(),
          Container(
            width: DotSize.segment,
            height: DotSpace.l + DotSpace.xs,
            decoration: BoxDecoration(
              color: t.tasks[colour].color,
              borderRadius: BorderRadius.circular(DotRadii.pill),
            ),
          ),
          dots(),
        ],
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick();

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, color: c.accentFill),
      child: Center(
        child: DotIcon(
          DotGlyphs.check,
          color: c.onAccent,
          size: DotSize.rowIcon,
          active: true,
        ),
      ),
    );
  }
}
