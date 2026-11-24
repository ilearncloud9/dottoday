import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/devices/device_providers.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/notifications/wake_up_tier_text.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Day shape › Wake Up alarm (docs/15 W1a, owner 2026-10-31):
/// the switch, then what it does on this device in one line, with the fix
/// when something is in the way (15 §2). On the Mac and the web the switch
/// still works (it syncs) and says the alarm rings on the phone.
class WakeUpAlarmRow extends ConsumerWidget {
  const WakeUpAlarmRow({required this.on, this.ring = false, super.key});

  /// `Settings.wakeUpAlarm`.
  final bool on;

  /// Wake Up and Wind Down's switch (E-Phones, ED-084): titled "Ring like
  /// an alarm", with the board's short lines where it draws them.
  final bool ring;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final capabilities = ref.watch(alarmCapabilitiesNowProvider).value;
    final (detail, more) = capabilities == null
        ? (l10n.settingsWakeUpAlarmDetail, null)
        : _detail(l10n, capabilities);
    final short = ring ? _boardLine(ref, l10n, capabilities) : null;
    final fix = on && capabilities != null ? wakeUpFix(capabilities) : null;
    return SettingsRow(
      // E-Phones draws an alarm clock on the Ring like an alarm row.
      glyph: ring ? TaskIcon.alarm.glyph! : DotGlyphs.bell,
      tint: t.tasks[TaskColor.amber].ink,
      title: ring ? l10n.wwdRingLikeAlarm : l10n.settingsWakeUpAlarm,
      subtitle: short ?? detail,
      toggle: on,
      onToggle: (value) {
        changeSettings(context, (s) => s.copyWith(wakeUpAlarm: value));
        // iOS 26+ asks for alarms as the switch goes on (15 §2).
        if (value) unawaited(_allow(ref));
      },
      below: (short != null || more == null) && fix == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (short == null && more != null)
                  Text(more, style: t.styles.rowMeta),
                if (fix != null)
                  TextButton(
                    onPressed: () => unawaited(_fix(ref, fix)),
                    child: Text(wakeUpFixLabel(l10n, fix)),
                  ),
              ],
            ),
    );
  }

  /// E-Phones' lines (ED-084): off on a phone, a normal reminder; ringing
  /// like an alarm, "Alarm-grade on this iPhone" or, on Android, "Full
  /// screen over the lock screen". Null where the board draws none (the
  /// built tier lines, docs/15 §2).
  String? _boardLine(
    WidgetRef ref,
    AppLocalizations l10n,
    AlarmCapabilities? capabilities,
  ) {
    if (capabilities == null) return null;
    if (capabilities.blockers.contains(AlarmBlocker.notAPhone)) return null;
    if (!on) return l10n.wwdAlarmOffLine;
    if (capabilities.tier != AlarmTier.alarm) return null;
    if (capabilities.blockers.isNotEmpty) return null;
    if (currentHealthPlatform() == HealthPlatform.android) {
      return l10n.wwdAlarmFullScreen;
    }
    final tablet = ref.watch(deviceIdentityProvider).form == DeviceForm.tablet;
    return l10n.wwdAlarmGradeOn(tablet ? l10n.deviceIpad : l10n.deviceIphone);
  }

  /// Off on a phone: what it would do. On, or anywhere it can't ring: what
  /// it does here.
  (String, String?) _detail(
    AppLocalizations l10n,
    AlarmCapabilities capabilities,
  ) {
    final away = capabilities.blockers.contains(AlarmBlocker.notAPhone);
    if (!on && !away) return (l10n.settingsWakeUpAlarmDetail, null);
    return wakeUpTierText(l10n, capabilities);
  }

  Future<void> _allow(WidgetRef ref) async {
    await ref.read(alarmGatewayProvider).requestAuthorization();
    ref.invalidate(alarmCapabilitiesNowProvider);
  }

  Future<void> _fix(WidgetRef ref, AlarmBlocker blocker) async {
    await ref.read(alarmGatewayProvider).fix(blocker);
    ref
      ..invalidate(alarmCapabilitiesNowProvider)
      ..invalidate(notificationPermissionStateProvider)
      ..invalidate(exactAlarmsAllowedProvider);
  }
}
