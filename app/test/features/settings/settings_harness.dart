import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/fln_exact_alarms.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/exact_alarms.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';
import 'package:dottoday/features/settings/pages/settings_pages.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/timeline_fakes.dart';

/// Records links instead of leaving the app.
final class FakeLinkLauncher implements LinkLauncher {
  final opened = <Uri>[];
  bool handled = true;

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return handled;
  }
}

/// What a Settings test can inspect.
typedef SettingsHarness = ({
  ProviderContainer container,
  FakeLinkLauncher links,
  FakeOccurrenceRepository occurrences,
});

/// Settings at 11:00 on the demo day for "Kody".
Future<SettingsHarness> pumpSettings(
  WidgetTester tester, {
  Settings settings = const Settings(use24h: true),
  Size size = const Size(390, 2600),
  ThemeMode mode = ThemeMode.light,
  TargetPlatform platform = TargetPlatform.iOS,
  List<Occurrence> rows = const [],
  String location = AppRoutes.settings,
  List<Override> overrides = const [],
  List<String> recentSearches = const [],
  NotificationPermission? permission,
  ExactAlarms exactAlarms = const AlwaysExactAlarms(),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final links = FakeLinkLauncher();
  final occurrences = FakeOccurrenceRepository(rows);
  final container = ProviderContainer(
    overrides: [
      ...timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 9),
        occurrences: occurrences,
        profile: testProfile(settings: settings).copyWith(displayName: 'Kody'),
        recentSearches: recentSearches,
        notificationPermission:
            permission ?? const UnwiredNotificationPermission(),
        exactAlarms: exactAlarms,
      ),
      linkLauncherProvider.overrideWithValue(links),
      appVersionProvider.overrideWith((ref) async => '0.1.0 (1)'),
      envProvider.overrideWithValue(
        Env(
          supabaseUrl: Uri.parse('https://example.supabase.co'),
          supabaseAnonKey: 'anon',
        ),
      ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  // Settings and its sub-pages (M3f.7), as the app routes them.
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: ':page',
            builder: (_, state) => settingsPageFor(
              SettingsPage.byName(state.pathParameters['page']!)!,
            ),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: DotTheme.light().copyWith(platform: platform),
        darkTheme: DotTheme.dark().copyWith(platform: platform),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (container: container, links: links, occurrences: occurrences);
}

/// The stored settings now.
Future<Settings> storedSettings(SettingsHarness h) async {
  final SettingsRepository repo = h.container.read(settingsRepositoryProvider);
  return (await repo.findLocalProfile())!.settings;
}

/// The stored profile now.
Future<Profile> storedProfile(SettingsHarness h) async =>
    (await h.container.read(settingsRepositoryProvider).findLocalProfile())!;
