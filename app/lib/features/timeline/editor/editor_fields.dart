import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/timeline/state/task_text.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_picker_sheet.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Uppercase field caption (`A-mac-editor` "WHEN", "DURATION").
class EditorCaption extends StatelessWidget {
  const EditorCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: DotSpace.l, bottom: DotSpace.s),
    child: Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: DotTheme.of(context).styles.caption,
      ),
    ),
  );
}

/// WHEN (a day button that opens the month) and START (typed or wheel
/// time) with "→ 11:00" (`A-mac-editor`). Changing the day keeps the wall
/// time; changing the time keeps the day (R-20).
class WhenFields extends ConsumerWidget {
  const WhenFields({
    required this.startUtc,
    required this.endUtc,
    required this.zone,
    required this.onDay,
    required this.onTime,
    super.key,
  });

  final DateTime startUtc;
  final DateTime endUtc;
  final tz.Location zone;
  final ValueChanged<DateTime> onDay;
  final ValueChanged<ClockTime> onTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final local = tz.TZDateTime.from(startUtc, zone);
    final day = DateTime(local.year, local.month, local.day);
    final today = ref.watch(todayDateProvider).value ?? day;
    final use24h = use24hFor(
      context,
      ref.watch(timelineDataProvider(day)).value?.settings.use24h,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorCaption(l10n.editorWhen),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDayPicker(
              context,
              title: l10n.editorPickDay,
              today: today,
              initial: day,
            );
            if (picked != null) onDay(picked);
          },
          icon: DotIcon(
            DotGlyphs.calendar,
            color: t.colors.text,
            size: DotSize.rowIcon,
          ),
          label: Text(DateFormat.MMMEd(locale).format(day)),
        ),
        EditorCaption(l10n.editorStart),
        Row(
          spacing: DotSpace.m,
          children: [
            Expanded(
              child: TimeInput(
                value: ClockTime.ofUtc(zone, startUtc),
                onChanged: onTime,
                use24h: use24h,
              ),
            ),
            Text(
              l10n.editorEndsAt(
                timeOfUtc(context, zone, endUtc, use24h: use24h),
              ),
              style: t.styles.body.copyWith(color: t.colors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

/// Repeat and Alerts as read-only rows until their editors land (M3f.1,
/// M3f.2).
class RepeatAlertRows extends StatelessWidget {
  const RepeatAlertRows({required this.task, super.key});

  final TaskView task;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    Widget row(DotGlyph glyph, String label, String value) => ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: DotTouch.android,
      leading: DotIcon(glyph, color: t.colors.muted),
      title: Text(label, style: t.styles.body),
      trailing: Text(
        value,
        style: t.styles.body.copyWith(color: t.colors.muted),
      ),
    );
    return Column(
      children: [
        row(
          DotGlyphs.repeat,
          l10n.sheetRepeat,
          repeatText(l10n, locale, task.series?.rrule),
        ),
        row(DotGlyphs.bell, l10n.sheetAlerts, alertsText(l10n, task.alerts)),
      ],
    );
  }
}
