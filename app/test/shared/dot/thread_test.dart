import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/thread_pieces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/sample_day.dart';
import '../../support/test_app.dart';

Widget _thread({
  ThreadActions actions = const ThreadActions(),
  ThemeMode mode = ThemeMode.light,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
}) => testApp(
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Thread(entries: mainThread, actions: actions),
          ),
        ),
      ),
    ),
  ),
  themeMode: mode,
);

void main() {
  testWidgets('dot, done circle, row and live buttons report the task', (
    tester,
  ) async {
    final log = <String>[];
    await tester.pumpWidget(
      _thread(
        actions: ThreadActions(
          onToggleDone: (id) => log.add('done $id'),
          onOpen: (id) => log.add('open $id'),
          onExtend: (id) => log.add('extend $id'),
          onShiftRest: (id) => log.add('shift $id'),
          onAddHere: (g) => log.add('add ${g.startLabel}'),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Reply to email, upcoming'));
    await tester.tap(find.byType(DoneCircle).first);
    await tester.tap(find.text('Reply to email'));
    await tester.tap(find.text('+15 min'));
    await tester.tap(find.text('Shift the rest'));
    await tester.tap(find.text('Done'));
    await tester.tap(find.text('1 h free · add here'));
    expect(log, [
      'done mail',
      'done deep',
      'open mail',
      'extend deep',
      'shift deep',
      'done deep',
      'add 11:30',
    ]);
  });

  testWidgets('screen reader hears each row with its state (R-12)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_thread(actions: ThreadActions(onOpen: (_) {})));
    for (final label in [
      'Deep work: roadmap, live, 38 minutes left',
      'Deep work: roadmap, 9:00 – 11:00, 1 of 3',
      'Morning run, done',
      'Lunch with Sam, 12:30 – 1:15, pinned',
      'Spanish lesson, 2:00 – 3:00, repeats',
      'Call the dentist, 4:00 – 4:15, not done',
      'Spanish review, skipped',
      '1 h free from 11:30. Add a task here',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    // The done circle duplicates the dot's toggle and stays silent.
    expect(find.bySemanticsLabel(RegExp('circle')), findsNothing);
    handle.dispose();
  });

  testWidgets('an imported event shows the calendar badge (F1.10)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      testApp(
        const Material(
          child: TaskRow(
            task: ThreadTask(
              id: 'standup',
              title: 'Team standup',
              color: TaskColor.slate,
              icon: TaskIcon.people,
              state: DotState.upcoming,
              timeRange: '3:00 – 3:15',
              imported: true,
            ),
          ),
        ),
      ),
    );
    final badge = find.byWidgetPredicate(
      (w) => w is DotIcon && w.glyph == DotGlyphs.calendar,
    );
    expect(badge, findsOneWidget);
    expect(
      find.bySemanticsLabel('Team standup, 3:00 – 3:15, from your calendar'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('outside hours: folded, then unfolded by a tap (F1.15)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final opened = <String>[];
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: Thread(
            entries: [
              const ThreadCap.wake('7:00'),
              const ThreadCap.bed('22:00'),
              ThreadOutside(
                bedtime: true,
                tasks: [
                  for (final id in ['a', 'b'])
                    ThreadTask(
                      id: id,
                      title: 'Late $id',
                      color: TaskColor.indigo,
                      icon: TaskIcon.travel,
                      state: DotState.upcoming,
                      timeRange: '23:00 – 23:30',
                    ),
                ],
              ),
            ],
            actions: ThreadActions(onOpen: opened.add),
          ),
        ),
      ),
    );
    expect(find.text('2 tasks after Bedtime'), findsOneWidget);
    expect(find.text('Late a'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('2 tasks after Bedtime')),
      matchesSemantics(
        label: '2 tasks after Bedtime',
        isButton: true,
        hasExpandedState: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.text('2 tasks after Bedtime'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Late b'));
    expect(opened, ['b']);
    await expectA11yGuidelines(tester);
    handle.dispose();
  });

  testWidgets('done titles are struck through', (tester) async {
    await tester.pumpWidget(_thread());
    final style = tester.widget<Text>(find.text('Morning run')).style!;
    expect(style.decoration, TextDecoration.lineThrough);
  });

  testWidgets('200 % text: rows grow, nothing overflows or ellipsises', (
    tester,
  ) async {
    await tester.pumpWidget(_thread(textScale: 2));
    expect(tester.takeException(), isNull);
    final texts = tester.widgetList<Text>(find.byType(Text));
    expect(texts.where((t) => t.overflow == TextOverflow.ellipsis), isEmpty);
  });

  testWidgets('RTL puts the thread on the right edge', (tester) async {
    await tester.pumpWidget(_thread(direction: TextDirection.rtl));
    final dot = tester.getCenter(
      find.bySemanticsLabel('Reply to email, upcoming'),
    );
    final title = tester.getCenter(find.text('Reply to email'));
    expect(dot.dx, greaterThan(title.dx));
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      await tester.pumpWidget(
        _thread(
          mode: mode,
          actions: ThreadActions(
            onToggleDone: (_) {},
            onOpen: (_) {},
            onExtend: (_) {},
            onShiftRest: (_) {},
            onAddHere: (_) {},
          ),
        ),
      );
      await expectA11yGuidelines(tester);
    });
  }

  testWidgets('Settings › Show free time off: no gap label (M3d.2)', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        const Material(
          child: GapRow(
            gap: ThreadGap(
              minutes: 60,
              startLabel: '11:30',
              addable: true,
              labelled: false,
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('free'), findsNothing);
  });
}
