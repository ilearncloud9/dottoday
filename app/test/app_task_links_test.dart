import 'package:dottoday/app_task_links.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/test_l10n.dart';
import 'support/timeline_fakes.dart';

/// ED-097, CR-068: the address and the open task stay in step.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  late GoRouter router;
  late Occurrence task;

  Future<ProviderContainer> pump(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final rows = demoDayRows(DateTime(2026, 10, 21));
    task = rows.first;
    router = GoRouter(
      initialLocation: AppRoutes.today,
      routes: [
        GoRoute(
          path: AppRoutes.today,
          builder: (context, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => openTask(context, task.id),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    final container = ProviderContainer(
      overrides: timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 7, 22),
        occurrences: FakeOccurrenceRepository(rows),
        profile: testProfile(),
      ),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: DotTheme.light(),
          localizationsDelegates: testL10nDelegates,
          supportedLocales: testL10nLocales,
          locale: testL10nLocale,
          routerConfig: router,
          builder: (context, child) =>
              TaskLinkHost(router: router, child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  String address() => router.routeInformationProvider.value.uri.toString();

  testWidgets('opening a task adds ?task= and shows the sheet on a phone', (
    tester,
  ) async {
    await pump(tester, const Size(390, 900));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(address(), '/today?task=${task.id}');
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('the address losing ?task= (Back) closes the sheet', (
    tester,
  ) async {
    await pump(tester, const Size(390, 900));
    router.go('/today?task=${task.id}');
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('closing the sheet by hand removes ?task=', (tester) async {
    await pump(tester, const Size(390, 900));
    router.go('/today?task=${task.id}');
    await tester.pumpAndSettle();
    // A swipe down, or the scrim.
    await tester.tapAt(const Offset(195, 20));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(address(), AppRoutes.today);
  });

  testWidgets('Esc closes the sheet and removes ?task= (Mac, web)', (
    tester,
  ) async {
    await pump(tester, const Size(390, 900));
    router.go('/today?task=${task.id}');
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(address(), AppRoutes.today);
  });

  testWidgets('at the expanded width it opens the panel, and closing the '
      'panel removes ?task=', (tester) async {
    final container = await pump(tester, const Size(1280, 900));
    router.go('/today?task=${task.id}');
    await tester.pumpAndSettle();
    expect(container.read(editingTaskProvider), task.id);
    expect(find.byType(BottomSheet), findsNothing);
    container.read(editingTaskProvider.notifier).close();
    await tester.pumpAndSettle();
    expect(address(), AppRoutes.today);
  });

  testWidgets('an unknown task opens Today and nothing else (D2)', (
    tester,
  ) async {
    await pump(tester, const Size(390, 900));
    router.go('/today?task=01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f90');
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(address(), AppRoutes.today);
  });
}
