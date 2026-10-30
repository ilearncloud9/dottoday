import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/sound_names.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/reminder_sound.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Settings › Reminders › Sound (docs/02 F6.6, M8.4d): the system sound
/// and the bundled set. A tap picks the sound and plays it, so the user
/// can try several; Done closes.
Future<void> showSoundSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.l10n.settingsSound,
  builder: (_) => const _Sounds(),
);

/// Settings › Reminders › Day-start summary (docs/02 F6.2, M8.4d): one
/// switch per weekday, in week order.
Future<void> showDaySummarySheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.l10n.settingsDaySummary,
  builder: (_) => const _SummaryDays(),
);

/// "Off", "Every day", "Weekdays" or "Mon, Wed, Fri".
String daySummaryText(BuildContext context, Set<Weekday> days) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  if (days.isEmpty) return l10n.settingsDaySummaryOff;
  if (days.length == Weekday.values.length) return l10n.repeatChoiceDaily;
  const workweek = {
    Weekday.mon,
    Weekday.tue,
    Weekday.wed,
    Weekday.thu,
    Weekday.fri,
  };
  if (days.length == workweek.length && days.containsAll(workweek)) {
    return l10n.repeatWeekdays;
  }
  return [
    for (final d in Weekday.values)
      if (days.contains(d)) weekdayName(locale, d),
  ].reduce(l10n.listJoin);
}

class _Sounds extends ConsumerWidget {
  const _Sounds();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    // docs/12 §3: unset is the Dot tone; the OS sound is stored as
    // "system" (null meant it before schema v8).
    final stored = settings.reminderSound ?? defaultReminderSoundId;
    bool isCurrent(ReminderSound? sound) =>
        (sound?.name ?? soundSystemKey) == stored;
    void pick(ReminderSound? sound) {
      changeSettings(
        context,
        (s) => s.copyWith(reminderSound: sound?.name ?? soundSystemKey),
      );
      if (sound != null) {
        unawaited(ref.read(soundPlayerProvider).play(resolveSound(sound.name)));
      }
    }

    Widget option(ReminderSound? sound, String label) => Semantics(
      selected: isCurrent(sound),
      child: ListTile(
        minTileHeight: DotTouch.android,
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: t.styles.rowTitle),
        trailing: isCurrent(sound)
            ? DotIcon(DotGlyphs.check, color: t.colors.accentInk)
            : null,
        onTap: () => pick(sound),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xs,
      children: [
        Text(l10n.settingsSoundDetail, style: t.styles.rowMeta),
        option(null, l10n.settingsSoundSystem),
        for (final s in ReminderSound.values) option(s, soundName(l10n, s)),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.alertsDone),
        ),
      ],
    );
  }
}

class _SummaryDays extends ConsumerWidget {
  const _SummaryDays();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final first = settings.firstDayOfWeek;
    final days = [
      for (var i = 0; i < 7; i++) Weekday.values[(first - 1 + i) % 7],
    ];
    void set(Weekday day, bool on) => changeSettings(
      context,
      (s) => s.copyWith(
        daySummaryDays: on
            ? {...s.daySummaryDays, day}
            : ({...s.daySummaryDays}..remove(day)),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xs,
      children: [
        Text(l10n.settingsDaySummaryDetail, style: t.styles.rowMeta),
        for (final d in days)
          MergeSemantics(
            child: ListTile(
              minTileHeight: DotTouch.android,
              contentPadding: EdgeInsets.zero,
              title: Text(
                DateFormat.EEEE(locale).format(DateTime(2024, 1, 1 + d.index)),
                style: t.styles.rowTitle,
              ),
              onTap: () => set(d, !settings.daySummaryDays.contains(d)),
              trailing: DotSwitch(
                value: settings.daySummaryDays.contains(d),
                onChanged: (v) => set(d, v),
              ),
            ),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.alertsDone),
        ),
      ],
    );
  }
}
