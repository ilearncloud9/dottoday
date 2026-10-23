import 'package:dottoday/app_menu.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/test_app.dart';
import 'support/timeline_fakes.dart';

/// Every menu item the app sent to macOS, by label (first match wins:
/// "Today" is in View, with ⌘1, and in Go).
Map<String, Map<String, Object?>> _flatten(
  List<Object?> items, [
  Map<String, Map<String, Object?>>? into,
]) {
  final out = into ?? {};
  for (final raw in items.cast<Map<Object?, Object?>>()) {
    if (raw['label'] case final String label) {
      out.putIfAbsent(label, () => raw.cast<String, Object?>());
    }
    _flatten((raw['children'] as List<Object?>?) ?? const [], out);
  }
  return out;
}

final _mac = TargetPlatformVariant.only(TargetPlatform.macOS);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late List<Object?> sent;
  late Map<AppCommand, int> calls;
  late FakeUndoService undo;
  late FakeOccurrenceRepository repo;

  Future<void> pump(WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.menu,
      (call) async {
        if (call.method == 'Menu.setMenus') {
          sent =
              (call.arguments as Map<Object?, Object?>)['0']! as List<Object?>;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.menu,
        null,
      ),
    );
    calls = {};
    repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    undo = FakeUndoService(repo);
    final router = GoRouter(
      initialLocation: AppRoutes.inbox,
      routes: [
        for (final path in [
          AppRoutes.today,
          AppRoutes.inbox,
          AppRoutes.settings,
        ])
          GoRoute(path: path, builder: (_, _) => Text(path)),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [undoServiceProvider.overrideWithValue(undo)],
        child: testApp(
          Builder(
            builder: (context) => AppMenuBar(
              router: router,
              handlers: {
                for (final c in AppCommand.values)
                  c: () => calls[c] = (calls[c] ?? 0) + 1,
              },
              child: const SizedBox(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> select(WidgetTester tester, String label) async {
    final id = _flatten(sent)[label]!['id'];
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.menu.name,
      SystemChannels.menu.codec.encodeMethodCall(
        MethodCall('Menu.selectedCallback', id),
      ),
      (_) {},
    );
    await tester.pump();
  }

  testWidgets('File, Edit, View, Go and Window carry the commands', (
    tester,
  ) async {
    await pump(tester);
    final items = _flatten(sent);
    expect(sent.cast<Map<Object?, Object?>>().map((m) => m['label']), [
      'Dottoday',
      'File',
      'Edit',
      'View',
      'Go',
      'Window',
    ]);
    // ⌘N, ⌘1–4, ⌘/ and ⌘, are native key equivalents …
    for (final label in ['New Task', 'Today', 'Inbox', 'Week', 'Month']) {
      expect(
        items[label],
        containsPair('shortcutModifiers', isNonZero),
        reason: label,
      );
    }
    // … but keys a text field needs are not.
    for (final label in ['Undo', 'Previous Day', 'Next Day']) {
      expect(
        items[label]!.containsKey('shortcutTrigger'),
        isFalse,
        reason: label,
      );
    }
  }, variant: _mac);

  testWidgets('a menu item runs the same handler as its key', (tester) async {
    await pump(tester);
    await select(tester, 'New Task');
    await select(tester, 'Week');
    expect(calls, {AppCommand.quickAdd: 1, AppCommand.goWeek: 1});
  }, variant: _mac);

  testWidgets('Edit › Undo reverts the last undoable change', (tester) async {
    await pump(tester);
    final gym = repo.rows.firstWhere((o) => o.title == 'Gym');
    await undo.applyUndoable(
      WriteBatch(
        userId: gym.userId,
        occurrences: [gym.copyWith(title: 'X')],
      ),
    );
    await select(tester, 'Undo');
    await tester.pumpAndSettle();
    expect(repo.rows.firstWhere((o) => o.id == gym.id).title, 'Gym');
  }, variant: _mac);

  testWidgets('no menu bar off the Mac', (tester) async {
    expect(AppMenuBar.shown, isFalse);
  });
}
