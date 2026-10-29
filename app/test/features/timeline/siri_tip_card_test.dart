import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/features/timeline/widgets/siri_tip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/a11y.dart';
import '../../support/fake_seen_tips.dart';

// Today's Siri card (docs/09 M14.3, D3): shown when due, Show me opens
// Settings › Siri & Shortcuts, and either button puts it away for good.

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  bool due = true,
  ThemeMode mode = ThemeMode.light,
}) async {
  final c = ProviderContainer(
    overrides: [
      seenTipsProvider.overrideWith(FakeSeenTips.new),
      // As the real one: due until put away.
      siriTipDueProvider.overrideWith((ref) async* {
        final seen = await ref.watch(seenTipsProvider.future);
        yield due && !seen.contains(Tip.siriToday);
      }),
    ],
  );
  addTearDown(c.dispose);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            const Scaffold(body: Column(children: [SiriTipCard()])),
      ),
      GoRoute(
        path: AppRoutes.settingsPage(SettingsPage.siri),
        builder: (_, _) => const Text('siri page'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
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
  return c;
}

const _tip = 'Ask Siri "What\'s next in Dottoday"';

void main() {
  testWidgets('not due: nothing', (tester) async {
    await _pump(tester, due: false);
    expect(find.text(_tip), findsNothing);
  });

  testWidgets('Show me opens the Siri page and puts it away', (tester) async {
    final c = await _pump(tester);
    expect(find.text(_tip), findsOneWidget);
    await tester.tap(find.text('Show me'));
    await tester.pumpAndSettle();
    expect(find.text('siri page'), findsOneWidget);
    expect(c.read(seenTipsProvider).value, contains(Tip.siriToday));
  });

  testWidgets("Don't show again: gone for good", (tester) async {
    final c = await _pump(tester);
    await tester.tap(find.text("Don't show again"));
    await tester.pumpAndSettle();
    expect(find.text(_tip), findsNothing);
    expect(c.read(seenTipsProvider).value, contains(Tip.siriToday));
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, mode: mode);
      await expectA11yGuidelines(tester);
      handle.dispose();
    });
  }
}
