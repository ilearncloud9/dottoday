import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/features/settings/widgets/health_summary_row.dart';
import 'package:dottoday/features/settings/widgets/quiet_hours_row.dart';
import 'package:dottoday/features/settings/widgets/reminder_sheets.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/feedback/permission_notice.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sounds/sound_options.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
import 'package:dottoday/shared/sounds/sound_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// REMINDERS (`A-ios-settings`, docs/02 F6.2, F6.6): Task starts (the
/// default alert set, up to 5, R-10), Sound, Quiet hours, Day-start
/// summary, the Wind Down reminder and Notification health.
class RemindersGroup extends ConsumerWidget {
  const RemindersGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final denied =
        ref.watch(notificationPermissionStateProvider).value ==
        PermissionState.denied;
    final group = _group(context, ref);
    final exact = ref.watch(exactAlarmsAllowedProvider).value ?? true;
    if (!denied && !exact) {
      // Reminders still come, maybe late: say why and offer the fix (M5.6).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          ExactAlarmNotice(
            onAllow: () async {
              await ref.read(exactAlarmsProvider).request();
              ref.invalidate(exactAlarmsAllowedProvider);
            },
          ),
          group,
        ],
      );
    }
    if (!denied) return group;
    // Notifications are off: say so above the rows (M3f.8, 03 §3.8).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        PermissionNotice(
          onOpenSettings: () async {
            final opened = await ref
                .read(notificationPermissionProvider)
                .openSettings();
            ref.invalidate(notificationPermissionStateProvider);
            return opened;
          },
        ),
        group,
      ],
    );
  }

  Widget _group(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final form = settingsFormAt(context);
    final sounds = form ? settingsSoundSections(l10n) : const <SoundSection>[];
    return SettingsGroup(
      caption: l10n.settingsReminders,
      children: [
        if (form)
          _AlertChips(
            alerts: settings.defaultAlerts,
            onAdd: () => unawaited(_editAlerts(context)),
          )
        else
          SettingsRow(
            glyph: DotGlyphs.bell,
            tint: t.colors.accentInk,
            title: l10n.settingsTaskStarts,
            value: alertSetText(l10n, settings.defaultAlerts),
            onTap: () => unawaited(_editAlerts(context)),
          ),
        SettingsRow(
          glyph: DotGlyphs.sound,
          tint: t.tasks[TaskColor.sky].ink,
          title: l10n.settingsSound,
          // Unset is the Dot tone; "system" the OS sound (docs/12 §3).
          value: reminderSoundName(l10n, settings.reminderSound),
          // The Mac/web form picks here and previews; All sounds… opens
          // the page (ED-450).
          choices: form ? _soundChoices(context, ref, sounds) : null,
          choiceHeaders: _soundHeaders(sounds),
          formButton: l10n.remindersAllSounds,
          onTap: () => unawaited(
            context.push(AppRoutes.settingsPage(SettingsPage.sounds)),
          ),
        ),
        QuietHoursRow(settings: settings),
        SettingsRow(
          glyph: DotGlyphs.sunrise,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.settingsDaySummary,
          value: daySummaryText(context, settings.daySummaryDays),
          onTap: () => unawaited(showDaySummarySheet(context)),
        ),
        const HealthSummaryRow(),
      ],
    );
  }

  List<FormChoice> _soundChoices(
    BuildContext context,
    WidgetRef ref,
    List<SoundSection> sections,
  ) {
    final selected = settings.reminderSound ?? defaultReminderSoundId;
    return [
      for (final section in sections)
        for (final o in section.options)
          (
            label: o.label,
            selected: o.key == selected,
            onSelect: () {
              changeSettings(context, (s) => s.copyWith(reminderSound: o.key));
              previewSound(ref, o.key);
            },
          ),
    ];
  }

  /// Each section's caption at its first sound.
  static Map<int, String> _soundHeaders(List<SoundSection> sections) {
    final headers = <int, String>{};
    var i = 0;
    for (final section in sections) {
      headers[i] = section.caption;
      i += section.options.length;
    }
    return headers;
  }

  /// The shared Alerts editor on the default set (F6.2): new tasks start
  /// with what it returns.
  Future<void> _editAlerts(BuildContext context) async {
    final picked = await showAlertsEditor(
      context,
      initial: settings.defaultAlerts,
    );
    if (picked == null || !context.mounted) return;
    if (_same(picked, settings.defaultAlerts)) return;
    changeSettings(context, (s) => s.copyWith(defaultAlerts: picked));
  }

  static bool _same(List<Alert> a, List<Alert> b) =>
      a.length == b.length && a.indexed.every((e) => b[e.$1] == e.$2);
}

/// Task starts on a Mac/web form (ED-450): each default alert a chip
/// with ×, then Add… (the Alerts editor); "No alert" when there are none.
class _AlertChips extends StatelessWidget {
  const _AlertChips({required this.alerts, required this.onAdd});

  final List<Alert> alerts;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return FormLine(
      label: l10n.settingsTaskStarts,
      child: Wrap(
        spacing: DotSpace.s,
        runSpacing: DotSpace.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (alerts.isEmpty)
            Text(l10n.settingsAlertNone, style: t.styles.inspectorValue),
          for (final (i, a) in alerts.indexed)
            InputChip(
              label: Text(_alertText(l10n, a)),
              labelStyle: t.styles.inspectorValue,
              visualDensity: VisualDensity.compact,
              deleteButtonTooltipMessage: l10n.remindersRemoveAlert(
                _alertText(l10n, a),
              ),
              onDeleted: () => changeSettings(
                context,
                (s) => s.copyWith(defaultAlerts: [...alerts]..removeAt(i)),
              ),
            ),
          FormButton(label: l10n.remindersAddAlert, onPressed: onAdd),
        ],
      ),
    );
  }
}

/// "No alert", "10 min before", "10 min before +2".
String alertSetText(AppLocalizations l10n, List<Alert> alerts) =>
    switch (alerts) {
      [] => l10n.settingsAlertNone,
      [final only] => _alertText(l10n, only),
      [final first, ...final rest] => l10n.settingsAlertsMore(
        _alertText(l10n, first),
        rest.length,
      ),
    };

/// One alert as a Settings value: "When it starts", "10 min before",
/// "At end" (the editor's chip labels are mid-sentence lower case).
String _alertText(AppLocalizations l10n, Alert a) => switch (a.kind) {
  AlertKind.before => l10n.settingsAlertBefore(a.offsetMin),
  AlertKind.atStart => l10n.settingsAlertAtStart,
  AlertKind.atEnd || AlertKind.overdue => _capitalized(alertLabel(l10n, a)),
};

String _capitalized(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
