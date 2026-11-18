import 'package:dottoday/app_commands.dart';
import 'package:dottoday/app_openers.dart';
import 'package:dottoday/app_shortcut_groups.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/shortcuts/single_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/test_app.dart';

/// The keyboard scheme (ED-095) beyond the built table.
void main() {
  group('bindings', () {
    test('the apps bind every command to its ⌘ key', () {
      final mac = AppShortcuts.bindings(TargetPlatform.macOS, web: false);
      final commands = {
        for (final i in mac.values) (i as AppCommandIntent).command,
      };
      expect(commands, AppShortcuts.table.keys.toSet());
      final back = mac.entries.where(
        (e) =>
            e.key is SingleActivator &&
            (e.key as SingleActivator).trigger ==
                LogicalKeyboardKey.bracketLeft,
      );
      expect((back.single.value as AppCommandIntent).command, AppCommand.back);
    });

    test('the web binds single keys and leaves ⌘/Ctrl N, T, 1–4, F and '
        'Back to the browser', () {
      final web = AppShortcuts.bindings(TargetPlatform.windows, web: true);
      final modified = [
        for (final a in web.keys)
          if (a is SingleActivator && (a.control || a.meta)) a.trigger,
      ];
      // Only ⌘/Ctrl / (the shortcut list) keeps its modifier.
      expect(modified, [LogicalKeyboardKey.slash]);
      final commands = {
        for (final i in web.values) (i as AppCommandIntent).command,
      };
      expect(commands, isNot(contains(AppCommand.back)));
      expect(commands, isNot(contains(AppCommand.pasteAsTasks)));
      expect(
        web.values.whereType<AppCommandIntent>().where((i) => i.single),
        hasLength(AppShortcuts.webTable.length),
      );
    });
  });

  group('single keys', () {
    Future<int> press(
      WidgetTester tester, {
      required bool on,
      required bool field,
    }) async {
      var ran = 0;
      await tester.pumpWidget(
        testApp(
          Shortcuts(
            shortcuts: {
              const SingleActivator(LogicalKeyboardKey.keyN):
                  const AppCommandIntent(AppCommand.quickAdd, single: true),
            },
            child: AppCommandScope(
              singleKeys: on,
              handlers: {AppCommand.quickAdd: () => ran++},
              child: field
                  ? const Material(child: TextField())
                  : const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pump();
      if (field) {
        await tester.tap(find.byType(TextField));
        await tester.pump();
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.pump();
      return ran;
    }

    testWidgets('a single key acts outside text fields', (tester) async {
      expect(await press(tester, on: true, field: false), 1);
    });

    testWidgets('a text field keeps its letters', (tester) async {
      expect(await press(tester, on: true, field: true), 0);
    });

    testWidgets('the setting turns single keys off (WCAG 2.1.4)', (
      tester,
    ) async {
      expect(await press(tester, on: false, field: false), 0);
    });

    testWidgets('PeriodKeys: [ ] t on the web, and the Go menu\'s moves', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        testApp(
          PeriodKeys(
            web: true,
            onPrevious: () => log.add('prev'),
            onNext: () => log.add('next'),
            onCurrent: () => log.add('now'),
            child: const Focus(autofocus: true, child: SizedBox()),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft, character: '[');
      await tester.sendKeyEvent(
        LogicalKeyboardKey.bracketRight,
        character: ']',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      final focus = primaryFocus!.context!;
      Actions.invoke(focus, const ShowDayIntent(-1));
      Actions.invoke(focus, const ShowTodayIntent());
      expect(log, ['prev', 'next', 'now', 'prev', 'now']);
    });
  });

  group('places by layout', () {
    late GoRouter router;
    late List<String> went;

    setUp(() {
      went = [];
      router = GoRouter(
        initialLocation: AppRoutes.today,
        routes: [
          for (final path in [
            AppRoutes.today,
            AppRoutes.inbox,
            AppRoutes.week,
            AppRoutes.month,
            AppRoutes.search,
          ])
            GoRoute(
              path: path,
              builder: (_, _) {
                went.add(path);
                return Text(path);
              },
            ),
        ],
      );
    });

    Future<void> run(WidgetTester tester, AppCommand c, bool minimal) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      appCommandHandlers(router, minimal: minimal)[c]!();
      await tester.pumpAndSettle();
    }

    testWidgets('Full: ⌘3 Week, ⌘4 Month', (tester) async {
      await run(tester, AppCommand.goWeek, false);
      await run(tester, AppCommand.goMonth, false);
      expect(went, containsAllInOrder([AppRoutes.week, AppRoutes.month]));
    });

    testWidgets('Minimal: ⌘3 Calendar (the month), ⌘4 Search', (tester) async {
      await run(tester, AppCommand.goWeek, true);
      await run(tester, AppCommand.goMonth, true);
      expect(went, containsAllInOrder([AppRoutes.month, AppRoutes.search]));
      expect(went, isNot(contains(AppRoutes.week)));
    });
  });

  group('⌘T', () {
    testWidgets('a screen with a current period takes it', (tester) async {
      var current = 0;
      var went = 0;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Actions(
              actions: {
                ShowTodayIntent: CallbackAction<ShowTodayIntent>(
                  onInvoke: (_) => current++,
                ),
              },
              child: const Focus(autofocus: true, child: SizedBox()),
            ),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      AppOpeners(router).today(() => went++);
      expect((current, went), (1, 0));
    });

    testWidgets('anywhere else goes to Today', (tester) async {
      var went = 0;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Focus(autofocus: true, child: SizedBox()),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      AppOpeners(router).today(() => went++);
      expect(went, 1);
    });
  });

  group('the shortcut list', () {
    List<String> keysOf(
      AppLocalizations l10n, {
      bool minimal = false,
      required bool web,
    }) => [
      for (final g in appShortcutGroups(l10n, minimal: minimal, web: web))
        for (final r in g.rows) '${r.keys} ${r.action}',
    ];

    testWidgets('the web lists its single keys and not the browser\'s', (
      tester,
    ) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (c) {
              l10n = c.l10n;
              return const SizedBox();
            },
          ),
        ),
      );
      final web = keysOf(l10n, web: true);
      expect(web, contains('n ${l10n.shortcutAdd}'));
      expect(web, contains('[ ${l10n.shortcutPrevDay}'));
      expect(web.where((r) => r.endsWith(l10n.shortcutBack)), isEmpty);
      expect(web.where((r) => r.endsWith(l10n.shortcutCopyDay)), isEmpty);
      final minimal = keysOf(l10n, minimal: true, web: false);
      expect(minimal.any((r) => r.endsWith(l10n.shortcutGoCalendar)), isTrue);
      expect(minimal.any((r) => r.endsWith(l10n.shortcutGoWeek)), isFalse);
    });
  });
}
