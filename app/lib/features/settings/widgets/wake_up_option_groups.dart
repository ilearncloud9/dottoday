import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/sound_names.gen.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/features/settings/widgets/sound_tier_sheet.dart';
import 'package:dottoday/features/settings/widgets/wake_up_rotation_sheet.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:dottoday/shared/sounds/sound_sections.dart';
import 'package:flutter/material.dart';

/// Wake Up alarm › SOUND (docs/15 §9): the cue, Vary the sound and, on
/// Android, the volume ramp (AlarmKit sets the iPhone's volume itself, so
/// the row is not shown there). [full] off is minimal mode's sound row
/// alone (15 §10).
class WakeUpSoundGroup extends StatelessWidget {
  const WakeUpSoundGroup({
    required this.settings,
    required this.full,
    super.key,
  });

  final Settings settings;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final sound = resolveStartSound(
      settings.wakeUpSoundId ?? settings.startSoundId,
    );
    return SettingsGroup(
      caption: l10n.wakeUpSoundCaption,
      children: [
        SettingsRow(
          glyph: DotGlyphs.sound,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.wakeUpSoundRow,
          value: soundDisplayName(l10n, sound),
          onTap: () => unawaited(
            showSoundTierSheet(
              context,
              title: l10n.wakeUpSoundRow,
              sections: startSoundSections(l10n),
              selected: (s) =>
                  resolveStartSound(s.wakeUpSoundId ?? s.startSoundId).id,
              write: (s, key) => s.copyWith(wakeUpSoundId: key),
            ),
          ),
        ),
        if (full)
          SettingsRow(
            glyph: DotGlyphs.repeat,
            tint: t.tasks[TaskColor.sky].ink,
            title: l10n.wakeUpVary,
            subtitle: l10n.wakeUpVaryDetail,
            toggle: settings.wakeUpVarySound,
            onToggle: (on) =>
                changeSettings(context, (s) => s.copyWith(wakeUpVarySound: on)),
          ),
        // Which Start sounds rotate (15 §9: choose 2–6).
        if (full && settings.wakeUpVarySound)
          SettingsRow(
            glyph: DotGlyphs.sound,
            tint: t.tasks[TaskColor.sky].ink,
            title: l10n.wakeUpRotationTitle,
            value: wakeUpRotationValue(l10n, settings),
            onTap: () => unawaited(showWakeUpRotationSheet(context)),
          ),
        if (full && currentHealthPlatform() != HealthPlatform.iphone)
          SettingsRow(
            glyph: DotGlyphs.sunrise,
            tint: t.tasks[TaskColor.amber].ink,
            title: l10n.wakeUpRamp,
            subtitle: l10n.wakeUpRampDetail,
            value: _ramp(l10n, settings.wakeUpRampSec),
            onTap: () => unawaited(_pickRamp(context)),
          ),
      ],
    );
  }

  Future<void> _pickRamp(BuildContext context) async {
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
}

String _ramp(AppLocalizations l10n, int seconds) =>
    seconds == 0 ? l10n.wakeUpRampOff : l10n.wakeUpRampSeconds(seconds);

/// Wake Up alarm › SNOOZE (docs/15 §9): on by default, 9 min, 3 times.
/// Past the limit the ringing screen offers only "I'm up".
class WakeUpSnoozeGroup extends StatelessWidget {
  const WakeUpSnoozeGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.wakeUpSnoozeCaption,
      children: [
        SettingsRow(
          glyph: DotGlyphs.moon,
          tint: t.tasks[TaskColor.violet].ink,
          title: l10n.wakeUpSnoozeRow,
          subtitle: l10n.wakeUpSnoozeDetail,
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
            onTap: () => unawaited(_pickLength(context)),
          ),
          SettingsRow(
            glyph: DotGlyphs.repeat,
            tint: t.colors.accentInk,
            title: l10n.wakeUpSnoozeLimit,
            value: _limit(l10n, settings.wakeUpSnoozeMax),
            onTap: () => unawaited(_pickLimit(context)),
          ),
        ],
      ],
    );
  }

  Future<void> _pickLength(BuildContext context) async {
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

  Future<void> _pickLimit(BuildContext context) async {
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
}

String _limit(AppLocalizations l10n, int times) =>
    times == 0 ? l10n.wakeUpSnoozeNoLimit : l10n.wakeUpSnoozeTimes(times);
