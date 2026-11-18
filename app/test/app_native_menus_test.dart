import 'package:dottoday/app_menus.dart';
import 'package:dottoday/app_native_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

const _channel = MethodChannel('dottoday/key_menus');

void main() {
  var ran = <String>[];
  List<AppMenu> menus() => [
    AppMenu(AppMenuKind.file, 'File', [
      [
        MenuCommand(
          'New Task',
          () => ran.add('new'),
          key: LogicalKeyboardKey.keyN,
        ),
        MenuCommand(
          'New Brain Dump…',
          () => ran.add('dump'),
          key: LogicalKeyboardKey.keyN,
          shift: true,
        ),
      ],
    ]),
    AppMenu(AppMenuKind.edit, 'Edit', [
      [
        MenuCommand('Undo', () => ran.add('undo'), textEdit: true),
        MenuCommand(
          'Copy Day as Text',
          () => ran.add('copy'),
          key: LogicalKeyboardKey.keyC,
          shift: true,
        ),
      ],
    ]),
    AppMenu(AppMenuKind.go, 'Go', [
      [
        MenuCommand(
          'Back',
          () => ran.add('back'),
          key: LogicalKeyboardKey.bracketLeft,
        ),
        MenuCommand('Next Day', () => ran.add('next')),
      ],
    ]),
  ];

  setUp(() => ran = []);

  test('the wire carries labels, keys and Shift; Undo stays the '
      'system\'s (R2-10)', () {
    final wire = NativeKeyMenus.wire(menus());
    expect(wire.map((m) => m['kind']), ['file', 'edit', 'go']);
    final file = (wire[0]['groups']! as List).single as List;
    expect(file, [
      {'id': '0.0.0', 'label': 'New Task', 'key': 'n', 'shift': false},
      {'id': '0.0.1', 'label': 'New Brain Dump…', 'key': 'n', 'shift': true},
    ]);
    final edit = (wire[1]['groups']! as List).single as List;
    expect(edit.map((i) => (i as Map)['label']), ['Copy Day as Text']);
    // Its id keeps its place, so the system's choice finds it.
    expect((edit.single as Map)['id'], '1.0.1');
    final go = (wire[2]['groups']! as List).single as List;
    expect((go[0] as Map)['key'], '[');
    expect((go[1] as Map).containsKey('key'), isFalse);
  });

  testWidgets('sent once per change; a chosen id runs its command', (
    tester,
  ) async {
    final sent = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (
      call,
    ) async {
      if (call.method == 'set') sent.add(call.arguments);
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        _channel,
        null,
      ),
    );
    final list = menus();
    await tester.pumpWidget(
      testApp(NativeKeyMenus(menus: list, child: const SizedBox())),
    );
    await tester.pumpWidget(
      testApp(NativeKeyMenus(menus: menus(), child: const SizedBox())),
    );
    expect(sent, hasLength(1));
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      _channel.name,
      _channel.codec.encodeMethodCall(const MethodCall('select', '2.0.0')),
      (_) {},
    );
    expect(ran, ['back']);
  });
}
