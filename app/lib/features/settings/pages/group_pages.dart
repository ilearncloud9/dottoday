import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/settings_places.dart';
import 'package:dottoday/features/settings/widgets/data_about_groups.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/learning_group.dart';
import 'package:dottoday/features/settings/widgets/planning_group.dart';
import 'package:dottoday/features/settings/widgets/reminders_group.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      children: groups,
    );
  }

  List<Widget> _groups(BuildContext context, Profile profile, Settings s) {
    final l10n = context.l10n;
    return switch (page) {
      SettingsPage.yourDay => [
        SettingsGroup(
          caption: l10n.settingsTheTwoEnds,
          children: const [PlaceRow(SettingsPage.wakeWindDown)],
        ),
        SettingsGroup(
          caption: l10n.settingsTheDayItself,
          children: const [PlaceRow(SettingsPage.learning)],
        ),
      ],
      SettingsPage.wakeWindDown => [DayShapeGroup(settings: s)],
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

/// A row that opens [page]: its icon, title and summary from its place.
class PlaceRow extends StatelessWidget {
  const PlaceRow(this.page, {super.key});

  final SettingsPage page;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final place = settingsPlace(context.l10n, page);
    return SettingsRow(
      glyph: place.glyph,
      tint: t.tasks[place.colour].ink,
      title: place.title,
      subtitle: place.summary,
      onTap: () => unawaited(context.push(AppRoutes.settingsPage(page))),
    );
  }
}
