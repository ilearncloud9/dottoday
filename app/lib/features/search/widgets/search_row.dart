import 'package:dottoday/core/l10n/l10n.dart';
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

/// One result (`A-ios-search`): the task's dot in its state, the title with
/// the match highlighted, and its meta — live ("9:00 – 11:00 · 38 min
/// left"), done (struck, "Mon 19 · … · Done"), missed, another day, or the
/// Inbox with "+ Schedule".
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
    return Semantics(
      button: true,
      label: l10n.searchRowLabel(task.title, info.meta),
      excludeSemantics: true,
      child: Material(
        color: t.colors.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.cardLarge),
          side: BorderSide(color: t.colors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.l),
            child: Row(
              spacing: DotSpace.m,
              children: [
                TaskDot(
                  color: TaskColor.fromKey(task.colorKey),
                  icon: TaskIcon.fromKey(task.iconKey),
                  state: info.state,
                  progress: info.progress,
                  label: task.title,
                ),
                Expanded(child: _text(t, info, done: done)),
                if (task.isInbox)
                  _ScheduleButton(onTap: onSchedule)
                else
                  DotIcon(
                    DotGlyphs.chevronRight,
                    color: t.colors.muted,
                    size: DotSize.rowIcon,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(DotTheme t, _Info info, {required bool done}) {
    final base = t.styles.rowTitle.copyWith(
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

/// "+ Schedule" on an inbox result.
class _ScheduleButton extends StatelessWidget {
  const _ScheduleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: t.colors.accentTint,
        foregroundColor: t.colors.accentInk,
        shape: const StadiumBorder(),
      ),
      icon: DotIcon(
        DotGlyphs.add,
        color: t.colors.accentInk,
        size: DotSize.rowIcon,
      ),
      label: Text(context.l10n.inboxSchedule),
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
