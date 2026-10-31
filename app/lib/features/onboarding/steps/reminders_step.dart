import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:dottoday/shared/feedback/permission_notice.dart';
import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O4 Reminders (docs/10 §5.1, docs/09 M4.4): the two kinds (before each
/// task; at Wind Down, with its switch), then Allow notifications (the
/// system prompt) or Not now. Denied → the M3f.8 notice, and on. Allowed
/// → "Send me a test alarm" (M6.5.9, skippable) and Continue. "Connect a
/// calendar" asks for the device calendars (M7.1); which ones come in is
/// chosen in Settings › Calendars.
class RemindersStep extends ConsumerStatefulWidget {
  const RemindersStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<RemindersStep> createState() => _RemindersStepState();
}

/// A leaf: only whether the system said no.
class _RemindersStepState extends ConsumerState<RemindersStep> {
  var _denied = false;
  var _granted = false;

  Future<void> _allow() async {
    final answer = await ref.read(notificationPermissionProvider).request();
    ref.invalidate(notificationPermissionStateProvider);
    if (!mounted) return;
    // Allowed: stay to offer the test alarm; Continue moves on (M6.5.9).
    setState(() {
      _granted = answer == PermissionState.granted;
      _denied = !_granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final bedtime =
        ref.watch(currentProfileProvider).value?.settings.bedtimeReminder ??
        false;
    final permission = ref.read(notificationPermissionProvider);
    final granted =
        _granted ||
        ref.watch(notificationPermissionStateProvider).value ==
            PermissionState.granted;
    final decided = _denied || granted;
    final alarm = ref.read(testAlarmProvider.notifier);
    return StepFrame(
      title: l10n.onboardingRemindersTitle,
      body: l10n.onboardingRemindersBody,
      primary: decided ? l10n.onboardingContinue : l10n.onboardingAllow,
      onPrimary: decided ? widget.onNext : () => unawaited(_allow()),
      secondary: decided ? null : l10n.onboardingNotNow,
      onSecondary: widget.onNext,
      children: [
        _rows(context, t, l10n, bedtime),
        if (granted)
          TestAlarmCard(
            onSend: alarm.send,
            onCancel: alarm.cancel,
            now: ref.read(clockProvider).nowUtc,
            afterNo: l10n.testAlarmLookLater,
          ),
        if (_denied) PermissionNotice(onOpenSettings: permission.openSettings),
        // Minimal asks for no setting with a default (docs/14 §4, §7):
        // calendars wait for Settings.
        if (!watchSimplified(ref, FeatureId.onboardingExtras))
          const _ConnectCalendar(),
      ],
    );
  }

  /// Before each task, At Wind Down (its switch).
  Widget _rows(
    BuildContext context,
    DotTheme t,
    AppLocalizations l10n,
    bool bedtime,
  ) => SettingsGroup(
    caption: l10n.settingsReminders,
    children: [
      SettingsRow(
        glyph: DotGlyphs.bell,
        tint: t.colors.accentInk,
        title: l10n.onboardingTaskStarts,
        subtitle: l10n.onboardingTaskStartsDetail,
      ),
      SettingsRow(
        glyph: DotGlyphs.moon,
        tint: t.tasks[TaskColor.violet].ink,
        title: l10n.onboardingBedtime,
        subtitle: l10n.onboardingBedtimeDetail,
        toggle: bedtime,
        onToggle: (on) => unawaited(
          updateSettings(
            ProviderScope.containerOf(context, listen: false),
            (s) => s.copyWith(bedtimeReminder: on),
          ),
        ),
      ),
    ],
  );
}

/// The optional "Connect a calendar" row (docs/10 §5.1 O4, PRD F5): the
/// OS prompt on tap; allowed → connected, choose in Settings; denied →
/// the calendar notice. Off where there are no device calendars yet.
class _ConnectCalendar extends ConsumerWidget {
  const _ConnectCalendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final gateway = ref.watch(deviceCalendarGatewayProvider);
    final state = ref.watch(calendarPermissionStateProvider).value;
    final connected = state == PermissionState.granted;
    final row = SettingsRow(
      glyph: DotGlyphs.calendar,
      tint: gateway.available ? t.colors.accentInk : t.colors.muted,
      title: l10n.calendarsConnect,
      subtitle: !gateway.available
          ? l10n.calendarsOnlineInSettings
          : connected
          ? l10n.calendarsPickInSettings
          : null,
      onTap: gateway.available && !connected
          ? () => unawaited(ref.read(calendarActionsProvider).connect())
          : null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        SettingsGroup(caption: l10n.settingsCalendars, children: [row]),
        if (gateway.available && state == PermissionState.denied)
          PermissionNotice(
            permission: AppPermission.calendar,
            onOpenSettings: gateway.openSettings,
          ),
      ],
    );
  }
}
