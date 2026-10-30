import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/notifications/sound_names.gen.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sync/clock_skew_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Reminders › Notification health (docs/09 M6.5.8, 11 A0;
/// derived from `SettingsGroup` rows): the real OS state that decides
/// whether a reminder gets through, in plain words, with one fix per
/// problem. Never red: a problem is a warning glyph and its sentence.
class NotificationHealthPage extends ConsumerWidget {
  const NotificationHealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final checks = ref.watch(notificationHealthChecksProvider).value;
    return SettingsPageFrame(
      title: l10n.healthTitle,
      children: [
        PageText(l10n.healthIntro),
        if (checks != null)
          SettingsGroup(
            caption: l10n.healthCaption,
            children: [for (final c in checks) HealthRow(check: c)],
          ),
        TestAlarmCard(
          onSend: ref.read(testAlarmProvider.notifier).send,
          onCancel: ref.read(testAlarmProvider.notifier).cancel,
          now: ref.read(clockProvider).nowUtc,
          afterNo: l10n.testAlarmLookHere,
        ),
      ],
    );
  }
}

/// One check: what it is, what to do, and its fix.
class HealthRow extends ConsumerWidget {
  const HealthRow({required this.check, super.key});

  /// Text scale past which a fix button moves under the row's text.
  static const _stackAbove = 1.3;

  final HealthCheck check;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final (title, detail) = _text(context.l10n);
    final fix = _fix(context, ref);
    final button = fix == null
        ? null
        : TextButton(onPressed: () => unawaited(fix.$2()), child: Text(fix.$1));
    // Large text: the button goes under the words instead of squeezing
    // them to a letter a line beside it (accessibility-as-code: reflow).
    final stacked = MediaQuery.textScalerOf(context).scale(1) > _stackAbove;
    return SettingsRow(
      glyph: switch (check.level) {
        HealthLevel.ok => DotGlyphs.check,
        HealthLevel.problem => DotGlyphs.warning,
        HealthLevel.info => DotGlyphs.bell,
      },
      tint: switch (check.level) {
        HealthLevel.ok => t.colors.success,
        HealthLevel.problem => t.colors.accentInk,
        HealthLevel.info => t.colors.muted,
      },
      title: title,
      subtitle: detail,
      trailing: stacked ? null : button,
      below: stacked && button != null
          ? Align(alignment: AlignmentDirectional.centerStart, child: button)
          : null,
    );
  }

  (String, String?) _text(AppLocalizations l10n) {
    final ok = check.level == HealthLevel.ok;
    return switch (check.kind) {
      HealthCheckKind.permission =>
        ok
            ? (l10n.healthPermissionOk, null)
            : (l10n.healthPermissionOff, l10n.healthPermissionOffDetail),
      HealthCheckKind.exactAlarms =>
        ok
            ? (l10n.healthExactOk, null)
            : (l10n.healthExactOff, l10n.healthExactOffDetail),
      HealthCheckKind.battery =>
        ok
            ? (l10n.healthBatteryOk, null)
            : (l10n.healthBatteryOff, l10n.healthBatteryOffDetail),
      HealthCheckKind.doNotDisturb =>
        ok
            ? (l10n.healthDndOff, null)
            : (l10n.healthDndOn, l10n.healthDndOnDetail),
      HealthCheckKind.sounds =>
        ok
            ? (l10n.healthSoundsOk, null)
            : (
                l10n.healthSoundsMuted(
                  check.mutedSounds.length,
                  _soundNames(l10n, check.mutedSounds),
                ),
                l10n.healthSoundsMutedDetail,
              ),
      HealthCheckKind.focus => (l10n.healthFocus, l10n.healthFocusDetail),
      HealthCheckKind.webPush =>
        ok
            ? (l10n.healthPushOk, null)
            : (l10n.healthPushOff, l10n.healthPushOffDetail),
      HealthCheckKind.clock => switch (check.skew) {
        final skew? => (clockSkewText(l10n, skew), l10n.healthClockOffDetail),
        null => (l10n.healthClockOk, null),
      },
    };
  }

  /// The button and what it does, for a problem that has a fix here.
  (String, Future<void> Function())? _fix(BuildContext context, WidgetRef ref) {
    if (check.level != HealthLevel.problem) return null;
    final l10n = context.l10n;
    return switch (check.kind) {
      HealthCheckKind.permission => (
        l10n.healthFixAllow,
        () async {
          final permission = ref.read(notificationPermissionProvider);
          if (await permission.status() == PermissionState.notAsked) {
            await permission.request();
          } else {
            await permission.openSettings();
          }
          ref.invalidate(notificationPermissionStateProvider);
        },
      ),
      HealthCheckKind.exactAlarms => (
        l10n.healthFixAllow,
        () async {
          await ref.read(exactAlarmsProvider).request();
          ref.invalidate(exactAlarmsAllowedProvider);
        },
      ),
      HealthCheckKind.battery => (
        l10n.healthFixOpen,
        () async {
          await ref.read(batteryOptimizationProvider).openSettings();
          ref.invalidate(powerStateProvider);
        },
      ),
      // The app's notification settings, where each sound's channel lives.
      HealthCheckKind.sounds => (
        l10n.healthFixOpen,
        () async {
          await ref.read(notificationPermissionProvider).openSettings();
          ref.invalidate(mutedSoundsProvider);
        },
      ),
      // The clock is the OS's own setting; the sentence says where.
      HealthCheckKind.clock ||
      HealthCheckKind.doNotDisturb ||
      HealthCheckKind.focus ||
      HealthCheckKind.webPush => null,
    };
  }
}

/// "Lift, Rooster": the muted sounds' names in the user's language.
String _soundNames(AppLocalizations l10n, List<String> ids) =>
    [for (final id in ids) soundDisplayName(l10n, resolveSound(id))].join(', ');
