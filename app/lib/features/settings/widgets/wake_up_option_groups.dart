import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/sound_names.gen.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/features/settings/widgets/sound_tier_sheet.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:dottoday/shared/sounds/sound_sections.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wake Up alarm's sound rows (docs/15 §9; E-Phones, ED-084): the cue;
/// on Android the volume ramp (E-R2-18; AlarmKit sets the iPhone's volume
/// itself); Vary the sound, which opens its page. [full] off is minimal
/// mode's sound row alone (15 §10).
List<Widget> wakeUpSoundRows(
  BuildContext context,
  Settings settings, {
  required bool full,
}) {
  final t = DotTheme.of(context);
  final l10n = context.l10n;
  final sound = resolveStartSound(
    settings.wakeUpSoundId ?? settings.startSoundId,
  );
  return [
    SettingsRow(
      glyph: DotGlyphs.sound,
      tint: t.tasks[TaskColor.slate].ink,
      title: l10n.settingsSound,
      value: soundDisplayName(l10n, sound),
      onTap: () => unawaited(pickWakeUpSound(context)),
    ),
    if (full && currentHealthPlatform() != HealthPlatform.iphone)
      SettingsRow(
        glyph: DotGlyphs.sunrise,
        tint: t.tasks[TaskColor.amber].ink,
        title: l10n.wakeUpRamp,
        value: _ramp(l10n, settings.wakeUpRampSec),
        onTap: () => unawaited(_pickRamp(context, settings)),
      ),
    if (full)
      SettingsRow(
        glyph: DotGlyphs.repeat,
        tint: t.tasks[TaskColor.violet].ink,
        title: l10n.wakeUpVary,
        value: settings.wakeUpVarySound ? l10n.wwdOn : l10n.wwdOff,
        onTap: () => unawaited(
          context.push(AppRoutes.settingsPage(SettingsPage.varySound)),
        ),
      ),
  ];
}

Future<void> _pickRamp(BuildContext context, Settings settings) async {
  final l10n = context.l10n;
  final picked = await showChoiceSheet<int>(
    context,
    title: l10n.wakeUpRamp,
    selected: settings.wakeUpRampSec,
    options: [
      for (final s in wakeUpRampChoices)
        (value: s, label: _ramp(l10n, s), detail: null),
    ],
  );
  if (picked != null && context.mounted) {
    changeSettings(context, (s) => s.copyWith(wakeUpRampSec: picked));
  }
}

String _ramp(AppLocalizations l10n, int seconds) =>
    seconds == 0 ? l10n.wakeUpRampOff : l10n.wakeUpRampSeconds(seconds);

/// Wake Up alarm's snooze rows (docs/15 §9; E-Phones, ED-084): on by
/// default, 9 min, 3 times. Past the limit the ringing screen offers only
/// "I'm up".
List<Widget> wakeUpSnoozeRows(BuildContext context, Settings settings) {
  final t = DotTheme.of(context);
  final l10n = context.l10n;
  return [
    SettingsRow(
      glyph: DotGlyphs.moon,
      tint: t.tasks[TaskColor.violet].ink,
      title: l10n.wakeUpSnoozeRow,
      toggle: settings.wakeUpSnooze,
      onToggle: (on) =>
          changeSettings(context, (s) => s.copyWith(wakeUpSnooze: on)),
    ),
    if (settings.wakeUpSnooze) ...[
      SettingsRow(
        glyph: DotGlyphs.clock,
        tint: t.colors.accentInk,
        title: l10n.wakeUpSnoozeLength,
        value: l10n.durationMinutes(settings.wakeUpSnoozeMin),
        onTap: () => unawaited(_pickLength(context, settings)),
      ),
      SettingsRow(
        glyph: DotGlyphs.repeat,
        tint: t.colors.accentInk,
        title: l10n.wakeUpSnoozeLimit,
        // The count alone, as E-Phones draws it; the picker says "times".
        value: switch (settings.wakeUpSnoozeMax) {
          0 => l10n.wakeUpSnoozeNoLimit,
          final n => '$n', // l10n-ignore: a count
        },
        onTap: () => unawaited(_pickLimit(context, settings)),
      ),
    ],
  ];
}

Future<void> _pickLength(BuildContext context, Settings settings) async {
  final l10n = context.l10n;
  final picked = await showChoiceSheet<int>(
    context,
    title: l10n.wakeUpSnoozeLength,
    selected: settings.wakeUpSnoozeMin,
    options: [
      for (final m in wakeUpSnoozeChoices)
        (value: m, label: l10n.durationMinutes(m), detail: null),
    ],
  );
  if (picked != null && context.mounted) {
    changeSettings(context, (s) => s.copyWith(wakeUpSnoozeMin: picked));
  }
}

Future<void> _pickLimit(BuildContext context, Settings settings) async {
  final l10n = context.l10n;
  final picked = await showChoiceSheet<int>(
    context,
    title: l10n.wakeUpSnoozeLimit,
    selected: settings.wakeUpSnoozeMax,
    options: [
      for (final n in wakeUpSnoozeLimits)
        (value: n, label: _limit(l10n, n), detail: null),
    ],
  );
  if (picked != null && context.mounted) {
    changeSettings(context, (s) => s.copyWith(wakeUpSnoozeMax: picked));
  }
}

String _limit(AppLocalizations l10n, int times) =>
    times == 0 ? l10n.wakeUpSnoozeNoLimit : l10n.wakeUpSnoozeTimes(times);

/// The Wake Up sound's picker, shared by every schedule: the Sound row
/// and the schedule sheet's Sound and snooze (owner 2026-11-24).
Future<void> pickWakeUpSound(BuildContext context) => showSoundTierSheet(
  context,
  title: context.l10n.wakeUpSoundRow,
  sections: startSoundSections(context.l10n),
  selected: (s) => resolveStartSound(s.wakeUpSoundId ?? s.startSoundId).id,
  write: (s, key) => s.copyWith(wakeUpSoundId: key),
);

/// The Wake Up sound's name ("Dawn chorus").
String wakeUpSoundName(AppLocalizations l10n, Settings settings) =>
    soundDisplayName(
      l10n,
      resolveStartSound(settings.wakeUpSoundId ?? settings.startSoundId),
    );
