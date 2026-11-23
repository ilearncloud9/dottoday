import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/features/settings/appearance/layout_row.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/health_summary_row.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Minimal Settings (docs/14 §4): one page, nine rows, no sections —
/// Layout, Wake Up, Wake Up alarm, Wake Up options, Wind Down, Remind me
/// when a dot starts, Calendars, Account and sync, Everything else… — and
/// the test alarm card under them. Notification health shows above them
/// only while something is off.
class MinimalSettings extends ConsumerWidget {
  const MinimalSettings({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final checks = ref.watch(notificationHealthChecksProvider).value;
    final off = checks != null && healthProblems(checks) > 0;
    final alarm = ref.read(testAlarmProvider.notifier);
    void open(SettingsPage page) =>
        unawaited(context.push(AppRoutes.settingsPage(page)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xl,
      children: [
        if (off)
          const SettingsGroup(caption: '', children: [HealthSummaryRow()]),
        SettingsGroup(
          caption: '',
          children: [
            const LayoutRow(),
            ...DayShapeGroup(settings: settings).times(context),
            SettingsRow(
              glyph: DotGlyphs.bell,
              tint: t.colors.accentInk,
              title: l10n.settingsRemindDotStarts,
              toggle: settings.defaultAlerts.isNotEmpty,
              // On/off over the existing default alert: at the start, or
              // none (docs/14 §3 "Notifications"); no new setting.
              onToggle: (on) => changeSettings(
                context,
                (s) => s.copyWith(
                  defaultAlerts: on
                      ? const [Alert(kind: AlertKind.atStart)]
                      : const [],
                ),
              ),
            ),
            SettingsRow(
              glyph: DotGlyphs.calendar,
              tint: t.colors.accentInk,
              title: l10n.settingsCalendars,
              onTap: () => open(SettingsPage.calendars),
            ),
            SettingsRow(
              glyph: DotGlyphs.person,
              tint: t.colors.accentInk,
              title: l10n.settingsAccountAndSync,
              onTap: () => open(SettingsPage.account),
            ),
            SettingsRow(
              glyph: DotGlyphs.more,
              tint: t.colors.muted,
              title: l10n.settingsEverythingElse,
              onTap: () => open(SettingsPage.everything),
            ),
          ],
        ),
        TestAlarmCard(
          onSend: alarm.send,
          onCancel: alarm.cancel,
          now: ref.read(clockProvider).nowUtc,
          afterNo: l10n.testAlarmLookLater,
        ),
      ],
    );
  }
}
