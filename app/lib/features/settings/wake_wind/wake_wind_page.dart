import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_cards.dart';
import 'package:dottoday/features/settings/wake_wind/tonight_card.dart';
import 'package:dottoday/features/settings/wake_wind/wind_down_reminder_row.dart';
import 'package:dottoday/features/settings/widgets/alarm_device_row.dart';
import 'package:dottoday/features/settings/widgets/mission_group.dart';
import 'package:dottoday/features/settings/widgets/night_rows.dart';
import 'package:dottoday/features/settings/widgets/wake_up_alarm_row.dart';
import 'package:dottoday/features/settings/widgets/wake_up_card_group.dart';
import 'package:dottoday/features/settings/widgets/wake_up_check_group.dart';
import 'package:dottoday/features/settings/widgets/wake_up_option_groups.dart';
import 'package:dottoday/shared/learning/wake_up_explain_sheet.dart';
import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings › Your day › Wake Up and Wind Down (E-Phones, ED-084; M20.7
/// part 4a): Tonight, your week as schedules with Add a schedule, the
/// night (sleep target, the night on the day dot), the Wake Up alarm
/// (docs/15 §9: the switch with this device's tier and fix, sound, snooze,
/// the check and missions while it is on, a real test alarm), and
/// reminders (Wind Down reminder, the Morning card). Minimal mode shows the
/// switches and the sound, with the rest behind More options (15 §10). On
/// a Mac or the web it says the alarm rings on the phone and syncs (§11).
class WakeWindDownPage extends ConsumerStatefulWidget {
  const WakeWindDownPage({super.key});

  @override
  ConsumerState<WakeWindDownPage> createState() => _WakeWindDownPageState();
}

class _WakeWindDownPageState extends ConsumerState<WakeWindDownPage> {
  /// Minimal mode's "More options", open for this visit only.
  var _more = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    final settings = profile?.settings;
    if (settings == null) return const SizedBox.shrink();
    final minimal = watchSimplified(ref, FeatureId.wakeUpAlarm);
    final full = !minimal || _more;
    final alarm = ref.read(testAlarmProvider.notifier);
    final caps = ref.watch(alarmCapabilitiesNowProvider).value;
    final desktop = caps?.blockers.contains(AlarmBlocker.notAPhone) ?? false;
    return SettingsPageFrame(
      title: l10n.settingsWakeWindDown,
      page: SettingsPage.wakeWindDown,
      children: [
        if (desktop) PageText(l10n.wakeUpDesktopNote),
        if (profile != null) TonightCard(profile: profile),
        ScheduleCards(settings: settings),
        SettingsGroup(
          caption: l10n.wwdTheNight,
          children: nightRows(context, settings),
        ),
        SettingsGroup(
          caption: l10n.wakeUpAlarmCaption,
          children: [
            WakeUpAlarmRow(on: settings.wakeUpAlarm),
            if (settings.wakeUpAlarm && profile != null)
              AlarmDeviceRow(profile: profile),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => unawaited(showWakeUpExplainSheet(context)),
            child: Text(l10n.wakeUpHowItWorks),
          ),
        ),
        if (settings.wakeUpAlarm) ...[
          WakeUpSoundGroup(settings: settings, full: full),
          if (full) WakeUpSnoozeGroup(settings: settings),
          if (full) WakeUpCheckGroup(settings: settings),
          MissionGroup(settings: settings, full: full),
        ],
        SettingsGroup(
          caption: l10n.settingsReminders,
          children: [WindDownReminderRow(settings: settings)],
        ),
        WakeUpCardGroup(settings: settings, full: full),
        if (!full)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => setState(() => _more = true),
              child: Text(l10n.wakeUpMoreOptions),
            ),
          ),
        TestAlarmCard(
          onSend: alarm.sendWakeUp,
          // A test alarm is meant to ring after the phone is locked, so
          // leaving the page keeps it.
          onCancel: () async {},
          now: ref.read(clockProvider).nowUtc,
          afterNo: l10n.wakeUpTestLookHere,
        ),
        SettingsGroup(
          caption: l10n.healthCaption,
          children: const [_HealthLink()],
        ),
      ],
    );
  }
}

class _HealthLink extends StatelessWidget {
  const _HealthLink();

  @override
  Widget build(BuildContext context) => SettingsRow(
    glyph: DotGlyphs.warning,
    tint: DotTheme.of(context).colors.accentInk,
    title: context.l10n.healthTitle,
    onTap: () => unawaited(
      context.push(AppRoutes.settingsPage(SettingsPage.notifications)),
    ),
  );
}
