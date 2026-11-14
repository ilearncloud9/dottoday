import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

// CR-160 B7 gate, G2: a question in a wide window stays prompt-wide; the
// popover sheet keeps its own, wider cap.

const _long =
    'A question long enough to run across the whole window when nothing '
    'holds it back, which is what the delete question did on the Mac and '
    'on the web at the expanded width.'; // l10n-ignore: test fixture

Widget _host(void Function(BuildContext) open) => testApp(
  Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => open(context),
          child: const Text('open'), // l10n-ignore: test fixture
        ),
      ),
    ),
  ),
);

Future<void> _wide(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('a title-less question is at most prompt-wide', (tester) async {
    await _wide(tester);
    await tester.pumpWidget(
      _host(
        (c) => showDialog<void>(
          context: c,
          builder: (_) => const AlertDialog(content: Text(_long)),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    // The dialog's card, not the full-window route it sits in.
    final card = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Material),
    );
    final width = tester.getSize(card.first).width;
    expect(width, lessThanOrEqualTo(DotSize.promptWidth));
  });

  testWidgets('a popover sheet keeps its own width', (tester) async {
    await _wide(tester);
    await tester.pumpWidget(
      _host(
        (c) => showAppSheet<void>(
          context: c,
          title: 'Sheet', // l10n-ignore: test fixture
          builder: (_) => const Text(_long),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final width = tester.getSize(find.byType(AppSheet)).width;
    expect(width, appSheetMaxWidth);
  });
}
