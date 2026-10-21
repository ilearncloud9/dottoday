import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

const _a = ThreadTask(
  id: 'a',
  title: 'Write',
  color: TaskColor.indigo,
  icon: TaskIcon.code,
  state: DotState.upcoming,
  timeRange: '9:00 – 9:30',
);
const _b = ThreadTask(
  id: 'b',
  title: 'Call',
  color: TaskColor.coral,
  icon: TaskIcon.mail,
  state: DotState.upcoming,
  timeRange: '10:00 – 10:30',
);

Widget _thread(Set<String> selected, List<String> log) => testApp(
  Scaffold(
    body: Thread(
      entries: const [ThreadTaskEntry(_a), ThreadTaskEntry(_b)],
      actions: ThreadActions(
        selectedIds: selected,
        onSelect: (id) => log.add('select $id'),
        onOpen: (id) => log.add('open $id'),
        drag: ThreadDrag(onDrop: (_, _, _, _) {}, hintFor: (_, _, _) => null),
      ),
    ),
  ),
);

void main() {
  testWidgets('long-press and let go without moving selects', (tester) async {
    final log = <String>[];
    await tester.pumpWidget(_thread(const {}, log));
    await tester.longPress(find.text('Write'));
    await tester.pumpAndSettle();
    expect(log, ['select a']);
  });

  testWidgets('Shift-click selects; a plain click opens', (tester) async {
    final log = <String>[];
    await tester.pumpWidget(_thread(const {}, log));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('Write'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('Call'));
    expect(log, ['select a', 'open b']);
  });

  testWidgets('while selecting, a tap anywhere on a row toggles it', (
    tester,
  ) async {
    final log = <String>[];
    await tester.pumpWidget(_thread(const {'a'}, log));
    await tester.tap(find.text('Call'));
    await tester.tap(find.byType(DoneCircle).first, warnIfMissed: false);
    expect(log, ['select b', 'select a']);
  });

  testWidgets('screen readers: "Select" action, then selected state '
      '(R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    final log = <String>[];
    await tester.pumpWidget(_thread(const {}, log));
    final row = find.semantics.byLabel(RegExp('^Write, upcoming'));
    tester.semantics.performAction(
      row,
      SemanticsAction.customAction,
      args: CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Select'),
      ),
    );
    expect(log, ['select a']);

    await tester.pumpWidget(_thread(const {'a'}, log));
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('^Write'))),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('^Call'))),
      isSemantics(isSelected: false, isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });
}
