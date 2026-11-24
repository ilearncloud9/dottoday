import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/features/settings/wake_wind/missions_page.dart';
import 'package:dottoday/features/settings/widgets/alarm_device_row.dart';
import 'package:dottoday/features/settings/widgets/wake_up_alarm_row.dart';
import 'package:dottoday/features/settings/widgets/wake_up_option_groups.dart';
import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wake Up and Wind Down › Wake Up alarm, one group as E-Phones draws it
/// (ED-084): Ring like an alarm; while on, Alarm sounds on, Sound (and on
/// Android the volume ramp, E-R2-18), Vary the sound, Snooze with its
/// length and limit, and Missions; Send a test alarm (its steps E-R2-20,
/// ED-317); and the board's footer. Minimal mode keeps the sound and
/// missions until More options (docs/15 §10).
class WakeUpAlarmGroup extends ConsumerWidget {
  const WakeUpAlarmGroup({
    required this.profile,
    required this.full,
    super.key,
  });

  final Profile profile;
  final bool full;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = profile.settings;
    final on = settings.wakeUpAlarm;
    final alarm = ref.read(testAlarmProvider.notifier);
    // On a Mac/web form, Alarm sounds on sits above the table and only the
    // phone can ring a test (ED-452).
    final form = settingsFormAt(context);
    return SettingsGroup(
      caption: l10n.settingsWakeUpAlarm,
      formHeading: true,
      footer: _footer(l10n, on: on),
      children: [
        WakeUpAlarmRow(on: on, ring: true),
        if (on) ...[
          if (!form) AlarmDeviceRow(profile: profile),
          ...wakeUpSoundRows(context, settings, full: full),
          if (full) ...wakeUpSnoozeRows(context, settings),
          MissionsRow(settings: settings),
        ],
        if (!form)
          TestAlarmRow(
            title: l10n.wwdSendTestAlarm,
            action: true,
            onSend: alarm.sendWakeUp,
            // A test alarm is meant to ring after the phone is locked, so
            // leaving the page keeps it.
            onCancel: () async {},
            now: ref.read(clockProvider).nowUtc,
            afterNo: l10n.wakeUpTestLookHere,
          ),
      ],
    );
  }

  /// On: one sound and snooze for every schedule. Off on a phone: what
  /// turning it on does there (iPhone E-Phones; Android, owner
  /// 2026-11-24). A Mac or the web never rings, and its note says so.
  static String? _footer(AppLocalizations l10n, {required bool on}) {
    if (on) return l10n.wwdAlarmFooterOn;
    return switch (currentHealthPlatform()) {
      HealthPlatform.iphone => l10n.wwdAlarmFooterOffIos,
      HealthPlatform.android => l10n.wwdAlarmFooterOffAndroid,
      HealthPlatform.mac || HealthPlatform.web => null,
    };
  }
}
