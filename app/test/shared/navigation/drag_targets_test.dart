import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// A task to drag in isolation: a plain [Draggable] with its id.
Widget _source(String id) => Draggable<String>(
  data: id,
  feedback: const SizedBox.square(dimension: 20),
  child: Text(id),
);

void main() {
  tearDown(() => TaskDragging.current.value = null);

  testWidgets('Trash shows only while a task is dragged, and takes it '
      '(ADR-0015)', (tester) async {
    final trashed = <String>[];
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: Column(
            children: [
              _source('write'),
              const SizedBox(height: 200),
              TrashDropZone(onTrash: trashed.add, label: 'Move to Trash'),
            ],
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Move to Trash'), findsNothing);
    TaskDragging.current.value = 'write';
    await tester.pump();
    expect(find.bySemanticsLabel('Move to Trash'), findsOneWidget);
    final g = await tester.startGesture(tester.getCenter(find.text('write')));
    await g.moveTo(tester.getCenter(find.bySemanticsLabel('Move to Trash')));
    await tester.pump();
    await g.up();
    await tester.pump();
    expect(trashed, ['write']);
  });

  testWidgets('the add button never lands in Trash or on a tab', (
    tester,
  ) async {
    final dropped = <String>[];
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: Column(
            children: [
              _source(newTaskDragId),
              const SizedBox(height: 200),
              TaskDropTab(
                onDropTask: dropped.add,
                child: const SizedBox.square(
                  dimension: DotTouch.android,
                  child: Text('Inbox'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final g = await tester.startGesture(
      tester.getCenter(find.text(newTaskDragId)),
    );
    await g.moveTo(tester.getCenter(find.text('Inbox')));
    await tester.pump();
    await g.up();
    await tester.pump();
    expect(dropped, isEmpty);
  });

  testWidgets('a task let go on the Inbox tab goes there', (tester) async {
    final dropped = <String>[];
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: Column(
            children: [
              _source('write'),
              const SizedBox(height: 200),
              TaskDropTab(
                onDropTask: dropped.add,
                child: const SizedBox.square(
                  dimension: DotTouch.android,
                  child: Text('Inbox'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final g = await tester.startGesture(tester.getCenter(find.text('write')));
    await g.moveTo(tester.getCenter(find.text('Inbox')));
    await tester.pump();
    await g.up();
    await tester.pump();
    expect(dropped, ['write']);
  });
}
