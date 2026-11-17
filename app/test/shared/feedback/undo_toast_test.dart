import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// A screen with a button that shows the Undo toast, counting undos.
Future<List<int>> _pump(WidgetTester tester, {bool reader = false}) async {
  final undone = <int>[];
  await tester.pumpWidget(
    testApp(
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(accessibleNavigation: reader),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showUndoSnackbar(
                  context,
                  message: 'Marked done',
                  onUndo: () => undone.add(1),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
  return undone;
}

const _past = Duration(seconds: 1);

void main() {
  testWidgets('Undo undoes once and closes', (tester) async {
    final undone = await _pump(tester);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undone, [1]);
    expect(find.text('Marked done'), findsNothing);
  });

  testWidgets('closes when the window ends, with no countdown', (tester) async {
    await _pump(tester);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pump(UndoService.window + _past);
    await tester.pumpAndSettle();
    expect(find.text('Marked done'), findsNothing);
  });

  testWidgets('held under the pointer it waits; the window ends: too late, '
      'Close only (ED-281)', (tester) async {
    await _pump(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(
      location: tester.getCenter(find.text('Marked done')),
    );
    await tester.pump();
    await tester.pump(UndoService.window + _past);
    await tester.pumpAndSettle();
    const tooLate =
        "That can't be undone any more. Deleted tasks stay in Trash for 30 days.";
    expect(find.text(tooLate), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(find.text(tooLate), findsNothing);
    await mouse.removePointer();
  });

  testWidgets('with a screen reader it stays and shows Close', (tester) async {
    await _pump(tester, reader: true);
    expect(find.byTooltip('Close'), findsOneWidget);
    await tester.pump(UndoService.window + _past);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Close'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Escape closes it', (tester) async {
    await _pump(tester);
    Focus.of(tester.element(find.text('Undo'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Marked done'), findsNothing);
  });
}
