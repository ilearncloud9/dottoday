import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/devices/device_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/devices/alarm_device.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/alarm_device_row.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_choice_mark.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wake Up alarm › Alarm sounds on (E-Phones "iPhone · Alarm sounds on",
/// ED-084): the schedule syncs everywhere and one device rings. Can ring:
/// each phone and tablet with its state, the chosen one checked; a tap
/// picks it, ready or not (Settings then says what to fix there). Can't
/// ring: a Mac and the web. Devices are named by kind until model names
/// are stored (owner 2026-11-24).
class AlarmDevicePage extends ConsumerStatefulWidget {
  const AlarmDevicePage({super.key});

  @override
  ConsumerState<AlarmDevicePage> createState() => _AlarmDevicePageState();
}

class _AlarmDevicePageState extends ConsumerState<AlarmDevicePage> {
  @override
  void initState() {
    super.initState();
    // This device's latest state before the list is read.
    unawaited(ref.read(deviceReporterProvider).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final self = ref.watch(selfDeviceIdProvider(profile.id)).value;
    final all = [
      for (final d
          in ref.watch(devicesProvider(profile.id)).value ?? const <Device>[])
        if (d.deletedAt == null) d,
    ];
    final ringable = [
      for (final d in all)
        if (d.canRing) d,
    ];
    final never = [
      for (final d in all)
        if (!d.canRing) d,
    ];
    Widget row(Device d) => _DeviceRow(device: d, profile: profile, self: self);
    return SettingsPageFrame(
      title: l10n.settingsAlarmSoundsOn,
      page: SettingsPage.alarmDevice,
      children: [
        PageText(l10n.wwdDevicesIntro),
        if (ringable.isNotEmpty)
          SettingsGroup(
            caption: l10n.wwdCanRing,
            children: [for (final d in ringable) row(d)],
          ),
        if (never.isNotEmpty)
          SettingsGroup(
            caption: l10n.wwdCantRing,
            children: [for (final d in never) row(d)],
          ),
      ],
    );
  }
}

/// One device: its kind's badge, its name and its state as a chip; the
/// chosen one checked. A Mac or the web is dimmed and can't be picked.
class _DeviceRow extends ConsumerWidget {
  const _DeviceRow({
    required this.device,
    required this.profile,
    required this.self,
  });

  final Device device;
  final Profile profile;
  final String? self;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final now = ref.watch(clockProvider).nowUtc();
    final chosen =
        device.canRing && device.id == profile.settings.alarmDeviceId;
    final (state, ready) = _state(context, now, chosen: chosen);
    final title = deviceLabel(l10n, device, self: self);
    return Semantics(
      selected: chosen,
      button: device.canRing,
      child: ListTile(
        minTileHeight: DotTouch.android,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.l,
        ),
        enabled: device.canRing,
        leading: _Badge(device: device),
        title: Text(
          title,
          style: device.canRing
              ? t.styles.body
              : t.styles.body.copyWith(color: t.colors.muted),
        ),
        subtitle: state == null
            ? null
            : Align(
                alignment: AlignmentDirectional.centerStart,
                child: _Chip(text: state, ready: ready),
              ),
        trailing: device.canRing ? SettingsChoiceMark(selected: chosen) : null,
        onTap: device.canRing
            ? () => changeSettings(
                context,
                (s) => s.copyWith(alarmDeviceId: device.id),
              )
            : null,
      ),
    );
  }

  /// The chip's words and whether it reads as ready.
  (String?, bool) _state(
    BuildContext context,
    DateTime now, {
    required bool chosen,
  }) {
    final l10n = context.l10n;
    if (!device.canRing) return (l10n.wwdNeverRings, false);
    final days = now.difference(device.lastSeenUtc).inDays;
    if (now.difference(device.lastSeenUtc) > alarmDeviceOfflineAfter) {
      return (l10n.wwdLastSeen(days), false);
    }
    if (!device.alarmOn) {
      return (l10n.wwdDeviceAlarmsOff(deviceKind(l10n, device)), false);
    }
    if (!chosen) return (null, false);
    final state = alarmDeviceState(device, nowUtc: now);
    return (
      alarmDeviceStateText(context, profile, state, device),
      state == AlarmDeviceState.ready,
    );
  }
}

/// The kind as a short word in a tile (E-Phones: "iPh", "iPad", "And",
/// "Mac", "Web"): product names, the same in every language.
class _Badge extends StatelessWidget {
  const _Badge({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final text = switch ((device.platform, device.form)) {
      (DevicePlatform.ios, DeviceForm.tablet) => 'iPad', // l10n-ignore: product
      (DevicePlatform.ios, _) => 'iPh', // l10n-ignore: product
      (DevicePlatform.android, _) => 'And', // l10n-ignore: product
      (DevicePlatform.macos, _) => 'Mac', // l10n-ignore: product
      (DevicePlatform.web, _) => 'Web', // l10n-ignore: product
    };
    return ExcludeSemantics(
      child: Container(
        width: DotSize.rowDot,
        height: DotSize.rowDot,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.colors.tile,
          borderRadius: BorderRadius.circular(DotRadii.iconTile),
        ),
        child: Text(text, style: t.styles.caption),
      ),
    );
  }
}

/// A device's state as a small chip: green when it is ready to ring.
class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.ready});

  final String text;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ink = ready ? t.tasks[TaskColor.mint].ink : t.colors.text;
    return Container(
      margin: const EdgeInsets.only(top: DotSpace.xs),
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
      decoration: BoxDecoration(
        color: ready
            ? ink.withValues(
                alpha: t.colors.isDark
                    ? TaskAlpha.tintDark
                    : TaskAlpha.tintLight,
              )
            : t.colors.chip,
        borderRadius: BorderRadius.circular(DotRadii.iconTile),
      ),
      child: Text(text, style: t.styles.caption.copyWith(color: ink)),
    );
  }
}
