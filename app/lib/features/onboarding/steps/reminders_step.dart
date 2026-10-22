import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:dottoday/shared/feedback/permission_notice.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O4 Reminders (docs/10 §5.1, docs/09 M4.4): the two kinds (before each
/// task; at Bedtime, with its switch), then Allow notifications (the
/// system prompt) or Not now. Denied → the M3f.8 notice, and on. The
/// "Connect a calendar" row arrives with calendar import (M7.1).
class RemindersStep extends ConsumerStatefulWidget {
  const RemindersStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<RemindersStep> createState() => _RemindersStepState();
}

/// A leaf: only whether the system said no.
class _RemindersStepState extends ConsumerState<RemindersStep> {
  var _denied = false;

  Future<void> _allow() async {
    final answer = await ref.read(notificationPermissionProvider).request();
    ref.invalidate(notificationPermissionStateProvider);
    if (!mounted) return;
    if (answer == PermissionState.granted) return widget.onNext();
    setState(() => _denied = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final bedtime =
        ref.watch(currentProfileProvider).value?.settings.bedtimeReminder ??
        false;
    final permission = ref.read(notificationPermissionProvider);
    return StepFrame(
      title: l10n.onboardingRemindersTitle,
      body: l10n.onboardingRemindersBody,
      primary: _denied ? l10n.onboardingContinue : l10n.onboardingAllow,
      onPrimary: _denied ? widget.onNext : () => unawaited(_allow()),
      secondary: _denied ? null : l10n.onboardingNotNow,
      onSecondary: widget.onNext,
      children: [
        SettingsGroup(
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
            SettingsRow(
              glyph: DotGlyphs.calendar,
              tint: t.colors.muted,
              title: l10n.calendarsConnect,
              subtitle: l10n.calendarsComingSoon,
            ),
          ],
        ),
        if (_denied) PermissionNotice(onOpenSettings: permission.openSettings),
      ],
    );
  }
}
