import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/layout/side_panel_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

final _list = ScrollController();

Widget _frame() => testApp(
  Scaffold(
    body: SidePanelFrame(
      panel: const Material(child: TextField(key: Key('note'))),
      child: ListView.builder(
        controller: _list,
        itemCount: 200,
        itemBuilder: (_, i) => SizedBox(height: 40, child: Text('row $i')),
      ),
    ),
  ),
);

Future<void> _window(WidgetTester tester, double width) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1;
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('docked from 1160, floating below, the same editor and scroll '
      'either way (ED-167, ED-168)', (tester) async {
    addTearDown(tester.view.reset);
    await _window(tester, 1280);
    await tester.pumpWidget(_frame());
    final panel = find.byKey(const Key('note'));
    // Docked: the content stops where the panel starts.
    final docked = tester.getRect(find.byType(ListView));
    expect(docked.right, lessThanOrEqualTo(tester.getRect(panel).left));
    await tester.enterText(panel, 'half a thought');
    _list.jumpTo(800);
    await tester.pump();

    await _window(tester, 1100);
    // Floating: the content runs under the panel.
    final floating = tester.getRect(find.byType(ListView));
    expect(floating.right, greaterThan(tester.getRect(panel).left));
    expect(find.text('half a thought'), findsOneWidget);
    expect(_list.offset, 800);
    expect(DotSize.sidePanel, tester.getSize(find.byType(TextField)).width);

    await _window(tester, 1280);
    expect(find.text('half a thought'), findsOneWidget);
    expect(_list.offset, 800);
  });
}
