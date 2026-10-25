import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/release/whats_new_seen.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/features/settings/whats_new_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';

/// The banner over a page, as the shell shows it (M8.2, R-19).
Future<ProviderContainer> _pump(
  WidgetTester tester,
  String seen, {
  ThemeMode mode = ThemeMode.light,
}) async {
  final container = ProviderContainer(
    overrides: [
      appVersionNameProvider.overrideWith((ref) async => '0.1.0'),
      whatsNewSeenProvider.overrideWith(() => FakeWhatsNewSeen(seen)),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: WhatsNewBanner()),
      ),
      GoRoute(
        path: AppRoutes.settingsPage(SettingsPage.changelog),
        builder: (_, _) => const Text('changelog'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('up to date: nothing', (tester) async {
    await _pump(tester, '0.1.0');
    expect(find.textContaining('is here'), findsNothing);
  });

  testWidgets('after an update: See what\'s new opens the changelog', (
    tester,
  ) async {
    final c = await _pump(tester, '0.0.9');
    expect(find.text('Dottoday 0.1.0 is here'), findsOneWidget);
    await expectA11yGuidelines(tester);
    await tester.tap(find.text("See what's new"));
    await tester.pumpAndSettle();
    expect(find.text('changelog'), findsOneWidget);
    expect(c.read(whatsNewSeenProvider).value, '0.1.0');
  });

  testWidgets('dark: meets a11y guidelines', (tester) async {
    await _pump(tester, '0.0.9', mode: ThemeMode.dark);
    await expectA11yGuidelines(tester);
  });

  testWidgets('Not now hides it until the next update', (tester) async {
    final c = await _pump(tester, '0.0.9');
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.textContaining('is here'), findsNothing);
    expect(c.read(whatsNewSeenProvider).value, '0.1.0');
  });
}
