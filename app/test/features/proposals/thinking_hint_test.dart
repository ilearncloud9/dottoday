import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:dottoday/features/proposals/thinking_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/a11y.dart';
import '../../support/fake_seen_tips.dart';

// The proposal hint (docs/09 M14.2, D4): a tap closes the proposal (the
// caller's onOpen — nothing is written) and opens Settings › Privacy; ×
// puts it away for good; nothing for a device that can't run the model.

Future<(ProviderContainer, List<String>)> _pump(
  WidgetTester tester, {
  ThinkingAvailability availability = ThinkingAvailability.notEnabled,
  ThinkingVendor vendor = ThinkingVendor.appleMac,
  Set<Tip> seen = const {},
  ThemeMode mode = ThemeMode.light,
}) async {
  final closed = <String>[];
  final c = ProviderContainer(
    overrides: [
      thinkingStatusProvider.overrideWith(
        (ref) async =>
            ThinkingStatus(availability: availability, vendor: vendor),
      ),
      seenTipsProvider.overrideWith(() => FakeSeenTips(seen)),
    ],
  );
  addTearDown(c.dispose);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(DotSpace.page),
            child: ThinkingHint(onOpen: () => closed.add('closed')),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPage(SettingsPage.privacy),
        builder: (_, _) => const Text('privacy page'),
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
  return (c, closed);
}

const _mac =
    'Made with simple rules · Turn on Apple Intelligence for smarter plans';

void main() {
  testWidgets('a tap closes the proposal and opens Privacy', (tester) async {
    final (_, closed) = await _pump(tester);
    await tester.tap(find.bySemanticsLabel(_mac));
    await tester.pumpAndSettle();
    expect(closed, ['closed']);
    expect(find.text('privacy page'), findsOneWidget);
  });

  testWidgets("Don't show again puts it away", (tester) async {
    final (c, _) = await _pump(tester);
    await tester.tap(find.byTooltip("Don't show again"));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(_mac), findsNothing);
    expect(c.read(seenTipsProvider).value, contains(Tip.thinkingHint));
  });

  testWidgets('never once put away', (tester) async {
    await _pump(tester, seen: {Tip.thinkingHint});
    expect(find.bySemanticsLabel(_mac), findsNothing);
  });

  for (final vendor in ThinkingVendor.values) {
    testWidgets('never when ${vendor.name} is not eligible', (tester) async {
      await _pump(
        tester,
        availability: ThinkingAvailability.notEligible,
        vendor: vendor,
      );
      expect(find.byType(InkWell), findsNothing);
    });
  }

  testWidgets('Gemini Nano downloading words it for Android', (tester) async {
    await _pump(
      tester,
      availability: ThinkingAvailability.downloading,
      vendor: ThinkingVendor.google,
    );
    expect(
      find.bySemanticsLabel(
        "Made with simple rules · Gemini Nano makes smarter plans once it's "
        'on this phone',
      ),
      findsOneWidget,
    );
  });

  for (final mode in ThemeMode.values.skip(1)) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, mode: mode);
      await expectA11yGuidelines(tester);
      handle.dispose();
    });
  }
}
