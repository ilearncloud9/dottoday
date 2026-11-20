import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

const _channel = MethodChannel('dottoday/context_menu');

// l10n-ignore: test fixtures
const _entries = [
  ContextMenuEntry(value: 'schedule', label: 'Schedule', symbol: 'calendar'),
  ContextMenuEntry(
    value: 'trash',
    label: 'Move to Trash',
    symbol: 'trash',
    shortcut: SingleActivator(LogicalKeyboardKey.backspace, meta: true),
  ),
];

/// Opens the menu from a button and records what it returned.
Future<List<String?>> _open(WidgetTester tester) async {
  final picked = <String?>[];
  await tester.pumpWidget(
    testApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => picked.add(
            await showContextMenu<String>(
              context,
              at: const Offset(40, 50),
              entries: _entries,
            ),
          ),
          child: const Text('open'), // l10n-ignore: test fixture
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return picked;
}

void main() {
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null),
  );

  void answer(int? index, List<MethodCall> calls) =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            calls.add(call);
            return index;
          });

  testWidgets('the Mac app asks the system menu: labels, SF Symbols and '
      'the ⌘⌫ hint go over; the choice comes back (ED-239, ED-336)', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    answer(1, calls);
    final picked = await _open(tester);
    expect(picked, ['trash']);
    final args = calls.single.arguments as Map<Object?, Object?>;
    expect(args['x'], 40);
    expect(args['y'], 50);
    final items = (args['items']! as List<Object?>)
        .cast<Map<Object?, Object?>>();
    expect([for (final i in items) i['label']], ['Schedule', 'Move to Trash']);
    expect([for (final i in items) i['symbol']], ['calendar', 'trash']);
    expect(items[1]['key'], 'backspace');
    expect(items[1]['command'], isTrue);
    expect(find.byType(PopupMenuItem<String>), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets("a pop-up's current choice goes over ticked (R2-40)", (
    tester,
  ) async {
    final calls = <MethodCall>[];
    answer(0, calls);
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showContextMenu<int>(
              context,
              at: Offset.zero,
              entries: const [
                ContextMenuEntry(value: 0, label: 'Low', checked: false),
                ContextMenuEntry(value: 1, label: 'High', checked: true),
              ],
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final items =
        ((calls.single.arguments as Map<Object?, Object?>)['items']!
                as List<Object?>)
            .cast<Map<Object?, Object?>>();
    expect([for (final i in items) i['checked']], [false, true]);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets("elsewhere the ticks are Flutter's checked items", (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showContextMenu<int>(
              context,
              at: Offset.zero,
              entries: const [
                ContextMenuEntry(value: 0, label: 'Low', checked: false),
                ContextMenuEntry(value: 1, label: 'High', checked: true),
              ],
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final high = tester.widget<CheckedPopupMenuItem<int>>(
      find.widgetWithText(CheckedPopupMenuItem<int>, 'High'),
    );
    expect(high.checked, isTrue);
  });

  testWidgets('dismissing the system menu returns nothing', (tester) async {
    answer(-1, []);
    final picked = await _open(tester);
    expect(picked, [null]);
    expect(find.byType(PopupMenuItem<String>), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('without the bridge the Mac falls back to Flutter\'s menu', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _channel,
          (_) async => throw MissingPluginException(),
        );
    await _open(tester);
    expect(find.text('Move to Trash'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('no answer at all is no bridge: Flutter\'s menu', (tester) async {
    answer(null, []);
    await _open(tester);
    expect(find.text('Move to Trash'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('iOS asks for its own menu too (owner, 4d)', (tester) async {
    final calls = <MethodCall>[];
    answer(1, calls);
    final picked = await _open(tester);
    expect(picked, ['trash']);
    expect(calls, hasLength(1));
    expect(find.byType(PopupMenuItem<String>), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('other platforms keep Flutter\'s menu and never ask', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    answer(0, calls);
    await _open(tester);
    expect(calls, isEmpty);
    expect(find.text('Schedule'), findsOneWidget);
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
