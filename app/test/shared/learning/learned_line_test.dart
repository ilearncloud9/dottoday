import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

// docs/13 §6: a learned value explains itself in place — one more line and
// the reset, no sheet, no dialog — and the reset can be undone.
void main() {
  Future<List<String>> pump(
    WidgetTester tester, {
    bool withReset = true,
    LearnedExplanation? explanation,
  }) async {
    final log = <String>[];
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: Center(
            child: LearnedLine(
              text: 'usually 2 h 20',
              explanation:
                  explanation ??
                  LearnedExplanation(
                    why: 'based on your last 6 times · median',
                    reset: withReset
                        ? () async {
                            log.add('reset');
                            return () async => log.add('undo');
                          }
                        : null,
                    resetDone: 'Learning for Deep work reset on this device',
                  ),
            ),
          ),
        ),
      ),
    );
    return log;
  }

  testWidgets('tap opens the line, a second tap or Esc closes it', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('based on your last 6 times · median'), findsNothing);
    await tester.tap(find.text('usually 2 h 20'));
    await tester.pump();
    expect(find.text('based on your last 6 times · median'), findsOneWidget);
    expect(find.text('Reset for this task on this device'), findsOneWidget);
    await tester.tap(find.text('usually 2 h 20'));
    await tester.pump();
    expect(find.text('based on your last 6 times · median'), findsNothing);
    await tester.tap(find.text('usually 2 h 20'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('based on your last 6 times · median'), findsNothing);
  });

  testWidgets('keyboard: Tab to it, Enter opens', (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.text('based on your last 6 times · median'), findsOneWidget);
  });

  testWidgets('reset closes the line and offers Undo', (tester) async {
    final log = await pump(tester);
    await tester.tap(find.text('usually 2 h 20'));
    await tester.pump();
    await tester.tap(find.text('Reset for this task on this device'));
    await tester.pumpAndSettle();
    expect(log, ['reset']);
    expect(
      find.text('Learning for Deep work reset on this device'),
      findsOneWidget,
    );
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(log, ['reset', 'undo']);
  });

  testWidgets('not per title: explained, no reset', (tester) async {
    await pump(tester, withReset: false);
    await tester.tap(find.text('usually 2 h 20'));
    await tester.pump();
    expect(find.text('Reset for this task on this device'), findsNothing);
  });

  testWidgets('a button labelled with its value, 48 px, a11y guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    expect(
      tester.getSemantics(find.byType(LearnedLine)),
      matchesSemantics(
        label: 'usually 2 h 20, learned from your history',
        hint: 'Shows how this was worked out',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: false,
        hasExpandedState: true,
        isFocusable: true,
      ),
    );
    expect(
      tester.getSize(find.byType(InkWell)).height,
      greaterThanOrEqualTo(48),
    );
    await expectA11yGuidelines(tester);
    handle.dispose();
  });
}
