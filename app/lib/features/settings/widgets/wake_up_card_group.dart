import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/wake_up_card.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';

/// Wake Up options › MORNING CARD (docs/15 §9, M17.3): the card's switch
/// (unset follows the Wake Up alarm, 15 §11), then while it is on: open
/// on the first launch after Wake Up, its calendar and Inbox lines, and
/// the offer to shift the day past N minutes. [full] off is minimal mode's
/// switch alone (15 §10).
class WakeUpCardGroup extends StatelessWidget {
  const WakeUpCardGroup({
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
    final on = wakeUpCardOn(settings);
    SettingsRow toggle(
      DotGlyph glyph,
      String title,
      bool value,
      Settings Function(Settings, bool) write,
    ) => SettingsRow(
      glyph: glyph,
      tint: t.colors.accentInk,
      title: title,
      toggle: value,
      onToggle: (v) => changeSettings(context, (s) => write(s, v)),
    );
    return SettingsGroup(
      caption: l10n.wakeUpCardCaption,
      children: [
        SettingsRow(
          glyph: DotGlyphs.sunrise,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.wakeUpCardRow,
          subtitle: l10n.wakeUpCardRowDetail,
          toggle: on,
          onToggle: (v) =>
              changeSettings(context, (s) => s.copyWith(wakeUpCard: v)),
        ),
        if (on && full) ...[
          toggle(
            DotGlyphs.bell,
            l10n.wakeUpCardOnOpenRow,
            settings.wakeUpCardOnOpen,
            (s, v) => s.copyWith(wakeUpCardOnOpen: v),
          ),
          toggle(
            DotGlyphs.calendar,
            l10n.wakeUpCardCalendarRow,
            settings.wakeUpCardCalendar,
            (s, v) => s.copyWith(wakeUpCardCalendar: v),
          ),
          toggle(
            DotGlyphs.inbox,
            l10n.wakeUpCardInboxRow,
            settings.wakeUpCardInbox,
            (s, v) => s.copyWith(wakeUpCardInbox: v),
          ),
          toggle(
            DotGlyphs.rollForward,
            l10n.wakeUpLateOfferRow,
            settings.wakeUpLateOffer,
            (s, v) => s.copyWith(wakeUpLateOffer: v),
          ),
          if (settings.wakeUpLateOffer)
            SettingsRow(
              glyph: DotGlyphs.clock,
              tint: t.colors.accentInk,
              title: l10n.wakeUpLateAfterRow,
              value: l10n.durationMinutes(settings.wakeUpLateMin),
              onTap: () => unawaited(_pickLate(context)),
            ),
        ],
      ],
    );
  }

  Future<void> _pickLate(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showChoiceSheet<int>(
      context,
      title: l10n.wakeUpLateAfterRow,
      selected: settings.wakeUpLateMin,
      options: [
        for (final m in wakeUpLateChoices)
          (value: m, label: l10n.durationMinutes(m), detail: null),
      ],
    );
    if (picked != null && context.mounted) {
      changeSettings(context, (s) => s.copyWith(wakeUpLateMin: picked));
    }
  }
}
