import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Calendars (docs/09 M3f.7; import lands in M7, R-02): what
/// it is, the connected list (none yet) and whether shifting the day
/// moves calendar events too — that setting works today.
class CalendarsPage extends ConsumerWidget {
  const CalendarsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    return SettingsPageFrame(
      title: l10n.settingsCalendars,
      children: [
        PageText(l10n.calendarsIntro),
        SettingsGroup(
          caption: l10n.calendarsConnected,
          children: [
            SettingsRow(
              glyph: DotGlyphs.calendar,
              tint: t.colors.muted,
              title: l10n.calendarsNone,
            ),
          ],
        ),
        const OutlinedButton(onPressed: null, child: _ConnectLabel()),
        PageText(l10n.calendarsComingSoon),
        if (settings != null)
          SettingsGroup(
            caption: l10n.calendarsShifting,
            children: [
              SettingsRow(
                glyph: DotGlyphs.rollForward,
                tint: t.tasks[TaskColor.teal].ink,
                title: l10n.calendarsMoveEvents,
                subtitle: l10n.calendarsMoveEventsDetail,
                toggle: settings.includeCalendarInShift,
                onToggle: (v) => changeSettings(
                  context,
                  (s) => s.copyWith(includeCalendarInShift: v),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ConnectLabel extends StatelessWidget {
  const _ConnectLabel();

  @override
  Widget build(BuildContext context) => Text(context.l10n.calendarsConnect);
}

/// Settings › Export (docs/09 M3f.7; the files land in M8.1, R-11): the
/// formats to come, free, and today's way out (Copy day as text).
class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    SettingsRow format(DotGlyph glyph, String title, String detail) =>
        SettingsRow(
          glyph: glyph,
          tint: t.colors.muted,
          title: title,
          subtitle: detail,
        );
    return SettingsPageFrame(
      title: l10n.settingsExport,
      children: [
        PageText(l10n.exportIntro),
        SettingsGroup(
          caption: l10n.exportFormats,
          children: [
            format(DotGlyphs.share, l10n.exportJson, l10n.exportJsonDetail),
            format(DotGlyphs.week, l10n.exportCsv, l10n.exportCsvDetail),
            format(DotGlyphs.calendar, l10n.exportIcs, l10n.exportIcsDetail),
          ],
        ),
        PageText(l10n.exportComingSoon),
      ],
    );
  }
}
