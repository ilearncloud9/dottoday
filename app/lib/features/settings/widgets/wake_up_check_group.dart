import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';

/// Wake Up options › CHECK I'VE STARTED (docs/15 §9, W3, M17.4): on by
/// default for anyone with the Wake Up alarm, after 10 min, as a gentle
/// ping; it can ring like the alarm instead, once.
class WakeUpCheckGroup extends StatelessWidget {
  const WakeUpCheckGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.wakeUpCheckCaption,
      children: [
        SettingsRow(
          glyph: DotGlyphs.check,
          tint: t.tasks[TaskColor.mint].ink,
          title: l10n.wakeUpCheckRow,
          subtitle: l10n.wakeUpCheckRowDetail,
          toggle: settings.wakeUpCheck,
          onToggle: (v) =>
              changeSettings(context, (s) => s.copyWith(wakeUpCheck: v)),
        ),
        if (settings.wakeUpCheck) ...[
          SettingsRow(
            glyph: DotGlyphs.clock,
            tint: t.colors.accentInk,
            title: l10n.wakeUpLateAfterRow,
            value: l10n.durationMinutes(settings.wakeUpCheckMin),
            onTap: () => unawaited(_pickAfter(context)),
          ),
          SettingsRow(
            glyph: DotGlyphs.bell,
            tint: t.colors.accentInk,
            title: l10n.wakeUpCheckAsRow,
            value: _tier(l10n, loud: settings.wakeUpCheckLoud),
            onTap: () => unawaited(_pickTier(context)),
          ),
        ],
      ],
    );
  }

  Future<void> _pickAfter(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showChoiceSheet<int>(
      context,
      title: l10n.wakeUpLateAfterRow,
      selected: settings.wakeUpCheckMin,
      options: [
        for (final m in wakeUpCheckChoices)
          (value: m, label: l10n.durationMinutes(m), detail: null),
      ],
    );
    if (picked != null && context.mounted) {
      changeSettings(context, (s) => s.copyWith(wakeUpCheckMin: picked));
    }
  }

  Future<void> _pickTier(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showChoiceSheet<bool>(
      context,
      title: l10n.wakeUpCheckAsRow,
      selected: settings.wakeUpCheckLoud,
      options: [
        for (final loud in [false, true])
          (value: loud, label: _tier(l10n, loud: loud), detail: null),
      ],
    );
    if (picked != null && context.mounted) {
      changeSettings(context, (s) => s.copyWith(wakeUpCheckLoud: picked));
    }
  }
}

String _tier(AppLocalizations l10n, {required bool loud}) =>
    loud ? l10n.wakeUpCheckAlarm : l10n.wakeUpCheckGentle;
