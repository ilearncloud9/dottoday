import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/scheduling/rebalance.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_parts.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_coach_mark.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// How many dots the card shows after the first (15 §5 step 4).
const _nextDots = 4;

/// A dot this long shows its time range under its title, as the board
/// draws Deep work (E-R2-19-B).
const _rangeFrom = 60;

/// The card's content as your thread (E-R2-19-B, ED-314; states ED-456):
/// full; Minimal (Wake Up and the first dot, the rest behind "Show my
/// day"); low energy (Wake Up and the first dot only, under its chip);
/// an empty day (Wake Up on an open line, Plan today). A late start shows
/// where the dots would move and offers Shift the rest?.
class WakeUpCardBody extends StatefulWidget {
  const WakeUpCardBody({
    required this.model,
    required this.minimal,
    required this.onOpenTask,
    required this.onShift,
    required this.onStart,
    required this.onLater,
    required this.onPlan,
    this.onClose,
    this.onMissionsOff,
    this.coachMark,
    this.inline = false,
    super.key,
  });

  final WakeUpCardModel model;
  final bool minimal;
  final ValueChanged<String> onOpenTask;
  final ValueChanged<int> onShift;
  final VoidCallback onStart;
  final VoidCallback onLater;
  final VoidCallback onPlan;

  /// × beside the greeting; none folded into Now.
  final VoidCallback? onClose;

  /// The once-only offer's answer (15 §8 rule 4): true turns missions off.
  final ValueChanged<bool>? onMissionsOff;

  /// Today's coach mark (15 §11): the first-morning line above Start.
  final HintId? coachMark;

  /// Folded into Minimal's Now (E-R2-26 frame 4): it doesn't scroll by
  /// itself, and "Show my day" gives way to the horizon above it.
  final bool inline;

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
    final late = first == null || m.lowEnergy ? null : m.lateMin;
    final top = [
      WakeUpCardHeader(
        title: context.l10n.wakeUpCardGreeting(
          DateFormat.MMMMEEEEd(_locale(context)).format(m.data.day.date),
        ),
        meta: first == null
            ? context.l10n.wakeUpCardEmpty
            : context.l10n.wakeUpCardPlanned(
                m.ahead.length,
                _time(context, m.ahead.last.endUtc!),
              ),
        onClose: widget.onClose,
      ),
      if (m.lowEnergy)
        WakeUpChips(chips: [(TaskIcon.leaf.glyph!, context.l10n.lowEnergyOn)]),
      WakeUpThread(
        openEnd: !whole || first == null,
        rows: _rows(context, tasks, whole: whole, late: late),
      ),
      if (whole || first == null) ..._chips(context),
      if (m.offerMissionsOff && widget.onMissionsOff != null)
        _MissionsOffOffer(onAnswer: widget.onMissionsOff!),
      if (late != null) WakeUpShiftRow(onShift: () => widget.onShift(late)),
    ];
    final bottom = _bottom(context, first: first != null);
    final gap = const SizedBox(height: DotSpace.l);
    if (widget.inline) {
      return Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.l,
          children: [...top, bottom],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(DotSpace.l),
            itemCount: top.length,
            separatorBuilder: (_, _) => gap,
            itemBuilder: (_, i) => top[i],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DotSpace.l,
            0,
            DotSpace.l,
            DotSpace.l,
          ),
          child: bottom,
        ),
      ],
    );
  }

  List<Widget> _rows(
    BuildContext context,
    List<ThreadTask> tasks, {
    required bool whole,
    required int? late,
  }) {
    final m = widget.model;
    final l10n = context.l10n;
    final moved = late == null ? const <String, DateTime>{} : _moves(late);
    String? movedText(ThreadTask task) => switch (moved[task.id]) {
      final at? => l10n.wakeUpCardMovedTo(_time(context, at)),
      null => null,
    };
    WakeUpThreadRow row(ThreadTask task, {bool first = false}) {
      final step = first ? m.steps[task.id] : null;
      return WakeUpThreadRow(
        time: _time(context, task.startUtc!),
        mark: wakeUpTaskDot(task, first: first),
        title: task.title,
        sub: first || task.minutes >= _rangeFrom
            ? switch (task.duration) {
                final d? when first => l10n.statusHintJoin(task.timeRange, d),
                _ => task.timeRange,
              }
            : null,
        moved: movedText(task),
        step: step == null
            ? null
            : WakeUpStep(
                color: task.color,
                text: switch (step.durationMin) {
                  final min? => l10n.wakeUpCardFirstStep(
                    step.title,
                    formatDurationShort(l10n, min),
                  ),
                  null => l10n.wakeUpCardFirstStepShort(step.title),
                },
              ),
        onTap: () => widget.onOpenTask(task.id),
        // One sentence for screen readers: the dot's own label would say
        // the title twice.
        semanticLabel: [
          l10n.rowLabel(task.title, task.timeRange),
          ?movedText(task),
        ].reduce(l10n.statusHintJoin),
      );
    }

    return [
      WakeUpThreadRow(
        time: _time(context, late == null ? m.shape.wakeUtc : m.upUtc),
        mark: const WakeUpSun(),
        title: l10n.settingsWakeUp,
        sub: late == null ? null : l10n.wakeUpCardLate(late),
      ),
      if (tasks.firstOrNull case final first?) row(first, first: true),
      if (whole)
        for (final task in tasks.skip(1).take(_nextDots)) row(task),
      if (m.oneThingInbox case final o? when !m.lowEnergy)
        WakeUpOneThing(occurrence: o, onOpen: () => widget.onOpenTask(o.id)),
    ];
  }

  /// Where Shift the rest? would move each dot: the same Rebalance its
  /// sheet proposes, read here only; nothing is written before Accept.
  Map<String, DateTime> _moves(int late) {
    final m = widget.model;
    final plan = rebalance(
      m.data.blocks,
      fromUtc: m.nowUtc,
      deltaMin: late,
      bedUtc: m.shape.bedUtc,
    );
    return {
      for (final MapEntry(:key, :value) in plan.changed.entries)
        key: ?value.startUtc,
    };
  }

  Widget _bottom(BuildContext context, {required bool first}) {
    final l10n = context.l10n;
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xs,
      children: [
        if (first && widget.coachMark == HintId.wakeUpStartDay)
          const WakeUpCoachMark(HintId.wakeUpStartDay),
        if (widget.minimal &&
            !widget.inline &&
            !_showDay &&
            !widget.model.lowEnergy &&
            first)
          TextButton(
            onPressed: () => setState(() => _showDay = true),
            child: Text(l10n.wakeUpCardShowDay),
          ),
        FilledButton(
          onPressed: first ? widget.onStart : widget.onPlan,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(DotTouch.min + DotSpace.m),
            textStyle: t.styles.primaryButton,
          ),
          child: Text(first ? l10n.wakeUpCardStart : l10n.wakeUpCardPlan),
        ),
        TextButton(
          onPressed: widget.onLater,
          child: Text(l10n.wakeUpCardLater),
        ),
      ],
    );
  }

  List<Widget> _chips(BuildContext context) {
    final m = widget.model;
    final l10n = context.l10n;
    final chips = [
      if (m.settings.wakeUpCardCalendar && m.calendar.isNotEmpty)
        (DotGlyphs.calendar, l10n.wakeUpCardCalendar(m.calendar.length)),
      if (m.settings.wakeUpCardInbox && m.inbox > 0)
        (DotGlyphs.inbox, l10n.wakeUpCardInbox(m.inbox)),
    ];
    return chips.isEmpty ? const [] : [WakeUpChips(chips: chips)];
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
      oneThingId: oneThingOn(m.settings.oneThing, m.dateKey),
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

/// "Missions seem to get in the way lately. Turn them off?" (15 §8 rule
/// 4): asked once; the app never turns them off by itself.
class _MissionsOffOffer extends StatelessWidget {
  const _MissionsOffOffer({required this.onAnswer});

  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.missionOffOffer, style: t.styles.body),
        Wrap(
          spacing: DotSpace.s,
          children: [
            TextButton(
              onPressed: () => onAnswer(true),
              child: Text(l10n.missionOffOfferTurnOff),
            ),
            TextButton(
              onPressed: () => onAnswer(false),
              child: Text(l10n.missionOffOfferKeep),
            ),
          ],
        ),
      ],
    );
  }
}
