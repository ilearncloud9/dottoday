import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// FORMAT on Appearance (M20.7 part 1, E-Phones): Week starts and Time
/// format (R-20), moved from Day shape.
class FormatGroup extends StatelessWidget {
  const FormatGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return SettingsGroup(
      caption: context.l10n.settingsFormat,
      children: [_weekStart(context, t), _timeFormat(context, t)],
    );
  }

  Widget _weekStart(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String name(int iso) =>
        DateFormat.EEEE(locale).format(DateTime(2024, 1, iso));
    return SettingsRow(
      glyph: DotGlyphs.calendar,
      tint: t.tasks[TaskColor.sky].ink,
      title: l10n.settingsWeekStarts,
      value: name(settings.firstDayOfWeek),
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
      tint: t.colors.muted,
      title: l10n.settingsTimeFormat,
      value: label(current),
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
