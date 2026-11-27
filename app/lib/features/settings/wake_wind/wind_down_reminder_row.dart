import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// Wind Down reminder (docs/15 §9): at Wind Down, with tomorrow's first
/// task. On Wake Up and Wind Down's Reminders (E-Phones, ED-084), moved
/// from Settings › Reminders.
class WindDownReminderRow extends StatelessWidget {
  const WindDownReminderRow({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsRow(
      // The bell everywhere (ED-332).
      glyph: DotGlyphs.bell,
      tint: t.tasks[TaskColor.violet].ink,
      title: l10n.settingsWindDownReminder,
      subtitle: l10n.settingsWindDownReminderDetail,
      formLabel: l10n.settingsWindDown,
      toggle: settings.windDownReminder,
      onToggle: (v) =>
          changeSettings(context, (s) => s.copyWith(windDownReminder: v)),
    );
  }
}
