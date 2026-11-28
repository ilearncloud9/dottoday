import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/l10n/language_names.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// FORMAT on Appearance (E-G3-9b, ED-161): Language, Time format and
/// Week starts on (R-20); on the web, its single-key shortcuts too.
class FormatGroup extends StatelessWidget {
  const FormatGroup({
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
    return SettingsGroup(
      caption: l10n.settingsFormat,
      children: [
        _language(context, t),
        _timeFormat(context, t),
        _weekStart(context, t),
        // Web only: its single-key shortcuts can be turned off (ED-095,
        // WCAG 2.1.4); Format is the nearest group.
        if (webChrome(context))
          SettingsRow(
            glyph: DotGlyphs.bolt,
            tint: t.tasks[TaskColor.teal].ink,
            title: l10n.settingsSingleKeys,
            subtitle: l10n.settingsSingleKeysHint,
            formLabel: l10n.settingsFormKeyboard,
            toggle: settings.webSingleKeys,
            onToggle: (on) =>
                changeSettings(context, (s) => s.copyWith(webSingleKeys: on)),
          ),
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
      tint: t.tasks[TaskColor.indigo].ink,
      title: l10n.settingsLanguage,
      value: names[locale] ?? names.values.first,
      choices: formChoices(
        values: names.keys,
        selected: locale,
        label: (code) => names[code]!,
        onPick: (code) {
          if (code != locale) onLocale(code);
        },
      ),
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

  Widget _weekStart(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String name(int iso) =>
        DateFormat.EEEE(locale).format(DateTime(2024, 1, iso));
    return SettingsRow(
      glyph: DotGlyphs.clockFace,
      tint: t.colors.secondary,
      title: l10n.settingsWeekStarts,
      value: name(settings.firstDayOfWeek),
      choices: formChoices(
        values: const [1, 7, 6],
        selected: settings.firstDayOfWeek,
        label: name,
        onPick: (d) =>
            changeSettings(context, (s) => s.copyWith(firstDayOfWeek: d)),
      ),
      onTap: () async {
        final picked = await showChoiceSheet<int>(
          context,
          title: l10n.settingsWeekStarts,
          selected: settings.firstDayOfWeek,
          options: [
            for (final d in const [1, 7, 6])
              (value: d, label: name(d), detail: null),
          ],
        );
        if (picked != null && context.mounted) {
          changeSettings(context, (s) => s.copyWith(firstDayOfWeek: picked));
        }
      },
    );
  }

  Widget _timeFormat(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final osIs24 = MediaQuery.alwaysUse24HourFormatOf(context);
    String label(_Format f) => switch (f) {
      _Format.h24 => l10n.settingsTime24,
      _Format.h12 => l10n.settingsTime12,
      _Format.device => l10n.settingsTimeSystem(
        osIs24 ? l10n.settingsTime24 : l10n.settingsTime12,
      ),
    };
    final current = _Format.of(settings.use24h);
    return SettingsRow(
      glyph: DotGlyphs.clock,
      tint: t.colors.secondary,
      title: l10n.settingsTimeFormat,
      value: label(current),
      choices: formChoices(
        values: _Format.values,
        selected: current,
        label: label,
        onPick: (f) =>
            changeSettings(context, (s) => s.copyWith(use24h: f.use24h)),
      ),
      onTap: () async {
        // An enum, not bool?: a dismissed sheet's null must not read as
        // "like this device".
        final picked = await showChoiceSheet<_Format>(
          context,
          title: l10n.settingsTimeFormat,
          selected: current,
          options: [
            for (final f in _Format.values)
              (value: f, label: label(f), detail: null),
          ],
        );
        if (picked == null || picked == current || !context.mounted) return;
        changeSettings(context, (s) => s.copyWith(use24h: picked.use24h));
      },
    );
  }
}

enum _Format {
  device(null),
  h12(false),
  h24(true);

  const _Format(this.use24h);

  final bool? use24h;

  static _Format of(bool? v) => values.firstWhere((f) => f.use24h == v);
}
