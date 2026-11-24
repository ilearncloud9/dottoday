import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';

/// The Settings root's six groups, in order (ED-081, E-Phones).
const settingsRootGroups = [
  SettingsPage.yourDay,
  SettingsPage.planning,
  SettingsPage.reminders,
  SettingsPage.appearance,
  SettingsPage.dataPrivacy,
  SettingsPage.helpAbout,
];

/// Where a Settings page sits (M20.7 part 1): its title, the summary its
/// row shows, its icon and colour (the row's and the page title's, ED-338)
/// and the page its ‹ returns to (null: the Settings root).
typedef SettingsPlace = ({
  String title,
  String? summary,
  DotGlyph glyph,
  TaskColor colour,
  SettingsPage? parent,
});

/// [page]'s place in Settings.
SettingsPlace settingsPlace(AppLocalizations l10n, SettingsPage page) =>
    switch (page) {
      SettingsPage.yourDay => (
        title: l10n.settingsChoiceYourDay,
        summary: l10n.settingsYourDaySummary,
        glyph: DotGlyphs.sun,
        colour: TaskColor.amber,
        parent: null,
      ),
      SettingsPage.planning => (
        title: l10n.settingsPlanning,
        summary: l10n.settingsPlanningSummary,
        glyph: DotGlyphs.plan,
        colour: TaskColor.teal,
        parent: null,
      ),
      SettingsPage.reminders => (
        title: l10n.settingsReminders,
        summary: l10n.settingsRemindersSummary,
        glyph: DotGlyphs.bell,
        colour: TaskColor.violet,
        parent: null,
      ),
      SettingsPage.appearance => (
        title: l10n.settingsAppearance,
        summary: l10n.settingsAppearanceSummary,
        glyph: DotGlyphs.palette,
        colour: TaskColor.rose,
        parent: null,
      ),
      SettingsPage.dataPrivacy => (
        title: l10n.settingsDataAndPrivacy,
        summary: l10n.settingsDataAndPrivacySummary,
        glyph: DotGlyphs.lock,
        colour: TaskColor.mint,
        parent: null,
      ),
      SettingsPage.helpAbout => (
        title: l10n.settingsHelpAndAbout,
        summary: l10n.settingsHelpAndAboutSummary,
        glyph: DotGlyphs.help,
        colour: TaskColor.slate,
        parent: null,
      ),
      SettingsPage.wakeWindDown => (
        title: l10n.settingsWakeWindDown,
        summary: null,
        glyph: DotGlyphs.moon,
        colour: TaskColor.violet,
        parent: SettingsPage.yourDay,
      ),
      SettingsPage.learning => (
        title: l10n.settingsLearnMyDay,
        summary: l10n.settingsLearnMyDaySummary,
        glyph: DotGlyphs.review,
        colour: TaskColor.slate,
        parent: SettingsPage.yourDay,
      ),
      SettingsPage.wakeUp => (
        title: l10n.settingsWakeUpOptions,
        summary: null,
        glyph: DotGlyphs.sound,
        colour: TaskColor.amber,
        parent: SettingsPage.wakeWindDown,
      ),
      SettingsPage.missions => (
        title: l10n.settingsMissions,
        summary: null,
        glyph: DotGlyphs.bolt,
        colour: TaskColor.amber,
        parent: SettingsPage.wakeWindDown,
      ),
      SettingsPage.alarmDevice => (
        title: l10n.settingsAlarmSoundsOn,
        summary: null,
        glyph: TaskIcon.flipphone.glyph!,
        colour: TaskColor.slate,
        parent: SettingsPage.wakeWindDown,
      ),
      SettingsPage.varySound => (
        title: l10n.wakeUpVary,
        summary: null,
        glyph: DotGlyphs.repeat,
        colour: TaskColor.violet,
        parent: SettingsPage.wakeWindDown,
      ),
      SettingsPage.notifications => (
        title: l10n.healthTitle,
        summary: null,
        glyph: DotGlyphs.bell,
        colour: TaskColor.violet,
        parent: SettingsPage.reminders,
      ),
      SettingsPage.sounds => (
        title: l10n.soundsTitle,
        summary: null,
        glyph: DotGlyphs.sound,
        colour: TaskColor.violet,
        parent: SettingsPage.reminders,
      ),
      SettingsPage.calendars => (
        title: l10n.settingsCalendars,
        summary: null,
        glyph: DotGlyphs.calendar,
        colour: TaskColor.sky,
        parent: SettingsPage.dataPrivacy,
      ),
      SettingsPage.export => (
        title: l10n.settingsExport,
        summary: null,
        glyph: DotGlyphs.share,
        colour: TaskColor.mint,
        parent: SettingsPage.dataPrivacy,
      ),
      SettingsPage.privacy => (
        title: l10n.settingsPrivacy,
        summary: null,
        glyph: DotGlyphs.shield,
        colour: TaskColor.mint,
        parent: SettingsPage.dataPrivacy,
      ),
      SettingsPage.routines => (
        title: l10n.routinesTitle,
        summary: null,
        glyph: DotGlyphs.repeat,
        colour: TaskColor.teal,
        parent: SettingsPage.planning,
      ),
      SettingsPage.help => (
        title: l10n.settingsHelp,
        summary: null,
        glyph: DotGlyphs.help,
        colour: TaskColor.slate,
        parent: SettingsPage.helpAbout,
      ),
      SettingsPage.about => (
        title: l10n.settingsAboutApp,
        summary: null,
        glyph: DotGlyphs.info,
        colour: TaskColor.slate,
        parent: SettingsPage.helpAbout,
      ),
      SettingsPage.changelog => (
        title: l10n.settingsWhatsNew,
        summary: null,
        glyph: DotGlyphs.bolt,
        colour: TaskColor.slate,
        parent: SettingsPage.helpAbout,
      ),
      SettingsPage.siri => (
        title: l10n.settingsSiri,
        summary: null,
        glyph: DotGlyphs.mic,
        colour: TaskColor.slate,
        parent: SettingsPage.helpAbout,
      ),
      SettingsPage.account => (
        title: l10n.settingsAccount,
        summary: null,
        glyph: DotGlyphs.person,
        colour: TaskColor.slate,
        parent: null,
      ),
      SettingsPage.everything => (
        title: l10n.settingsEverythingElse,
        summary: null,
        glyph: DotGlyphs.more,
        colour: TaskColor.slate,
        parent: null,
      ),
    };
