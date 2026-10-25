import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/schedule/planned_colors.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/task_text.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/pin_row.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/pickers/zone_picker.dart';
import 'package:dottoday/shared/time/time_labels.dart';
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
/// time) with "→ 11:00" (`A-mac-editor`), then the time zone. Changing
/// the day keeps the wall time; changing the time keeps the day (R-20);
/// changing the zone keeps the wall clock and moves the instant (as Add's
/// Time zone, M3c.4).
class WhenFields extends ConsumerWidget {
  const WhenFields({
    required this.startUtc,
    required this.endUtc,
    required this.zone,
    required this.onWhen,
    super.key,
  });

  final DateTime startUtc;
  final DateTime endUtc;
  final tz.Location zone;

  /// The new start and its zone id.
  final void Function(DateTime startUtc, String tzId) onWhen;

  ClockTime get _time => ClockTime.ofUtc(zone, startUtc);

  DateTime get _day {
    final local = tz.TZDateTime.from(startUtc, zone);
    return DateTime(local.year, local.month, local.day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final day = _day;
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
          onPressed: () => unawaited(_pickDay(context, ref, day, today)),
          icon: DotIcon(
            DotGlyphs.calendar,
            color: t.colors.text,
            size: DotSize.rowIcon,
          ),
          label: Text(DateFormat.MMMEd(locale).format(day)),
        ),
        EditorCaption(l10n.editorStart),
        _startRow(context, t, use24h: use24h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => unawaited(_pickZone(context)),
            child: Text(l10n.editorZone(zoneCity(zone.name))),
          ),
        ),
      ],
    );
  }

  /// The typed time and "→ 11:00".
  Widget _startRow(BuildContext context, DotTheme t, {required bool use24h}) =>
      Row(
        spacing: DotSpace.m,
        children: [
          Expanded(
            child: TimeInput(
              value: _time,
              onChanged: (time) => onWhen(time.onDate(zone, _day), zone.name),
              use24h: use24h,
            ),
          ),
          Text(
            context.l10n.editorEndsAt(
              timeOfUtc(context, zone, endUtc, use24h: use24h),
            ),
            style: t.styles.body.copyWith(color: t.colors.muted),
          ),
        ],
      );

  /// "Change day" with each day's planned dots (docs/09 M3f.4).
  Future<void> _pickDay(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    DateTime today,
  ) async {
    final settings = ref.read(currentProfileProvider).value?.settings;
    final picked = await showMonthDayPicker(
      context,
      title: context.l10n.editorPickDay,
      today: today,
      initial: day,
      firstDayOfWeek: settings?.firstDayOfWeek ?? 1,
      plannedFor: (m) =>
          plannedColors(ProviderScope.containerOf(context, listen: false), m),
    );
    if (picked != null) onWhen(_time.onDate(zone, picked), zone.name);
  }

  /// "Time zone": the same wall clock in the picked zone.
  Future<void> _pickZone(BuildContext context) async {
    final id = await showZonePicker(context, current: zone.name);
    if (id == null || id == zone.name) return;
    onWhen(_time.onDate(tz.getLocation(id), _day), id);
  }
}

/// Repeat, Alerts and Travel time (docs/03 §3.4, M7.5): each row opens
/// its editor. Then the Pinned switch (docs/02 F2.9) when [onPinned] is
/// given.
class RepeatAlertRows extends StatelessWidget {
  const RepeatAlertRows({
    required this.task,
    this.onRepeat,
    this.onAlerts,
    this.travelMin = 0,
    this.onTravel,
    this.pinned = false,
    this.onPinned,
    super.key,
  });

  final TaskView task;

  /// Opens the Repeat editor (M3f.1); null keeps the row read-only.
  final VoidCallback? onRepeat;

  /// Opens the Alerts editor (M3f.2).
  final VoidCallback? onAlerts;

  /// The draft's travel time before it (R-17); 0 = none.
  final int travelMin;

  /// Picks the travel time; null hides the row (an Inbox task).
  final VoidCallback? onTravel;

  /// The draft's pin (R-17).
  final bool pinned;

  /// Pins or unpins the draft; hidden when null or the task is not
  /// [pinnable].
  final ValueChanged<bool>? onPinned;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    Widget row(
      DotGlyph glyph,
      String label,
      String value, [
      VoidCallback? onTap,
    ]) => ListTile(
      onTap: onTap,
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
          onRepeat,
        ),
        row(
          DotGlyphs.bell,
          l10n.sheetAlerts,
          alertsText(l10n, task.alerts),
          onAlerts,
        ),
        if (onTravel != null)
          row(
            TaskIcon.car.glyph ?? DotGlyphs.clock,
            l10n.travelTitle,
            travelMin == 0
                ? l10n.travelNone
                : l10n.travelBefore(formatDurationShort(l10n, travelMin)),
            onTravel,
          ),
        if (onPinned case final onPinned? when pinnable(task.occurrence))
          PinRow(
            pinned: pinned,
            onChanged: onPinned,
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
}
