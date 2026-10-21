import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// "Today · 9:00 – 11:00 · 2 h · 38 min left" (`A-ios-task-sheet`).
class SheetMeta extends ConsumerWidget {
  const SheetMeta({required this.task, this.minutesLeft, super.key});

  final TaskView task;
  final int? minutesLeft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final o = task.occurrence;
    final start = o.startUtc;
    final muted = t.styles.body.copyWith(color: t.colors.muted);
    if (start == null) return Text(l10n.sheetInbox, style: muted);
    final zone = tz.getLocation(o.tzId);
    final today = ref.watch(todayDateProvider).value;
    final use24h = use24hFor(
      context,
      ref
          .watch(timelineDataProvider(_localDay(start, zone)))
          .value
          ?.settings
          .use24h,
    );
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final meta = l10n.sheetMetaDay(
      _dayName(context, start, zone, today),
      l10n.threadTimeRange(time(start), time(o.endUtc!)),
      formatDurationShort(l10n, o.durationMin),
    );
    return Text.rich(
      TextSpan(
        text: meta,
        children: [
          if (minutesLeft case final left?)
            TextSpan(
              text: l10n.sheetLeftSuffix(l10n.liveMinutesLeft(left)),
              style: TextStyle(color: t.colors.accentInk),
            ),
        ],
      ),
      style: muted,
    );
  }

  static DateTime _localDay(DateTime utc, tz.Location zone) {
    final l = tz.TZDateTime.from(utc, zone);
    return DateTime(l.year, l.month, l.day);
  }

  static String _dayName(
    BuildContext context,
    DateTime utc,
    tz.Location zone,
    DateTime? today,
  ) {
    final day = _localDay(utc, zone);
    final l10n = context.l10n;
    if (day == today) return l10n.sheetToday;
    if (today != null &&
        day == DateTime(today.year, today.month, today.day + 1)) {
      return l10n.sheetTomorrow;
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.MMMEd(locale).format(day);
  }
}
