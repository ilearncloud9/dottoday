import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';

/// Settings › Calendars › TRAVEL TIME (docs/02 F5, docs/09 M7.5, R-17):
/// whether an imported event with a place offers travel time before it,
/// off until chosen, and how much (one length for every event: no route is
/// looked up, so the place stays on the device).
class TravelTimeGroup extends StatelessWidget {
  const TravelTimeGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.calendarsTravel,
      children: [
        SettingsRow(
          glyph: TaskIcon.car.glyph ?? DotGlyphs.clock,
          tint: t.tasks[TaskColor.sky].ink,
          title: l10n.calendarsTravelSuggest,
          subtitle: l10n.calendarsTravelSuggestDetail,
          toggle: settings.suggestTravelTime,
          onToggle: (v) =>
              changeSettings(context, (s) => s.copyWith(suggestTravelTime: v)),
        ),
        if (settings.suggestTravelTime)
          SettingsRow(
            glyph: DotGlyphs.clock,
            tint: t.colors.accentInk,
            title: l10n.travelTitle,
            value: formatDurationShort(l10n, settings.travelTimeMin),
            onTap: () => unawaited(_pick(context)),
          ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showChoiceSheet<int>(
      context,
      title: l10n.travelTitle,
      selected: settings.travelTimeMin,
      options: [
        for (final m in Settings.travelChoices)
          (value: m, label: formatDurationShort(l10n, m), detail: null),
      ],
    );
    if (picked != null && context.mounted) {
      changeSettings(context, (s) => s.copyWith(travelTimeMin: picked));
    }
  }
}
