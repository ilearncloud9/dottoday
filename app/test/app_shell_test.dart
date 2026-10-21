import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/test_app.dart';

int _quickAdds = 0;

/// Expanded (Mac/web) by default: the rail with every destination.
Future<GoRouter> _pump(WidgetTester tester, {double width = 1280}) async {
  _quickAdds = 0;
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(router, onQuickAdd: () => _quickAdds++),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _chord(
  WidgetTester tester,
  LogicalKeyboardKey mod,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(mod);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(mod);
  await tester.pumpAndSettle();
}

Finder _route(String name) => find.byKey(ValueKey('route:$name'));

void main() {
  testWidgets('tabs switch branches; labels come from l10n', (tester) async {
    await _pump(tester);
    expect(_route('today'), findsOneWidget);
    for (final (label, route) in [
      ('Inbox', 'inbox'),
      ('Week', 'week'),
      ('Search', 'search'),
      ('Settings', 'settings'),
      ('Today', 'today'),
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(_route(route), findsOneWidget, reason: label);
    }
  });

  testWidgets('⌘1-4 and ⌘N on macOS', (tester) async {
    await _pump(tester);
    const meta = LogicalKeyboardKey.metaLeft;
    await _chord(tester, meta, LogicalKeyboardKey.digit2);
    expect(_route('inbox'), findsOneWidget);
    await _chord(tester, meta, LogicalKeyboardKey.digit3);
    expect(_route('week'), findsOneWidget);
    await _chord(tester, meta, LogicalKeyboardKey.digit1);
    expect(_route('today'), findsOneWidget);
    await _chord(tester, meta, LogicalKeyboardKey.keyN);
    expect(_quickAdds, 1);
    await _chord(tester, meta, LogicalKeyboardKey.digit4);
    expect(_route('month'), findsOneWidget);
    // Ctrl is not the primary modifier on macOS.
    await _chord(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyN,
    );
    expect(_quickAdds, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('Ctrl shortcuts on Windows/Linux/Android', (tester) async {
    await _pump(tester);
    await _chord(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.digit2,
    );
    expect(_route('inbox'), findsOneWidget);
    await _chord(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyN,
    );
    expect(_quickAdds, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('add button: labelled, ≥ 44 pt, invokes Quick Add', (
    tester,
  ) async {
    await _pump(tester, width: 412);
    final fab = find.byType(FloatingActionButton);
    final size = tester.getSize(fab);
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
    expect(find.byTooltip('Add task'), findsOneWidget);
    await tester.tap(fab);
    expect(_quickAdds, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('iPhone add dot invokes Quick Add', (tester) async {
    await _pump(tester, width: 390);
    await tester.tap(find.bySemanticsLabel('Add task'));
    expect(_quickAdds, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
