import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/now/now_view.dart';
import 'package:dottoday/features/timeline/now/now_actions.dart';
import 'package:dottoday/features/timeline/now/now_rows.dart';
import 'package:dottoday/features/timeline/now/now_states.dart';
import 'package:dottoday/shared/dot/now_orb.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formats a time as the rest of Today does ("10:30 AM").
typedef NowTime = String Function(DateTime utc);

/// What Now shows under the horizon, by [view] (ED-329): the running
/// task's orb, actions, Also now and Next; Next up between tasks; an
/// open day; or Nothing else today. [orbSize] and [aside] are the Mac
/// and web pane's (E-Minimal): the larger orb, Done · Focus · Need more
/// time?, and [aside] (the Add row) beside Also now and Next.
class NowBody extends StatelessWidget {
  const NowBody({
    required this.view,
    required this.nowUtc,
    required this.windDownUtc,
    required this.time,
    this.orbSize,
    this.aside,
    super.key,
  });

  final NowView view;
  final DateTime nowUtc;
  final DateTime windDownUtc;
  final NowTime time;
  final double? orbSize;
  final Widget? aside;

  @override
  Widget build(BuildContext context) => switch (view) {
    NowRunning(:final task, :final alsoNow, :final next, :final later) =>
      _Running(
        task: task,
        alsoNow: alsoNow,
        next: next,
        later: later,
        nowUtc: nowUtc,
        time: time,
        orbSize: orbSize ?? _orb(context),
        aside: aside,
      ),
    NowNextUp(:final next, :final free, :final after, :final earlier) => Column(
      spacing: DotSpace.m,
      children: [
        NowNextUpView(task: next, free: free, time: time),
        const SizedBox(height: DotSpace.l),
        if (after case final a?)
          NowRow(
            label: context.l10n.nowNext,
            task: a,
            time: time(a.startUtc!),
            state: DotState.upcoming,
            onTap: () => openTask(context, a.id),
          ),
        for (final (i, o) in earlier.indexed)
          EarlierRow(task: o, first: i == 0, time: time(o.startUtc!)),
      ],
    ),
    NowOpenDay(:final free) => NowOpenDayView(
      free: free,
      windDown: time(windDownUtc),
      orbSize: orbSize ?? _orb(context),
    ),
    NowNothingElse() => NowQuietView(windDown: time(windDownUtc)),
  };
}

double _orb(BuildContext context) => DotIdiom.of(context) == DotIdiom.material
    ? DotSize.orbAndroid
    : DotSize.orbIphone;

/// The orb's numeral in the locale's own digits.
String nowNumber(BuildContext context, int n) => NumberFormat.decimalPattern(
  Localizations.localeOf(context).toLanguageTag(),
).format(n);

/// A task's start–end, as the rows show it ("10:00 AM–12:00 PM").
String nowRange(NowTime time, Occurrence o) =>
    '${time(o.startUtc!)}–${time(o.endUtc!)}'; // l10n-ignore: a range dash

class _Running extends StatelessWidget {
  const _Running({
    required this.task,
    required this.alsoNow,
    required this.next,
    required this.later,
    required this.nowUtc,
    required this.time,
    required this.orbSize,
    required this.aside,
  });

  final Occurrence task;
  final List<Occurrence> alsoNow;
  final Occurrence? next;
  final int later;
  final DateTime nowUtc;
  final NowTime time;
  final double orbSize;
  final Widget? aside;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final left = task.endUtc!.difference(nowUtc).inMinutes.clamp(0, 9999);
    final gone =
        nowUtc.difference(task.startUtc!).inSeconds / (task.durationMin * 60);
    final hours = left >= 100;
    final minutes = l10n.liveMinutesLeft(left);
    final spoken = '${task.title}, $minutes'; // l10n-ignore: title, phrase
    return Column(
      spacing: DotSpace.m,
      children: [
        // A tap on the orb opens Focus (ED-244).
        Semantics(
          button: true,
          label: spoken,
          hint: l10n.nowFocusHint,
          excludeSemantics: true,
          onTap: () => openFocus(context, task.id),
          child: GestureDetector(
            onTap: () => openFocus(context, task.id),
            child: NowOrb(
              numeral: nowNumber(context, hours ? left ~/ 60 : left),
              unit: hours ? l10n.nowHours : null,
              caption: hours ? l10n.nowOrbHoursCaption : l10n.nowOrbCaption,
              size: orbSize,
              color: TaskColor.fromKey(task.colorKey),
              icon: TaskIcon.fromKey(task.iconKey),
              progress: gone,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: t.styles.emptyTitle,
            ),
            Text(nowRange(time, task), style: t.styles.rowMeta),
          ],
        ),
        NowActions(task: task, wide: aside != null),
        if (aside case final a?)
          Padding(
            padding: const EdgeInsets.only(top: DotSpace.l),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.xl,
              children: [
                Expanded(child: Column(children: _rows(context))),
                Expanded(child: a),
              ],
            ),
          )
        else
          ..._rows(context),
      ],
    );
  }

  List<Widget> _rows(BuildContext context) {
    final l10n = context.l10n;
    return [
      for (final o in alsoNow)
        NowRow(
          label: l10n.nowAlsoNow,
          task: o,
          time: time(o.startUtc!),
          state: DotState.live,
          progress:
              nowUtc.difference(o.startUtc!).inSeconds / (o.durationMin * 60),
          onTap: () => openTask(context, o.id),
        ),
      if (next case final n?)
        NowRow(
          label: l10n.nowNext,
          task: n,
          time: time(n.startUtc!),
          state: DotState.upcoming,
          // "Lunch · 4 more" in the wide pane (E-Minimal).
          more: aside != null && later > 0
              ? l10n.nowMore(nowNumber(context, later))
              : null,
          onTap: () => openTask(context, n.id),
        ),
    ];
  }
}
