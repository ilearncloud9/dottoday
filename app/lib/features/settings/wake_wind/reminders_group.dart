import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/wake_up_card.dart';
import 'package:dottoday/features/settings/wake_wind/wind_down_reminder_row.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wake Up and Wind Down › Reminders (E-Phones, ED-084): the Wind Down
/// reminder, then the Wake Up card and Check I've started, which open
/// Wake Up options (E-R2-32, ED-337). The check runs only with the alarm
/// (docs/15 W3), so it reads Off without it; with the alarm off the
/// board's footer says both follow it.
class WakeWindRemindersGroup extends StatelessWidget {
  const WakeWindRemindersGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final check = settings.wakeUpAlarm && settings.wakeUpCheck;
    void options() =>
        unawaited(context.push(AppRoutes.settingsPage(SettingsPage.wakeUp)));
    // On a Mac/web form the card and the check share one Morning line
    // with Wake Up options… (ED-452).
    if (settingsFormAt(context)) {
      return SettingsGroup(
        caption: l10n.settingsReminders,
        formHeading: true,
        footer: settings.wakeUpAlarm ? null : l10n.wwdRemindersFooterOff,
        children: [
          WindDownReminderRow(settings: settings),
          FormLine(
            label: l10n.wwdFormMorning,
            child: Wrap(
              spacing: DotSpace.s,
              runSpacing: DotSpace.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.statusHintJoin(
                    wakeUpCardOn(settings)
                        ? l10n.wwdMorningCardOn
                        : l10n.wwdMorningCardOff,
                    check
                        ? l10n.wwdMorningCheck(
                            l10n.durationMinutes(settings.wakeUpCheckMin),
                          )
                        : l10n.wwdMorningNoCheck,
                  ),
                  style: t.styles.inspectorValue,
                ),
                FormButton(
                  label: l10n.settingsFormOpen(l10n.settingsWakeUpOptions),
                  onPressed: options,
                ),
              ],
            ),
          ),
        ],
      );
    }
    return SettingsGroup(
      caption: l10n.settingsReminders,
      footer: settings.wakeUpAlarm ? null : l10n.wwdRemindersFooterOff,
      children: [
        WindDownReminderRow(settings: settings),
        SettingsRow(
          glyph: DotGlyphs.horizon,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.wwdWakeUpCard,
          value: wakeUpCardOn(settings) ? l10n.wwdOn : l10n.wwdOff,
          onTap: options,
        ),
        SettingsRow(
          glyph: DotGlyphs.check,
          tint: t.tasks[TaskColor.mint].ink,
          title: l10n.wakeUpCheckRow,
          value: check
              ? l10n.wwdCheckAfterValue(
                  l10n.durationMinutes(settings.wakeUpCheckMin),
                )
              : l10n.wwdOff,
          onTap: options,
        ),
      ],
    );
  }
}
