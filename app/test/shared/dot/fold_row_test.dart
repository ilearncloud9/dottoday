import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/sample_earlier.dart';
import '../../support/test_app.dart';

/// Today's thread folded as DayPage does it, with the choice kept here.
class _Folded extends StatefulWidget {
  const _Folded();

  @override
  State<_Folded> createState() => _FoldedState();
}

class _FoldedState extends State<_Folded> {
  var _open = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: Thread(
        entries: foldEarlier(earlierDay, open: _open),
        actions: ThreadActions(
          onEarlier: (open) => setState(() => _open = open),
        ),
      ),
    ),
  );
}

ThreadTask _late(String id) => ThreadTask(
  id: id,
  title: 'Late $id',
  color: TaskColor.indigo,
  icon: TaskIcon.travel,
  state: DotState.upcoming,
  timeRange: '23:00 – 23:30',
);

void main() {
  testWidgets('Earlier is one button with no count; Show and Hide toggle it '
      '(ED-164)', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(testApp(const _Folded()));
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.text('Show'), findsOneWidget);
    expect(find.text('Morning run'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Earlier, done tasks')),
      matchesSemantics(
        label: 'Earlier, done tasks',
        isButton: true,
        hasExpandedState: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('Morning run'), findsOneWidget);
    expect(find.text('Hide'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Earlier, done tasks')),
      matchesSemantics(
        label: 'Earlier, done tasks',
        isButton: true,
        hasExpandedState: true,
        isExpanded: true,
        hasTapAction: true,
      ),
    );
    await expectA11yGuidelines(tester);
    handle.dispose();
  });

  testWidgets('keyboard: Tab reaches the row, Space toggles, → opens and ← '
      'closes (E-R2-39)', (tester) async {
    await tester.pumpWidget(testApp(const _Folded()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Morning run'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Morning run'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('Morning run'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Morning run'), findsNothing);
  });

  testWidgets('Minimal outside rows drop the count (ED-246)', (tester) async {
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: Thread(
            entries: [
              ThreadOutside(
                windDown: false,
                counted: false,
                tasks: [_late('a')],
              ),
              const ThreadCap.wake('7:00'),
              const ThreadCap.bed('22:00'),
              ThreadOutside(
                windDown: true,
                counted: false,
                open: true,
                tasks: [_late('b')],
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Before Wake Up'), findsOneWidget);
    expect(find.text('After Wind Down'), findsOneWidget);
    expect(find.text('Late b'), findsOneWidget);
    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('Show'), findsOneWidget);
  });
}
