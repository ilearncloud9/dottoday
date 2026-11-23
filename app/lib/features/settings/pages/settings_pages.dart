import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/settings/appearance/appearance_page.dart';
import 'package:dottoday/features/settings/pages/about_page.dart';
import 'package:dottoday/features/settings/pages/account_page.dart';
import 'package:dottoday/features/settings/pages/calendars_page.dart';
import 'package:dottoday/features/settings/pages/changelog_page.dart';
import 'package:dottoday/features/settings/pages/data_pages.dart';
import 'package:dottoday/features/settings/pages/everything_page.dart';
import 'package:dottoday/features/settings/pages/group_pages.dart';
import 'package:dottoday/features/settings/pages/info_pages.dart';
import 'package:dottoday/features/settings/pages/notification_health_page.dart';
import 'package:dottoday/features/settings/pages/siri_page.dart';
import 'package:dottoday/features/settings/pages/sounds_page.dart';
import 'package:dottoday/features/settings/wake_wind/wake_wind_page.dart';
import 'package:flutter/widgets.dart';

/// The page at `/settings/<page>` (docs/09 M3f.7).
Widget settingsPageFor(SettingsPage page) => switch (page) {
  SettingsPage.account => const AccountPage(),
  SettingsPage.notifications => const NotificationHealthPage(),
  SettingsPage.sounds => const SoundsPage(),
  // Wake Up options is part of Wake Up and Wind Down now (ED-084); its
  // links land there.
  SettingsPage.wakeUp || SettingsPage.wakeWindDown => const WakeWindDownPage(),
  SettingsPage.calendars => const CalendarsPage(),
  // Composed in app_screens (features don't import each other).
  SettingsPage.routines => const SizedBox.shrink(),
  SettingsPage.export => const ExportPage(),
  SettingsPage.help => const HelpPage(),
  SettingsPage.privacy => const PrivacyPage(),
  SettingsPage.about => const AboutPage(),
  SettingsPage.changelog => const ChangelogPage(),
  SettingsPage.siri => const SiriPage(),
  SettingsPage.everything => const EverythingPage(),
  SettingsPage.appearance => const AppearancePage(),
  SettingsPage.yourDay ||
  SettingsPage.planning ||
  SettingsPage.reminders ||
  SettingsPage.dataPrivacy ||
  SettingsPage.helpAbout ||
  SettingsPage.learning => SettingsGroupPage(page: page),
};
