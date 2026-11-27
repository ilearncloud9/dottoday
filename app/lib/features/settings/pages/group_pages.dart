import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/intents/siri_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:dottoday/features/settings/settings_places.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/features/settings/widgets/data_about_groups.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/learning_group.dart';
import 'package:dottoday/features/settings/widgets/planning_group.dart';
import 'package:dottoday/features/settings/widgets/reminders_group.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Settings group's page (M20.7 part 1, E-Phones Settings): the root's
/// six groups and the pages under Your day. Until parts 2–4 restyle them
/// they hold today's rows, each on its group's page.
class SettingsGroupPage extends ConsumerWidget {
  const SettingsGroupPage({required this.page, super.key});

  final SettingsPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final groups = profile == null
        ? const <Widget>[]
        : _groups(context, profile, profile.settings);
    return SettingsPageFrame(
      title: settingsPlace(context.l10n, page).title,
      page: page,
      singleGroup: groups.length == 1,
      // Drawn for the Mac and the web (ED-450); Help and about isn't.
      form: page != SettingsPage.helpAbout,
      children: groups,
    );
  }

  List<Widget> _groups(BuildContext context, Profile profile, Settings s) {
    final l10n = context.l10n;
    return switch (page) {
      SettingsPage.yourDay => [
        SettingsGroup(
          caption: l10n.settingsTheTwoEnds,
          list: true,
          children: [
            PlaceRow(
              SettingsPage.wakeWindDown,
              // The week at a glance on a Mac/web form (ED-450).
              summary: settingsFormFits(context) ? _week(context, s) : null,
            ),
          ],
        ),
        SettingsGroup(
          caption: l10n.settingsTheDayItself,
          list: true,
          children: const [PlaceRow(SettingsPage.learning)],
        ),
      ],
      SettingsPage.learning => [LearningGroup(settings: s)],
      SettingsPage.planning => [PlanningGroup(settings: s)],
      SettingsPage.reminders => [RemindersGroup(settings: s)],
      SettingsPage.dataPrivacy => const [DataGroup(), PrivacyGroup()],
      SettingsPage.helpAbout => const [AboutGroup()],
      // Their own pages (settingsPageFor), never a group page.
      _ => const <Widget>[],
    };
  }
}

/// "Weekdays 6:30 AM · 11:00 PM, Weekend 8:30 AM · 12:30 AM".
String _week(BuildContext context, Settings s) {
  final l10n = context.l10n;
  return [
    for (final d in schedulesOf(s, firstDay: s.firstDayOfWeek))
      l10n.yourDayScheduleLine(
        scheduleName(l10n, d.days),
        clockText(context, windowMinutes(d.window.start), s.use24h),
        clockText(context, windowMinutes(d.window.end), s.use24h),
      ),
  ].reduce(l10n.listJoin);
}

/// A row that opens [page]: its icon, title and summary from its place.
/// Help and about names Siri only where its page has the Siri row
/// (ED-499).
class PlaceRow extends ConsumerWidget {
  const PlaceRow(this.page, {this.summary, super.key});

  final SettingsPage page;

  /// In place of the place's own summary.
  final String? summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final place = settingsPlace(context.l10n, page);
    final noSiri =
        page == SettingsPage.helpAbout && !ref.watch(siriAvailableProvider);
    return SettingsRow(
      glyph: place.glyph,
      tint: t.tasks[place.colour].ink,
      title: place.title,
      subtitle:
          summary ??
          (noSiri
              ? context.l10n.settingsHelpAndAboutSummaryNoSiri
              : place.summary),
      selected: SettingsPaneScope.selectedAt(context, page),
      onTap: () => openSettingsPage(context, page),
    );
  }
}
