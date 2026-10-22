import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/l10n/language_names.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/feedback/permission_notice.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The default alert offsets offered (minutes before; 0 = at start).
const _alertChoices = [null, 0, 5, 10, 15, 30];

/// REMINDERS (`A-ios-settings`): Task starts (the default alert, R-10) and
/// the Bedtime reminder.
class RemindersGroup extends ConsumerWidget {
  const RemindersGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final denied =
        ref.watch(notificationPermissionStateProvider).value ==
        PermissionState.denied;
    final group = _group(context);
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

  Widget _group(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    String label(int? m) => switch (m) {
      null => l10n.settingsAlertNone,
      0 => l10n.settingsAlertAtStart,
      final n => l10n.settingsAlertBefore(n),
    };
    final current = _firstOffset(settings.defaultAlerts);
    final bed = windowMinutes(commonWindow(settings).end);
    return SettingsGroup(
      caption: l10n.settingsReminders,
      children: [
        SettingsRow(
          glyph: DotGlyphs.bell,
          tint: t.colors.accentInk,
          title: l10n.settingsTaskStarts,
          value: label(current),
          onTap: () async {
            final picked = await showChoiceSheet<_Offset>(
              context,
              title: l10n.settingsTaskStarts,
              selected: _Offset(current),
              options: [
                for (final m in _alertChoices)
                  (value: _Offset(m), label: label(m), detail: null),
              ],
            );
            if (picked == null || !context.mounted) return;
            changeSettings(
              context,
              (s) => s.copyWith(defaultAlerts: _alertsFor(picked.minutes)),
            );
          },
        ),
        SettingsRow(
          glyph: DotGlyphs.moon,
          tint: t.tasks[TaskColor.violet].ink,
          title: l10n.settingsBedtimeReminder,
          subtitle: l10n.settingsBedtimeReminderDetail(
            clockText(context, bed, settings.use24h),
          ),
          toggle: settings.bedtimeReminder,
          onToggle: (v) =>
              changeSettings(context, (s) => s.copyWith(bedtimeReminder: v)),
        ),
      ],
    );
  }

  /// The offset of the first start alert; null = none.
  static int? _firstOffset(List<Alert> alerts) {
    for (final a in alerts) {
      if (a.kind == AlertKind.atStart) return 0;
      if (a.kind == AlertKind.before) return a.offsetMin;
    }
    return null;
  }

  static List<Alert> _alertsFor(int? minutes) => switch (minutes) {
    null => const [],
    0 => const [Alert(kind: AlertKind.atStart)],
    final m => [Alert(kind: AlertKind.before, offsetMin: m)],
  };
}

/// A nullable offset as a value: a dismissed sheet's null must not read
/// as "No alert".
@immutable
final class _Offset {
  const _Offset(this.minutes);

  final int? minutes;

  @override
  bool operator ==(Object other) =>
      other is _Offset && other.minutes == minutes;

  @override
  int get hashCode => minutes.hashCode;
}

/// LOOK and Language: Theme, Accent, Language (PRD F8).
class LookGroup extends StatelessWidget {
  const LookGroup({
    required this.settings,
    required this.locale,
    required this.onLocale,
    super.key,
  });

  final Settings settings;

  /// `profiles.locale`.
  final String locale;
  final ValueChanged<String> onLocale;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    String theme(ThemePreference p) => switch (p) {
      ThemePreference.system => l10n.settingsThemeSystem,
      ThemePreference.light => l10n.settingsThemeLight,
      ThemePreference.dark => l10n.settingsThemeDark,
    };
    return SettingsGroup(
      caption: l10n.settingsLook,
      children: [
        SettingsRow(
          glyph: DotGlyphs.sunrise,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.settingsTheme,
          value: theme(settings.theme),
          onTap: () async {
            final picked = await showChoiceSheet<ThemePreference>(
              context,
              title: l10n.settingsTheme,
              selected: settings.theme,
              options: [
                for (final p in ThemePreference.values)
                  (value: p, label: theme(p), detail: null),
              ],
            );
            if (picked != null && context.mounted) {
              changeSettings(context, (s) => s.copyWith(theme: picked));
            }
          },
        ),
        SettingsRow(
          glyph: DotGlyphs.today,
          tint: t.colors.accentInk,
          title: l10n.settingsAccent,
          below: _Accents(current: DotAccent.fromKey(settings.accent)),
        ),
        _language(context, t),
      ],
    );
  }

  Widget _language(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final names = {
      for (final l in AppLocalizations.supportedLocales)
        l.languageCode: languageName(l.languageCode),
    };
    return SettingsRow(
      glyph: DotGlyphs.globe,
      tint: t.tasks[TaskColor.sky].ink,
      title: l10n.settingsLanguage,
      value: names[locale] ?? names.values.first,
      onTap: () async {
        final picked = await showChoiceSheet<String>(
          context,
          title: l10n.settingsLanguage,
          selected: locale,
          options: [
            for (final MapEntry(key: code, value: name) in names.entries)
              (value: code, label: name, detail: null),
          ],
        );
        if (picked != null && picked != locale) onLocale(picked);
      },
    );
  }
}

/// The four accent swatches (docs/10 §2.1), the current one ringed.
class _Accents extends StatelessWidget {
  const _Accents({required this.current});

  final DotAccent current;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in DotAccent.values)
          Semantics(
            button: true,
            selected: a == current,
            label: l10n.settingsAccentLabel(
              taskColorName(l10n, TaskColor.fromKey(a.key)),
            ),
            excludeSemantics: true,
            child: InkResponse(
              onTap: () =>
                  changeSettings(context, (s) => s.copyWith(accent: a.key)),
              radius: DotTouch.min / 2,
              child: SizedBox.square(
                dimension: DotTouch.min,
                child: Center(
                  child: Container(
                    width: DotSize.pickerDot,
                    height: DotSize.pickerDot,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.colors.isDark ? a.dark : a.light,
                      border: a == current
                          ? Border.all(
                              color: t.colors.text,
                              width: DotSize.smallDotOutline,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
