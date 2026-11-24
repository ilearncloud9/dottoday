import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/devices/device_providers.dart';
import 'package:dottoday/domain/devices/alarm_device.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wake Up alarm › Alarm sounds on (E-Phones, ED-084; docs/15 §9a): the
/// one phone or tablet that rings Wake Up, with its state; a tap opens
/// its page to pick another.
class AlarmDeviceRow extends ConsumerWidget {
  const AlarmDeviceRow({required this.profile, super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final self = ref.watch(selfDeviceIdProvider(profile.id)).value;
    final all = ref.watch(devicesProvider(profile.id)).value ?? const [];
    final chosen = all
        .where((d) => d.canRing && d.id == profile.settings.alarmDeviceId)
        .firstOrNull;
    final now = ref.watch(clockProvider).nowUtc();
    return SettingsRow(
      glyph: TaskIcon.flipphone.glyph!,
      tint: t.tasks[TaskColor.slate].ink,
      title: l10n.settingsAlarmSoundsOn,
      value: chosen == null ? null : deviceLabel(l10n, chosen, self: self),
      accentValue: true,
      subtitle: alarmDeviceStateText(
        context,
        profile,
        alarmDeviceState(chosen, nowUtc: now),
        chosen,
      ),
      onTap: () => unawaited(
        context.push(AppRoutes.settingsPage(SettingsPage.alarmDevice)),
      ),
    );
  }
}

/// The chosen device's state in words: "Ready · confirmed 6:02 PM" (when
/// it last confirmed the times, E-Phones), "Waiting to sync", …
String alarmDeviceStateText(
  BuildContext context,
  Profile profile,
  AlarmDeviceState state,
  Device? chosen,
) {
  final l10n = context.l10n;
  return switch (state) {
    AlarmDeviceState.ready when chosen != null => l10n.alarmDeviceReadyAt(
      formatClockTime(
        context,
        ClockTime.ofUtc(tz.getLocation(profile.tzId), chosen.lastSeenUtc),
        use24h: profile.settings.use24h,
      ),
    ),
    AlarmDeviceState.ready => l10n.alarmDeviceReady,
    AlarmDeviceState.waitingToSync => l10n.alarmDeviceWaiting,
    AlarmDeviceState.alarmsOff => l10n.alarmDeviceAlarmsOff,
    AlarmDeviceState.noDevice => l10n.alarmDeviceNone,
    AlarmDeviceState.offline => l10n.alarmDeviceOffline,
  };
}

/// "iPhone", "Android tablet", or "This iPhone" for [self].
String deviceLabel(AppLocalizations l10n, Device d, {String? self}) {
  final kind = deviceKind(l10n, d);
  return d.id == self ? l10n.deviceThis(kind) : kind;
}

/// "iPhone", "iPad", "Android phone", "Mac", "Web browser".
String deviceKind(AppLocalizations l10n, Device d) =>
    switch ((d.platform, d.form)) {
      (DevicePlatform.ios, DeviceForm.tablet) => l10n.deviceIpad,
      (DevicePlatform.ios, _) => l10n.deviceIphone,
      (DevicePlatform.android, DeviceForm.tablet) => l10n.deviceAndroidTablet,
      (DevicePlatform.android, _) => l10n.deviceAndroidPhone,
      (DevicePlatform.macos, _) => l10n.deviceMac,
      (DevicePlatform.web, _) => l10n.deviceWeb,
    };
