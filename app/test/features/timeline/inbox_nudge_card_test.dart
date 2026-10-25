import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_nudge_seen.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/widgets/inbox_nudge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/a11y.dart';
import '../../support/sample_inbox.dart';

// "Plan your inbox", once a day (docs/02 F3.3, docs/09 M8.4c).

final _today = DateTime(2026, 10, 21);
final _shape = DayShape(
  wakeUtc: DateTime.utc(2026, 10, 21, 5),
  bedUtc: DateTime.utc(2026, 10, 21, 20),
);

final class _FakeSeen extends InboxNudgeSeen {
  _FakeSeen(this.initial);

  final DateTime? initial;

  @override
  Future<DateTime?> build() async => initial;

  @override
  Future<void> putAway(DateTime day) async => state = AsyncData(day);
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  bool enabled = true,
  DateTime? putAwayOn,
  ThemeMode mode = ThemeMode.light,
}) async {
  final container = ProviderContainer(
    overrides: [
      inboxNudgeSeenProvider.overrideWith(() => _FakeSeen(putAwayOn)),
      inboxItemsProvider.overrideWith((ref) => Stream.value(sampleInbox())),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: InboxNudgeCard(
            enabled: enabled,
            today: _today,
            shape: _shape,
            now: DateTime.utc(2026, 10, 21, 6),
          ),
        ),
      ),
      GoRoute(path: AppRoutes.inbox, builder: (_, _) => const Text('inbox')),
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
  testWidgets('off by default: nothing', (tester) async {
    await _pump(tester, enabled: false);
    expect(find.text('PLAN YOUR INBOX'), findsNothing);
  });

  testWidgets('on: Plan opens the Inbox and puts it away for today', (
    tester,
  ) async {
    final c = await _pump(tester);
    expect(find.text('PLAN YOUR INBOX'), findsOneWidget);
    expect(find.textContaining('waiting in your Inbox'), findsOneWidget);
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(find.text('inbox'), findsOneWidget);
    expect(c.read(inboxNudgeSeenProvider).value, _today);
  });

  testWidgets('Not now puts it away', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('PLAN YOUR INBOX'), findsNothing);
  });

  testWidgets('put away today stays away', (tester) async {
    await _pump(tester, putAwayOn: _today);
    expect(find.text('PLAN YOUR INBOX'), findsNothing);
  });

  testWidgets('put away yesterday: back today', (tester) async {
    await _pump(tester, putAwayOn: DateTime(2026, 10, 20));
    expect(find.text('PLAN YOUR INBOX'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final width in [390.0, 1280.0]) {
      testWidgets('meets a11y guidelines (${mode.name}, $width)', (
        tester,
      ) async {
        tester.view
          ..physicalSize = Size(width, 800)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _pump(tester, mode: mode);
        await expectA11yGuidelines(tester);
      });
    }
  }
}
