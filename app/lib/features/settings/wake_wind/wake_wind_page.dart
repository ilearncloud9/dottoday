import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/wake_wind/alarm_group.dart';
import 'package:dottoday/features/settings/wake_wind/reminders_group.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_cards.dart';
import 'package:dottoday/features/settings/wake_wind/tonight_card.dart';
import 'package:dottoday/features/settings/widgets/night_rows.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Your day › Wake Up and Wind Down (E-Phones, ED-084; M20.7
/// part 4a and its fix): Tonight, your week as schedules with Add a
/// schedule, the night (sleep target, the night on the day dot), the Wake
/// Up alarm as one group, and Reminders, whose card and check open Wake Up
/// options (E-R2-32). Minimal mode keeps the sound and missions until More
/// options (docs/15 §10). On a Mac or the web it says the alarm rings on
/// the phone and syncs (§11).
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
    if (profile == null || settings == null) return const SizedBox.shrink();
    final minimal = watchSimplified(ref, FeatureId.wakeUpAlarm);
    final full = !minimal || _more;
    final caps = ref.watch(alarmCapabilitiesNowProvider).value;
    final desktop = caps?.blockers.contains(AlarmBlocker.notAPhone) ?? false;
    return SettingsPageFrame(
      title: l10n.settingsWakeWindDown,
      page: SettingsPage.wakeWindDown,
      children: [
        if (desktop) PageText(l10n.wakeUpDesktopNote),
        TonightCard(profile: profile),
        ScheduleCards(settings: settings),
        SettingsGroup(
          caption: l10n.wwdTheNight,
          children: nightRows(context, settings),
        ),
        WakeUpAlarmGroup(profile: profile, full: full),
        if (!full && settings.wakeUpAlarm)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => setState(() => _more = true),
              child: Text(l10n.wakeUpMoreOptions),
            ),
          ),
        WakeWindRemindersGroup(settings: settings),
      ],
    );
  }
}
