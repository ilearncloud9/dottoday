import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

const _write = ThreadTask(
  id: 'write',
  title: 'Write',
  color: TaskColor.indigo,
  icon: TaskIcon.code,
  state: DotState.upcoming,
  timeRange: '9:00 – 9:30',
);
final _pinned = ThreadTask(
  id: 'call',
  title: 'Call',
  color: TaskColor.coral,
  icon: TaskIcon.mail,
  state: DotState.upcoming,
  timeRange: '11:00 – 11:30',
  movable: false,
  startUtc: _call,
  minutes: 30,
);
// 11:00 Berlin (CEST); the gap opens 9:30.
final _call = DateTime.utc(2026, 10, 21, 9);
final _gap = ThreadGap(
  minutes: 90,
  startLabel: '9:30',
  addable: true,
  startUtc: DateTime.utc(2026, 10, 21, 7, 30),
);

class _Log {
  _Log({this.shiftByDefault, this.calendarByDefault});

  final bool? shiftByDefault;
  final bool? calendarByDefault;
  final drops = <String>[];
  ThreadDrag get drag => ThreadDrag(
    shiftByDefault: shiftByDefault,
    calendarByDefault: calendarByDefault,
    onDrop: (id, span, f, shift) => drops.add(
      '$id ${_label(span)}${shift.followers ? ' shift' : ''}'
      '${shift.calendar ? ' +calendar' : ''}',
    ),
    hintFor: (id, span, f) => span == null ? null : '→ ${_label(span)}',
  );

  /// "9:30" for the gap, "on 11:00" for Call's row (Berlin, CEST).
  static String _label(DropSpan s) {
    final local = s.startUtc.add(const Duration(hours: 2));
    final time = '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
    return s.fit ? time : 'on $time';
  }
}

Widget _thread(_Log log, {double textScale = 1}) => testApp(
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Thread(
            entries: [
              const ThreadTaskEntry(_write),
              _gap,
              ThreadTaskEntry(_pinned),
            ],
            actions: ThreadActions(drag: log.drag),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('long-press lifts a task, the chip shows the drop time and '
      'letting go on a gap reports it (R-05)', (tester) async {
    final log = _Log();
    await tester.pumpWidget(_thread(log));
    final g = await tester.startGesture(tester.getCenter(find.text('Write')));
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
    await g.moveTo(tester.getCenter(find.textContaining('free')));
    await tester.pump();
    expect(find.text('→ 9:30'), findsOneWidget);
    await g.up();
    await tester.pumpAndSettle();
    expect(log.drops, ['write 9:30']);
    expect(find.text('→ 9:30'), findsNothing);
  });

  testWidgets('drag still drops at 200 % text (§7.4)', (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final log = _Log();
    await tester.pumpWidget(_thread(log, textScale: 2));
    final g = await tester.startGesture(tester.getCenter(find.text('Write')));
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
    await g.moveTo(tester.getCenter(find.textContaining('free')));
    await tester.pump();
    await g.up();
    await tester.pumpAndSettle();
    expect(log.drops, ['write 9:30']);
    expect(tester.takeException(), isNull);
  });

  group('Shift later tasks chip (R-04)', () {
    Future<TestGesture> lift(WidgetTester tester) async {
      final g = await tester.startGesture(tester.getCenter(find.text('Write')));
      await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
      await g.moveBy(const Offset(0, 4));
      await tester.pump();
      return g;
    }

    Future<void> dropOnGap(WidgetTester tester, TestGesture g) async {
      await g.moveTo(tester.getCenter(find.textContaining('free')));
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
    }

    testWidgets('shows while dragging, starts from the setting, and a '
        'second finger toggles it', (tester) async {
      final log = _Log(shiftByDefault: false);
      await tester.pumpWidget(_thread(log));
      expect(find.text('Shift later tasks'), findsNothing);
      final g = await lift(tester);
      expect(find.text('Shift later tasks'), findsOneWidget);
      // A fresh pointer id: a fixed one collided with the held drag's
      // under some test orders.
      await tester.tap(find.text('Shift later tasks'));
      await tester.pump();
      await dropOnGap(tester, g);
      expect(log.drops, ['write 9:30 shift']);
      expect(find.text('Shift later tasks'), findsNothing);
    });

    testWidgets('"always" starts on; holding Alt inverts it', (tester) async {
      final log = _Log(shiftByDefault: true);
      await tester.pumpWidget(_thread(log));
      await dropOnGap(tester, await lift(tester));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await dropOnGap(tester, await lift(tester));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      expect(log.drops, ['write 9:30 shift', 'write 9:30']);
    });

    testWidgets('"Calendar events too" shows beside it only while it is on, '
        'starts from the setting and rides along with the drop (M7.6)', (
      tester,
    ) async {
      final log = _Log(shiftByDefault: false, calendarByDefault: true);
      await tester.pumpWidget(_thread(log));
      final g = await lift(tester);
      expect(find.text('Calendar events too'), findsNothing);
      await tester.tap(find.text('Shift later tasks'));
      await tester.pump();
      expect(find.text('Calendar events too'), findsOneWidget);
      await tester.tap(find.text('Calendar events too'));
      await tester.pump();
      await dropOnGap(tester, g);
      // Started on (the setting), toggled off before the drop.
      expect(log.drops, ['write 9:30 shift']);
    });

    testWidgets('the calendar chip on reaches the drop; no events, no chip', (
      tester,
    ) async {
      final on = _Log(shiftByDefault: true, calendarByDefault: true);
      await tester.pumpWidget(_thread(on));
      final g = await lift(tester);
      expect(find.text('Calendar events too'), findsOneWidget);
      await dropOnGap(tester, g);
      expect(on.drops, ['write 9:30 shift +calendar']);

      final none = _Log(shiftByDefault: true);
      await tester.pumpWidget(_thread(none));
      final h = await lift(tester);
      expect(find.text('Shift later tasks'), findsOneWidget);
      expect(find.text('Calendar events too'), findsNothing);
      await dropOnGap(tester, h);
    });

    testWidgets('"never" shows no chip', (tester) async {
      final log = _Log();
      await tester.pumpWidget(_thread(log));
      final g = await lift(tester);
      expect(find.text('Shift later tasks'), findsNothing);
      await dropOnGap(tester, g);
      expect(log.drops, ['write 9:30']);
    });
  });

  testWidgets('a pinned task does not lift', (tester) async {
    final log = _Log();
    await tester.pumpWidget(_thread(log));
    final g = await tester.startGesture(tester.getCenter(find.text('Call')));
    await tester.pump(DotTouch.liftDelay * 2);
    await g.moveTo(tester.getCenter(find.textContaining('free')));
    await tester.pump();
    await g.up();
    await tester.pumpAndSettle();
    expect(log.drops, isEmpty);
  });

  testWidgets('a task drops onto another task\'s row, overlapping it '
      '(ADR-0015)', (tester) async {
    final log = _Log();
    await tester.pumpWidget(_thread(log));
    final g = await tester.startGesture(tester.getCenter(find.text('Write')));
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
    await g.moveTo(tester.getCenter(find.text('Call')));
    await tester.pump();
    expect(find.text('→ on 11:00'), findsOneWidget);
    await g.up();
    await tester.pumpAndSettle();
    expect(log.drops, ['write on 11:00']);
  });

  testWidgets('a task let go on its own row drops nothing', (tester) async {
    final log = _Log();
    await tester.pumpWidget(_thread(log));
    final g = await tester.startGesture(tester.getCenter(find.text('Write')));
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
    await g.moveBy(const Offset(0, 30));
    await tester.pump();
    await g.up();
    await tester.pumpAndSettle();
    expect(log.drops, isEmpty);
  });

  testWidgets('the day thread has no resize grip (ADR-0015)', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_thread(_Log()));
    expect(find.bySemanticsLabel(RegExp('^Change how long')), findsNothing);
    handle.dispose();
  });

  testWidgets('a week-strip day takes a dropped task (PRD F8)', (tester) async {
    final drops = <String>[];
    final log = _Log();
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: Column(
            children: [
              WeekStrip(
                days: [
                  for (var i = 0; i < 7; i++)
                    StripDay(
                      weekday: 'D$i',
                      date: '${i + 1}',
                      label: 'day $i',
                      completion: const Completion.none(),
                    ),
                ],
                selected: 0,
                onDropTask: (id, i) => drops.add('$id $i'),
              ),
              Thread(
                entries: const [ThreadTaskEntry(_write)],
                actions: ThreadActions(drag: log.drag),
              ),
            ],
          ),
        ),
      ),
    );
    final g = await tester.startGesture(tester.getCenter(find.text('Write')));
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
    await g.moveTo(tester.getCenter(find.text('D3')));
    await tester.pump();
    await g.up();
    await tester.pumpAndSettle();
    expect(drops, ['write 3']);
  });
}
