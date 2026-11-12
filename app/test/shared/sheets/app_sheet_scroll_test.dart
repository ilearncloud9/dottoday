import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

// CR-160 B7 gate, G1: a sheet whose body scrolls keeps its title and close
// button whole (they slid under the drag handle, cut to 48×22).

Widget _host() => testApp(
  Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => showAppSheet<void>(
            context: context,
            title: 'Download 9 files', // l10n-ignore: test fixture
            builder: (_) => Column(
              children: [
                for (var i = 0; i < 30; i++)
                  TextButton(
                    onPressed: () {},
                    child: Text('row $i'), // l10n-ignore: test fixture
                  ),
              ],
            ),
          ),
          child: const Text('open'), // l10n-ignore: test fixture
        ),
      ),
    ),
  ),
);

void main() {
  for (final (name, size) in [
    ('compact', const Size(390, 844)),
    ('wide', const Size(1280, 800)),
  ]) {
    testWidgets('scrolled to the end, the close button stays whole ($name)', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final close = find.widgetWithIcon(IconButton, Icons.close);
      final before = tester.getRect(close);

      await tester.scrollUntilVisible(
        find.text('row 29'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(close), before);
      // Android's 48 dp floor, above our 44 pt one (DotTouch.min).
      expect(before.size, const Size.square(48));
      expect(find.text('Download 9 files').hitTestable(), findsOneWidget);
      expect(close.hitTestable(), findsOneWidget);
    });
  }
}
