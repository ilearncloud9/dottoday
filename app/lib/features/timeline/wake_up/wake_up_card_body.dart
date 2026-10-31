import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_parts.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// How many dots the card shows after the first (15 §5 step 4).
const _nextDots = 4;

/// The card's content (docs/15 §5, §10): full, minimal (the first dot and
/// Start, the rest behind "Show my day"), low energy (the first dot and
/// Start only) and an empty day ("Nothing planned yet", Plan today).
class WakeUpCardBody extends StatefulWidget {
  const WakeUpCardBody({
    required this.model,
    required this.minimal,
    required this.onOpenTask,
    required this.onShift,
    required this.onStart,
    required this.onLater,
    required this.onPlan,
    super.key,
  });

  final WakeUpCardModel model;
  final bool minimal;
  final ValueChanged<String> onOpenTask;
  final ValueChanged<int> onShift;
  final VoidCallback onStart;
  final VoidCallback onLater;
  final VoidCallback onPlan;

  @override
  State<WakeUpCardBody> createState() => _WakeUpCardBodyState();
}

class _WakeUpCardBodyState extends State<WakeUpCardBody> {
  /// Minimal mode's "Show my day", for this visit.
  var _showDay = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    final tasks = _tasks(context);
    final first = tasks.firstOrNull;
    final whole = !m.lowEnergy && (!widget.minimal || _showDay);
    final late = m.lateMin;
    return ListView(
      padding: const EdgeInsets.all(DotSpace.l),
      children: [
        WakeUpGreeting(
          date: DateFormat.MMMMEEEEd(_locale(context)).format(m.data.day.date),
          planned: m.ahead.length,
          ends: _time(context, m.ahead.lastOrNull?.endUtc ?? m.shape.bedUtc),
          showDot: whole,
        ),
        const SizedBox(height: DotSpace.l),
        if (first == null)
          ..._empty(context)
        else ...[
          WakeUpFirstDot(
            task: first,
            step: m.steps[first.id],
            onOpen: () => widget.onOpenTask(first.id),
          ),
          if (whole && tasks.length > 1) ...[
            const SizedBox(height: DotSpace.l),
            WakeUpNextDots(
              tasks: tasks.skip(1).take(_nextDots).toList(),
              onOpen: widget.onOpenTask,
            ),
          ],
        ],
        if (whole) ..._chips(context),
        if (late != null && first != null && !m.lowEnergy) ...[
          const SizedBox(height: DotSpace.l),
          WakeUpLateLine(minutes: late, onShift: () => widget.onShift(late)),
        ],
        if (widget.minimal && !_showDay && !m.lowEnergy && first != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => setState(() => _showDay = true),
              child: Text(context.l10n.wakeUpCardShowDay),
            ),
          ),
        const SizedBox(height: DotSpace.xl),
        if (first != null)
          FilledButton(
            onPressed: widget.onStart,
            child: Text(context.l10n.wakeUpCardStart),
          ),
        TextButton(
          onPressed: widget.onLater,
          child: Text(context.l10n.wakeUpCardLater),
        ),
      ],
    );
  }

  List<Widget> _empty(BuildContext context) => [
    Text(
      context.l10n.wakeUpCardEmpty,
      style: DotTheme.of(context).styles.cardTitle,
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: DotSpace.m),
    FilledButton(
      onPressed: widget.onPlan,
      child: Text(context.l10n.wakeUpCardPlan),
    ),
  ];

  List<Widget> _chips(BuildContext context) {
    final m = widget.model;
    final l10n = context.l10n;
    final lines = [
      if (m.settings.wakeUpCardCalendar && m.calendar.isNotEmpty)
        (DotGlyphs.calendar, l10n.wakeUpCardCalendar(m.calendar.length)),
      if (m.settings.wakeUpCardInbox && m.inbox > 0)
        (DotGlyphs.inbox, l10n.wakeUpCardInbox(m.inbox)),
    ];
    if (lines.isEmpty) return const [];
    return [const SizedBox(height: DotSpace.l), WakeUpChips(lines: lines)];
  }

  /// The dots ahead as Today draws them (same states, times and icons).
  List<ThreadTask> _tasks(BuildContext context) {
    final m = widget.model;
    final ids = {for (final o in m.ahead) o.id};
    final entries = threadEntries(
      blocks: m.ahead,
      shape: m.shape,
      nowUtc: m.nowUtc,
      format: ThreadFormat(
        time: (utc) => _time(context, utc),
        range: context.l10n.threadTimeRange,
        duration: (min) => formatDurationShort(context.l10n, min),
      ),
    );
    return [
      for (final e in entries)
        if (e is ThreadTaskEntry && ids.contains(e.task.id)) e.task,
      for (final e in entries)
        if (e is ThreadOutside)
          for (final task in e.tasks)
            if (ids.contains(task.id)) task,
    ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  }

  String _time(BuildContext context, DateTime utc) => timeOfUtc(
    context,
    widget.model.data.day.location,
    utc,
    use24h: use24hFor(context, widget.model.settings.use24h),
  );

  String _locale(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();
}
