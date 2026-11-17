import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/bead_hop.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/thread_pieces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

ThreadTaskEntry _task(String id, DotState state) => ThreadTaskEntry(
  ThreadTask(
    id: id,
    title: 'Task $id',
    color: TaskColor.mint,
    icon: TaskIcon.run,
    state: state,
    timeRange: '',
  ),
);

/// 9:59: A is live, the bead after it. 10:00: A has ended, B is live, and
/// the bead moved one row down.
final _before = <ThreadEntry>[
  const ThreadCap.wake('7:00'),
  _task('a', DotState.live),
  const ThreadNow('9:59'),
  _task('b', DotState.upcoming),
  const ThreadCap.bed('23:00'),
];
final _after = <ThreadEntry>[
  const ThreadCap.wake('7:00'),
  _task('a', DotState.done),
  _task('b', DotState.live),
  const ThreadNow('10:00'),
  const ThreadCap.bed('23:00'),
];

Widget _app(List<ThreadEntry> entries) =>
    testApp(Scaffold(body: Thread(entries: entries)));

double _beadHeight(WidgetTester tester) =>
    tester.getSize(find.byType(NowRow)).height;

void main() {
  testWidgets('the bead row closes where it was and opens where it lands, '
      '200 ms (ED-246, ED-364)', (tester) async {
    await tester.pumpWidget(_app(_before));
    expect(find.byType(BeadRow), findsOneWidget);
    await tester.pumpWidget(_app(_after));
    await tester.pump(const Duration(milliseconds: 100));
    // Mid-hop: the departing row and the arriving one, each part open.
    expect(find.byType(BeadRow), findsNWidgets(2));
    final mid = tester.getSize(find.byType(BeadRow).last).height;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(DotSize.threadRowNow));
    await tester.pumpAndSettle();
    expect(find.byType(BeadRow), findsOneWidget);
    expect(_beadHeight(tester), DotSize.threadRowNow);
  });

  testWidgets('a minute tick in the same row moves nothing', (tester) async {
    await tester.pumpWidget(_app(_before));
    await tester.pumpWidget(_app([..._before]..[2] = const ThreadNow('10:00')));
    expect(find.byType(BeadRow), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('Reduce Motion: the bead jumps', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(_app(_before));
    await tester.pumpWidget(_app(_after));
    expect(find.byType(BeadRow), findsOneWidget);
    expect(_beadHeight(tester), DotSize.threadRowNow);
  });

  testWidgets('a new current task is said once, politely', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(_before));
    await tester.pumpWidget(_app(_after));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(_after));
    expect(tester.takeAnnouncements().map((a) => a.message), ['Now: Task b']);
    handle.dispose();
  });
}
