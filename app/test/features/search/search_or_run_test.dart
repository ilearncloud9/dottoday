import 'package:dottoday/app_menus.dart';
import 'package:dottoday/app_search_or_run.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/search/state/search_state.dart';
import 'package:dottoday/features/search/widgets/search_or_run.dart';
import 'package:dottoday/features/search/widgets/search_or_run_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../timeline/calendar/calendar_world.dart';

/// Search or run (ED-333, E-R2-30; docs/09 M20.2 part 3).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  const mac = Size(1280, 800);
  final macOnly = TargetPlatformVariant.only(TargetPlatform.macOS);
  String at(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

  /// The palette over the app, with [ran] counting a test command.
  Future<(GoRouter, List<String>)> open(WidgetTester tester) async {
    final router = await pumpCalendar(tester, size: mac);
    final ran = <String>[];
    final host =
        router.routerDelegate.navigatorKey.currentState!.overlay!.context;
    // Not awaited: it completes when the palette closes.
    // ignore: unawaited_futures
    showSearchOrRun(
      host,
      commands: [
        PaletteCommand('New Task', () => ran.add('new'), keys: '⌘N'),
        PaletteCommand('Go to Date…', () => ran.add('date'), keys: '⇧⌘T'),
      ],
      placeholder: 'Search or run',
    );
    await tester.pumpAndSettle();
    return (router, ran);
  }

  test('⌘K / Ctrl K and the web k are Search or run', () {
    for (final (platform, meta) in [
      (TargetPlatform.macOS, true),
      (TargetPlatform.windows, false),
    ]) {
      final hit = AppShortcuts.bindings(platform, web: false).entries.where(
        (e) =>
            e.key is SingleActivator &&
            (e.key as SingleActivator).trigger == LogicalKeyboardKey.keyK &&
            (e.key as SingleActivator).meta == meta,
      );
      expect(
        (hit.single.value as AppCommandIntent).command,
        AppCommand.searchOrRun,
      );
    }
    expect(
      AppShortcuts.webTable[AppCommand.searchOrRun],
      const SingleActivator(LogicalKeyboardKey.keyK),
    );
  });

  test('commands: the menus, no text-edit items, one per name, Mac keys', () {
    void noop() {}
    final menus = [
      AppMenu(AppMenuKind.file, 'File', [
        [
          MenuCommand('New Task', noop, key: LogicalKeyboardKey.keyN),
          MenuCommand(
            'Show Plan Panel',
            noop,
            key: LogicalKeyboardKey.keyP,
            alt: true,
          ),
        ],
      ]),
      AppMenu(AppMenuKind.edit, 'Edit', [
        [MenuCommand('Undo', noop, textEdit: true)],
      ]),
      AppMenu(AppMenuKind.go, 'Go', [
        [MenuCommand('New Task', noop), const MenuCommand('Disabled', null)],
      ]),
    ];
    final mac = paletteCommands(menus, web: false);
    expect([for (final c in mac) c.label], ['New Task', 'Show Plan Panel']);
    expect([for (final c in mac) c.keys], ['⌘N', '⌥⌘P']);
    final web = paletteCommands(menus, web: true);
    expect([for (final c in web) c.keys], [null, null]);
  });

  testWidgets('nothing typed: the commands, the keys, the footer', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Commands'), findsOneWidget);
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('⇧⌘T'), findsOneWidget);
    expect(find.text('↑↓ to move · ↵ to open · esc to close'), findsOneWidget);
  }, variant: macOnly);

  testWidgets('typing finds tasks, then Search for …; ↓ ↵ runs it', (
    tester,
  ) async {
    final (router, _) = await open(tester);
    await tester.enterText(find.byType(TextField), 'roadmap');
    await tester.pumpAndSettle();
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Deep work: roadmap'), findsOneWidget);
    expect(find.text('Search for “roadmap”'), findsOneWidget);
    expect(find.text('New Task'), findsNothing, reason: 'filtered by name');
    // The task is first; ↓ reaches Search for ….
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(SearchOrRun), findsNothing);
    expect(at(router), AppRoutes.search);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(searchInputStateProvider).text, 'roadmap');
    expect(find.widgetWithText(TextField, 'roadmap'), findsOneWidget);
  }, variant: macOnly);

  testWidgets('a command runs after the palette closes; Esc closes', (
    tester,
  ) async {
    final (_, ran) = await open(tester);
    await tester.enterText(find.byType(TextField), 'date');
    await tester.pumpAndSettle();
    // "Search for “date”", then Go to Date….
    await tester.tap(find.text('Go to Date…'));
    await tester.pumpAndSettle();
    expect(ran, ['date']);
    expect(find.byType(SearchOrRun), findsNothing);
  }, variant: macOnly);

  testWidgets('Esc closes it, with nothing run', (tester) async {
    final (_, ran) = await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(SearchOrRun), findsNothing);
    expect(ran, isEmpty);
  }, variant: macOnly);

  testWidgets('nothing matches', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    // "Search for" always matches; nothing else does.
    expect(find.text('Search for “zzzz”'), findsOneWidget);
    expect(find.text('Tasks'), findsNothing);
  }, variant: macOnly);

  testWidgets('the iPad and Android go to Search instead', (tester) async {
    final router = await pumpCalendar(tester, size: mac);
    final ref =
        tester.element(find.byWidgetPredicate((w) => w is ConsumerWidget).first)
            as WidgetRef;
    openSearchOrRun(router, ref, const {}, minimal: false, web: false);
    await tester.pumpAndSettle();
    expect(at(router), AppRoutes.search);
    expect(find.byType(SearchOrRun), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('⌘K opens it over Today with the menus\' commands', (
    tester,
  ) async {
    final router = await pumpCalendar(tester, size: mac);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.byType(SearchOrRun), findsOneWidget);
    // From the real menus: File's New Task, Go's Go to Date….
    expect(find.text('New Task'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(SearchOrRun),
        matching: find.byType(TextField),
      ),
      'o',
    );
    await tester.pumpAndSettle();
    expect(find.text('Go to Date…'), findsOneWidget);
    expect(find.text('Undo'), findsNothing, reason: 'text-edit items stay out');
  }, variant: macOnly);

  testWidgets('the toolbar\'s Search or run opens it too', (tester) async {
    final router = await pumpCalendar(tester, size: mac);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    // The toolbar measures its other layouts off screen (FirstThatFits).
    await tester.tap(find.text('⌘K').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.byType(SearchOrRun), findsOneWidget);
  }, variant: macOnly);

  testWidgets('meets a11y guidelines', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'roadmap');
    await tester.pumpAndSettle();
    await expectA11yGuidelines(tester);
  }, variant: macOnly);
}
