import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _host(void Function(BuildContext) onPressed, {ThemeMode? mode}) =>
    testApp(
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => onPressed(context),
              child: const Text('go'), // l10n-ignore: test fixture
            ),
          ),
        ),
      ),
      themeMode: mode ?? ThemeMode.light,
    );

void main() {
  testWidgets('shows message and Undo for the 30 s undo window', (
    tester,
  ) async {
    var undone = 0;
    await tester.pumpWidget(
      _host(
        (c) => showUndoSnackbar(c, message: 'Moved', onUndo: () => undone++),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.duration, UndoService.window);
    expect(find.text('Moved'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    expect(undone, 1);
  });

  testWidgets('a new action replaces the previous snackbar', (tester) async {
    var n = 0;
    await tester.pumpWidget(
      _host((c) => showUndoSnackbar(c, message: 'm${n++}', onUndo: () {})),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('m0'), findsNothing);
    expect(find.text('m1'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines ($mode)', (tester) async {
      await tester.pumpWidget(
        _host(
          (c) => showUndoSnackbar(c, message: 'Moved', onUndo: () {}),
          mode: mode,
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await expectA11yGuidelines(tester);
    });
  }
}
