import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/features/settings/widgets/wind_down_learn_offer.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';

/// Settings › Day shape's night rows (docs/15 W4, W6, §9): the sleep target
/// (off, or 6 h–10 h), which pulls Wind Down earlier before an early
/// tomorrow, with the learned offer and its switch while one is set, and
/// whether the day dot shows the night.
List<Widget> nightRows(BuildContext context, Settings settings) {
  final t = DotTheme.of(context);
  final l10n = context.l10n;
  final target = settings.sleepTargetMin;
  return [
    SettingsRow(
      glyph: DotGlyphs.moon,
      tint: t.tasks[TaskColor.violet].ink,
      title: l10n.settingsSleepTarget,
      subtitle: l10n.settingsSleepTargetDetail,
      value: target == null
          ? l10n.settingsSleepTargetOff
          : formatDurationShort(l10n, target),
      onTap: () => unawaited(_pickTarget(context, target)),
      // The learned offer (15 §7b), only while Wind Down follows a target.
      below: target == null ? null : const WindDownLearnOffer(),
    ),
    if (target != null)
      SettingsRow(
        glyph: DotGlyphs.sunrise,
        tint: t.tasks[TaskColor.violet].ink,
        title: l10n.settingsWindDownLearn,
        toggle: settings.windDownLearnOffer,
        onToggle: (v) =>
            changeSettings(context, (s) => s.copyWith(windDownLearnOffer: v)),
      ),
    SettingsRow(
      glyph: DotGlyphs.freeRing,
      tint: t.tasks[TaskColor.violet].ink,
      title: l10n.settingsShowNight,
      toggle: settings.showNightArc,
      onToggle: (v) =>
          changeSettings(context, (s) => s.copyWith(showNightArc: v)),
    ),
  ];
}

/// The Wind Down row's value: "22:45 · from tomorrow's 06:30" when a sleep
/// target pulls it before the set time, else the set time.
String windDownValue(
  AppLocalizations l10n,
  Settings settings, {
  required int wakeMinute,
  required int windDownMinute,
  required String Function(int minute) at,
}) {
  final target = settings.sleepTargetMin;
  if (target == null) return at(windDownMinute);
  final derived = wakeMinute + 24 * 60 - target;
  if (derived >= windDownMinute) return at(windDownMinute);
  return l10n.settingsWindDownFrom(at(derived), at(wakeMinute));
}

Future<void> _pickTarget(BuildContext context, int? current) async {
  final l10n = context.l10n;
  final picked = await showChoiceSheet<int>(
    context,
    title: l10n.settingsSleepTarget,
    // 0 stands for off in the sheet; the setting stores null.
    selected: current ?? 0,
    options: [
      (value: 0, label: l10n.settingsSleepTargetOff, detail: null),
      for (final m in sleepTargetChoices)
        (value: m, label: formatDurationShort(l10n, m), detail: null),
    ],
  );
  if (picked == null || !context.mounted) return;
  changeSettings(
    context,
    (s) => s.copyWith(sleepTargetMin: picked == 0 ? null : picked),
  );
}
