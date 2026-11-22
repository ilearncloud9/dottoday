import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:dottoday/features/search/state/search_state.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mac and web at the expanded width: results as cards at pointer sizes
/// (E-R2-30); touch and narrow windows list them flat (E-R2-13).
bool searchCards(BuildContext context) =>
    !touchApp(context) && AppLayout.classOf(context) == WidthClass.expanded;

/// One result (E-R2-13, E-R2-30): the task's dot in its state, the title
/// with the match highlighted, and its meta: live ("9:00 – 11:00 · 38 min
/// left"), done (struck, "Mon 19 · … · Done"), not done, another day, or
/// the Inbox with Schedule.
class SearchRow extends StatelessWidget {
  const SearchRow({
    required this.task,
    required this.query,
    required this.view,
    required this.onOpen,
    required this.onSchedule,
    super.key,
  });

  final Occurrence task;
  final String query;
  final SearchView view;
  final VoidCallback onOpen;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final info = _info(context);
    final done = task.status == OccurrenceStatus.done;
    final cards = searchCards(context);
    final row = Row(
      spacing: DotSpace.m,
      children: [
        TaskDot(
          color: TaskColor.fromKey(task.colorKey),
          icon: TaskIcon.fromKey(task.iconKey),
          state: info.state,
          progress: info.progress,
          label: task.title,
          size: cards ? DotSize.macRowDot : DotSize.rowDot,
        ),
        Expanded(
          child: _text(t, info, done: done, cards: cards),
        ),
        if (task.isInbox) _ScheduleButton(onTap: onSchedule, small: cards),
      ],
    );
    return Semantics(
      button: true,
      label: l10n.searchRowLabel(task.title, info.meta),
      excludeSemantics: true,
      child: Material(
        color: cards ? t.colors.raised : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.card),
          side: cards
              ? BorderSide(color: t.colors.threadAhead)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: cards ? DotTouch.android : DotSize.searchRowMin,
            ),
            child: Padding(
              padding: cards
                  ? const EdgeInsets.symmetric(
                      horizontal: DotSpace.m,
                      vertical: DotSpace.s,
                    )
                  : const EdgeInsets.symmetric(
                      horizontal: DotSpace.xs,
                      vertical: DotSpace.xs + DotSpace.xxs,
                    ),
              child: row,
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(
    DotTheme t,
    _Info info, {
    required bool done,
    required bool cards,
  }) {
    final base = (cards ? t.styles.cardTitle : t.styles.rowTitle).copyWith(
      color: done ? t.colors.muted : t.colors.text,
      decoration: done ? TextDecoration.lineThrough : null,
    );
    final title = task.title;
    final spans = <InlineSpan>[];
    var at = 0;
    for (final (start, end) in matchSpans(title, query)) {
      if (start > at) spans.add(TextSpan(text: title.substring(at, start)));
      spans.add(
        TextSpan(
          text: title.substring(start, end),
          style: TextStyle(backgroundColor: t.colors.accentTint),
        ),
      );
      at = end;
    }
    if (at < title.length) spans.add(TextSpan(text: title.substring(at)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(style: base, children: spans)),
        _Meta(info: info),
      ],
    );
  }

  _Info _info(BuildContext context) {
    final l10n = context.l10n;
    final start = task.startUtc;
    if (start == null) {
      return _Info(
        DotState.upcoming,
        l10n.searchMetaInbox(formatDurationShort(l10n, task.durationMin)),
      );
    }
    final when = _when(context, start);
    final now = view.nowUtc;
    if (task.status == OccurrenceStatus.done) {
      return _Info(DotState.done, l10n.searchMetaDone(when));
    }
    if (task.status == OccurrenceStatus.skipped) {
      return _Info(DotState.skipped, when);
    }
    if (!start.isAfter(now) && task.endUtc!.isAfter(now)) {
      final total = task.endUtc!.difference(start).inSeconds;
      // Rounded up, as the thread shows it (`thread_day.dart`).
      final left = (task.endUtc!.difference(now).inSeconds / 60).ceil();
      return _Info(
        DotState.live,
        when,
        progress: now.difference(start).inSeconds / total,
        left: l10n.liveMinutesLeft(left),
      );
    }
    if (!task.endUtc!.isAfter(now)) {
      return _Info(DotState.missed, l10n.searchMetaMissed(when));
    }
    return _Info(DotState.upcoming, when);
  }
}

extension on SearchRow {
  /// "9:00 – 11:00" today, else "Fri 23 · 2:00 – 3:00".
  String _when(BuildContext context, DateTime start) {
    final l10n = context.l10n;
    final day = localDateOf(task, view.location)!;
    final text = DayTimeText(
      context,
      view.location,
      day,
      use24h: use24hFor(context, view.use24h),
    );
    final range = l10n.threadTimeRange(text.utc(start), text.utc(task.endUtc!));
    if (day == view.today) return range;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return l10n.searchMetaDay(
      l10n.searchDayLabel(
        DateFormat.E(locale).format(day),
        DateFormat.d(locale).format(day),
      ),
      range,
    );
  }
}

final class _Info {
  const _Info(this.state, this.meta, {this.progress = 0, this.left});

  final DotState state;
  final String meta;
  final double progress;
  final String? left;
}

/// Schedule on an Inbox result (E-R2-30).
class _ScheduleButton extends StatelessWidget {
  const _ScheduleButton({required this.onTap, required this.small});

  final VoidCallback onTap;

  /// Pointer size, on the Mac and the web's cards.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: t.colors.text,
        textStyle: small ? t.styles.rowMeta : t.styles.button,
        padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
        minimumSize: Size(
          0,
          small ? DotTouch.pointer + DotSpace.s : DotTouch.android,
        ),
        tapTargetSize: small
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
      ),
      child: Text(context.l10n.inboxSchedule),
    );
  }
}

/// "9:00 – 11:00  ● 38 min left" (the live part in the accent).
class _Meta extends StatelessWidget {
  const _Meta({required this.info});

  final _Info info;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Text.rich(
      TextSpan(
        style: t.styles.rowMeta,
        children: [
          TextSpan(text: info.meta),
          if (info.left case final left?) ...[
            const TextSpan(text: '  '), // l10n-ignore: spacing
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: DotSpace.s,
                height: DotSpace.s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.colors.accent,
                ),
              ),
            ),
            TextSpan(
              text: ' $left', // l10n-ignore: spacing
              style: TextStyle(
                color: t.colors.accentInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
