import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

/// M8.5b, R-08: a write that fails (0 bytes free) never loses what was
/// typed in Add.
/// A wide window: Minimal's sheet reopens there as on a phone.
const _wide = Size(1280, 900);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const message = "Couldn't save on this device. Try again.";
  late WriteFault fault;
  setUp(() => fault = WriteFault()..failure = const StorageFailure());

  Finder titleWith(String text) => find.widgetWithText(TextField, text);

  testWidgets('Add reopens with the draft; Try again writes it', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester, size: _wide, writeFault: fault);
    await tester.enterText(addTitle, 'Pay rent 5pm 20m');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Pay rent'), isNull);
    expect(find.byType(AddFlowSheet), findsOneWidget);
    expect(titleWith('Pay rent 5pm 20m'), findsOneWidget);
    expect(find.text(message), findsOneWidget);

    fault.failure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    final o = addedRow(repo, 'Pay rent')!;
    expect(o.startUtc, DateTime.utc(2026, 10, 21, 15));
    expect(o.durationMin, 20);
    expect(find.byType(AddFlowSheet), findsNothing);
    expect(find.text('Pay rent added for 5:00 PM'), findsOneWidget);
  });

  testWidgets('the reopened draft can be edited and added as usual', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester, size: _wide, writeFault: fault);
    await tester.enterText(addTitle, 'Call Mum');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    fault.failure = null;
    await tester.enterText(addTitle, 'Call Dad');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Call Dad'), isNotNull);
    expect(addedRow(repo, 'Call Mum'), isNull);
    expect(find.byType(AddFlowSheet), findsNothing);
  });

  testWidgets('Add another keeps the sheet and the title on failure', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester, size: _wide, writeFault: fault);
    await tester.enterText(addTitle, 'Pack 8pm 30m');
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Pack'), isNull);
    expect(titleWith('Pack 8pm 30m'), findsOneWidget);
    expect(find.text(message), findsOneWidget);

    fault.failure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Pack'), isNotNull);
    // Still open for the next one, the failure gone.
    expect(titleWith('Pack 8pm 30m'), findsNothing);
    expect(find.text(message), findsNothing);
  });

  // A pasted list in Minimal goes to Brain dump and writes nothing; Full's
  // list that fails to save: add_popover_test.dart.

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      // Minimal's sheet reopens itself at every width; Full reopens Create
      // task (create_task_test) or the popover (add_popover_test).
      ('medium', const Size(700, 900)),
      ('expanded', _wide),
    ]) {
      testWidgets('failure strip a11y ${mode.name} $name', (tester) async {
        await pumpAddHost(tester, mode: mode, size: size, writeFault: fault);
        await tester.enterText(addTitle, 'Pay rent');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(find.text(message), findsOneWidget);
        await expectA11yGuidelines(tester);
      });
    }
  }
}
