import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/devices/device_providers.dart';
import 'package:dottoday/domain/devices/alarm_device.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Settings › Wake Up › Alarm sounds on (ED-084, docs/15 §9a): the one
/// phone or tablet that rings Wake Up, with its state; a tap picks another.
/// Only devices that can ring are offered; a Mac and the web never ring.
class AlarmDeviceRow extends ConsumerWidget {
  const AlarmDeviceRow({required this.profile, super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final self = ref.watch(selfDeviceIdProvider(profile.id)).value;
    final all = ref.watch(devicesProvider(profile.id)).value ?? const [];
    final ringable = [
      for (final d in all)
        if (d.canRing) d,
    ];
    final chosenId = profile.settings.alarmDeviceId;
    final chosen = ringable.where((d) => d.id == chosenId).firstOrNull;
    final now = ref.watch(clockProvider).nowUtc();
    final state = alarmDeviceState(chosen, nowUtc: now);
    return SettingsRow(
      glyph: DotGlyphs.bell,
      tint: t.tasks[TaskColor.amber].ink,
      title: l10n.settingsAlarmSoundsOn,
      value: chosen == null ? null : deviceLabel(l10n, chosen, self: self),
      subtitle: _stateText(context, state, chosen),
      below: Text(l10n.alarmDeviceNote, style: t.styles.rowMeta),
      onTap: ringable.isEmpty
          ? null
          : () => unawaited(_pick(context, ref, ringable, self, now)),
    );
  }

  String _stateText(
    BuildContext context,
    AlarmDeviceState state,
    Device? chosen,
  ) {
    final l10n = context.l10n;
    return switch (state) {
      AlarmDeviceState.ready => switch (chosen?.armedWakeUtc) {
        final at? => l10n.alarmDeviceReadyAt(_time(context, at)),
        null => l10n.alarmDeviceReady,
      },
      AlarmDeviceState.waitingToSync => l10n.alarmDeviceWaiting,
      AlarmDeviceState.alarmsOff => l10n.alarmDeviceAlarmsOff,
      AlarmDeviceState.noDevice => l10n.alarmDeviceNone,
      AlarmDeviceState.offline => l10n.alarmDeviceOffline,
    };
  }

  String _time(BuildContext context, DateTime utc) => formatClockTime(
    context,
    ClockTime.ofUtc(tz.getLocation(profile.tzId), utc),
    use24h: profile.settings.use24h,
  );

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    List<Device> ringable,
    String? self,
    DateTime now,
  ) async {
    unawaited(ref.read(deviceReporterProvider).refresh());
    final l10n = context.l10n;
    final picked = await showChoiceSheet<String>(
      context,
      title: l10n.settingsAlarmSoundsOn,
      selected: profile.settings.alarmDeviceId ?? '',
      options: [
        for (final d in ringable)
          (
            value: d.id,
            label: deviceLabel(l10n, d, self: self),
            detail: d.id == profile.settings.alarmDeviceId
                ? _stateText(context, alarmDeviceState(d, nowUtc: now), d)
                : null,
          ),
      ],
    );
    if (picked == null || !context.mounted) return;
    changeSettings(context, (s) => s.copyWith(alarmDeviceId: picked));
  }
}

/// "iPhone", "Android tablet", or "This iPhone" for [self].
String deviceLabel(AppLocalizations l10n, Device d, {String? self}) {
  final kind = switch ((d.platform, d.form)) {
    (DevicePlatform.ios, DeviceForm.tablet) => l10n.deviceIpad,
    (DevicePlatform.ios, _) => l10n.deviceIphone,
    (DevicePlatform.android, DeviceForm.tablet) => l10n.deviceAndroidTablet,
    (DevicePlatform.android, _) => l10n.deviceAndroidPhone,
    (DevicePlatform.macos, _) => l10n.deviceMac,
    (DevicePlatform.web, _) => l10n.deviceWeb,
  };
  return d.id == self ? l10n.deviceThis(kind) : kind;
}
