import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/now/now_view.dart';
import 'package:dottoday/features/timeline/now/now_actions.dart';
import 'package:dottoday/features/timeline/now/now_rows.dart';
import 'package:dottoday/shared/dot/now_orb.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formats a time as the rest of Today does ("10:30 AM").
typedef NowTime = String Function(DateTime utc);

/// What Now shows under the horizon, by [view] (ED-329): the running
/// task's orb, actions, Also now and Next; Next up between tasks; an
/// open day; or Nothing else today.
class NowBody extends StatelessWidget {
  const NowBody({
    required this.view,
    required this.nowUtc,
    required this.windDownUtc,
    required this.time,
    super.key,
  });

  final NowView view;
  final DateTime nowUtc;
  final DateTime windDownUtc;
  final NowTime time;

  @override
  Widget build(BuildContext context) => switch (view) {
    NowRunning(:final task, :final alsoNow, :final next) => _Running(
      task: task,
      alsoNow: alsoNow,
      next: next,
      nowUtc: nowUtc,
      time: time,
    ),
    NowNextUp(:final next, :final free, :final after, :final earlier) => Column(
      spacing: DotSpace.m,
      children: [
        _NextUp(task: next, free: free, time: time),
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
    NowOpenDay(:final free) => _OpenDay(
      free: free,
      windDown: time(windDownUtc),
    ),
    NowNothingElse() => _Quiet(windDown: time(windDownUtc)),
  };
}

double _orb(BuildContext context) => DotIdiom.of(context) == DotIdiom.material
    ? DotSize.orbAndroid
    : DotSize.orbIphone;

/// The orb's numeral in the locale's own digits.
String _n(BuildContext context, int n) => NumberFormat.decimalPattern(
  Localizations.localeOf(context).toLanguageTag(),
).format(n);

String _range(NowTime time, Occurrence o) =>
    '${time(o.startUtc!)}–${time(o.endUtc!)}'; // l10n-ignore: a range dash

class _Running extends StatelessWidget {
  const _Running({
    required this.task,
    required this.alsoNow,
    required this.next,
    required this.nowUtc,
    required this.time,
  });

  final Occurrence task;
  final List<Occurrence> alsoNow;
  final Occurrence? next;
  final DateTime nowUtc;
  final NowTime time;

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
              numeral: _n(context, hours ? left ~/ 60 : left),
              unit: hours ? l10n.nowHours : null,
              caption: hours ? l10n.nowOrbHoursCaption : l10n.nowOrbCaption,
              size: _orb(context),
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
            Text(_range(time, task), style: t.styles.rowMeta),
          ],
        ),
        NowActions(task: task),
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
            onTap: () => openTask(context, n.id),
          ),
      ],
    );
  }
}

class _NextUp extends StatelessWidget {
  const _NextUp({required this.task, required this.free, required this.time});

  final Occurrence task;
  final Duration free;
  final NowTime time;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return MergeSemantics(
      child: InkWell(
        onTap: () => openTask(context, task.id),
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: Column(
          spacing: DotSpace.xs,
          children: [
            NextUpRing(task: task),
            const SizedBox(height: DotSpace.s),
            Text(
              l10n.widgetNextUp.toUpperCase(),
              style: t.styles.caption.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: t.styles.emptyTitle,
            ),
            Text(_range(time, task), style: t.styles.rowMeta),
            Text(
              l10n.threadFree(formatDurationShort(l10n, free.inMinutes)),
              style: t.styles.rowMeta.copyWith(
                color: t.colors.accentInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenDay extends StatelessWidget {
  const _OpenDay({required this.free, required this.windDown});

  final Duration free;
  final String windDown;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      spacing: DotSpace.m,
      children: [
        NowOrb(
          numeral: _n(context, free.inHours),
          unit: l10n.nowHours,
          caption: l10n.nowOrbFree,
          size: _orb(context),
        ),
        Column(
          children: [
            Text(l10n.nowOpenDay, style: t.styles.emptyTitle),
            Text(l10n.nowFreeUntil(windDown), style: t.styles.rowMeta),
          ],
        ),
        FilledButton.icon(
          onPressed: () => Actions.maybeInvoke(
            context,
            const AppCommandIntent(AppCommand.quickAdd),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(DotTouch.android),
          ),
          icon: DotIcon(DotGlyphs.add, color: t.colors.onAccent),
          label: Text(l10n.nowAddToDay),
        ),
        Text(l10n.nowOneThing, style: t.styles.rowMeta),
      ],
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet({required this.windDown});

  final String windDown;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DotSpace.xxl),
      child: Column(
        spacing: DotSpace.xs,
        children: [
          Text(l10n.widgetNothingNext, style: t.styles.emptyTitle),
          Text(l10n.nowFreeUntil(windDown), style: t.styles.rowMeta),
        ],
      ),
    );
  }
}
