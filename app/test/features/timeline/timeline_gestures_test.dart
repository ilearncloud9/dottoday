import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/timeline_screen.dart';
import 'package:dottoday/features/timeline/widgets/block_gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';

final _now = DateTime.utc(2026, 10, 21, 11); // 13:00 Berlin
final _date = DateTime(2026, 10, 21);

/// Core density at 100 % text: 1.8 px per minute.
const _pxPerMin = 1.8;

Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester, {
  Size size = const Size(420, 1400),
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository(demoDayRows(_date));
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(now: _now, occurrences: repo),
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: const TimelineScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Occurrence _row(FakeOccurrenceRepository repo, String title) =>
    repo.rows.firstWhere((o) => o.title == title);

/// Long-press [title] for 300 ms, drag by [dy], release.
Future<void> _longPressDrag(
  WidgetTester tester,
  String title,
  double dy, {
  Offset grab = Offset.zero,
}) async {
  final g = await tester.startGesture(
    tester.getCenter(find.text(title)) + grab,
  );
  await tester.pump(const Duration(milliseconds: 300));
  await g.moveBy(Offset(0, dy / 2));
  await tester.pump();
  await g.moveBy(Offset(0, dy / 2));
  await tester.pump();
  await g.up();
  await tester.pumpAndSettle();
}

List<String> _haptics(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add(call.arguments as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('long-press then drag moves a block by the dragged time', (
    tester,
  ) async {
    final repo = await _pump(tester);
    final before = _row(repo, 'Spanish lesson').startUtc!;
    await _longPressDrag(tester, 'Spanish lesson', 60 * _pxPerMin);
    final after = _row(repo, 'Spanish lesson');
    expect(after.startUtc, before.add(const Duration(hours: 1)));
    expect(after.durationMin, 60);
    expect(find.text('Moved to 15:00'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_row(repo, 'Spanish lesson').startUtc, before);
  });

  testWidgets('a swipe without the pause scrolls, never drags (R-05)', (
    tester,
  ) async {
    final repo = await _pump(tester, size: const Size(420, 700));
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    final offset = scrollable.position.pixels;
    final before = _row(repo, 'Lunch with Sam').startUtc;
    await tester.drag(find.text('Spanish lesson'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(offset));
    expect(_row(repo, 'Spanish lesson').startUtc, isNot(isNull));
    expect(
      repo.rows.map((o) => o.startUtc),
      demoDayRows(_date).map((o) => o.startUtc),
    );
    expect(_row(repo, 'Lunch with Sam').startUtc, before);
  });

  testWidgets('a tap does not move anything', (tester) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Spanish lesson'));
    await tester.pumpAndSettle();
    expect(
      repo.rows.map((o) => o.startUtc),
      demoDayRows(_date).map((o) => o.startUtc),
    );
  });

  testWidgets('drops snap to the 5-minute grid', (tester) async {
    final repo = await _pump(tester);
    final before = _row(repo, 'Spanish lesson').startUtc!;
    await _longPressDrag(tester, 'Spanish lesson', 7 * _pxPerMin);
    expect(
      _row(repo, 'Spanish lesson').startUtc,
      before.add(const Duration(minutes: 5)),
    );
  });

  testWidgets('pinned blocks do not lift and explain why (R-17)', (
    tester,
  ) async {
    final repo = await _pump(tester);
    final calls = _haptics(tester);
    final before = _row(repo, 'Lunch with Sam').startUtc;
    await _longPressDrag(tester, 'Lunch with Sam', 100);
    expect(_row(repo, 'Lunch with Sam').startUtc, before);
    expect(
      find.text('Pinned blocks stay put. Unpin it to move it.'),
      findsOneWidget,
    );
    expect(calls, contains('HapticFeedbackType.heavyImpact'));
  });

  testWidgets('a drop onto a pinned block settles after it', (tester) async {
    final repo = await _pump(tester);
    // Spanish 14:00 → 12:45 overlaps Lunch 12:30–13:15 (pinned).
    await _longPressDrag(tester, 'Spanish lesson', -75 * _pxPerMin);
    final lesson = _row(repo, 'Spanish lesson');
    expect(lesson.startUtc, _row(repo, 'Lunch with Sam').endUtc);
    expect(find.text('Moved to 13:15, after a pinned block'), findsOneWidget);
  });

  testWidgets('haptics: light on pick-up, selection tick per snap', (
    tester,
  ) async {
    await _pump(tester);
    final calls = _haptics(tester);
    await _longPressDrag(tester, 'Spanish lesson', 30 * _pxPerMin);
    expect(calls.first, 'HapticFeedbackType.lightImpact');
    expect(calls, contains('HapticFeedbackType.selectionClick'));
  });

  testWidgets('ghost and floating time label follow the drag', (tester) async {
    await _pump(tester);
    final g = await tester.startGesture(
      tester.getCenter(find.text('Spanish lesson')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await g.moveBy(const Offset(0, 60 * _pxPerMin));
    await tester.pump();
    expect(find.text('15:00–16:00'), findsWidgets);
    expect(find.text('Spanish lesson'), findsNWidgets(2)); // original + ghost
    await g.up();
    await tester.pumpAndSettle();
    expect(find.text('Spanish lesson'), findsOneWidget);
  });

  testWidgets('after a pick-up, handles resize the selected block', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await _longPressDrag(tester, 'Spanish lesson', 0);
    final end = find.bySemanticsLabel('Change end time');
    expect(end, findsOneWidget);
    await tester.drag(end, const Offset(0, 30 * _pxPerMin));
    await tester.pumpAndSettle();
    expect(_row(repo, 'Spanish lesson').durationMin, 90);
    expect(find.text('Now 14:00–15:30'), findsOneWidget);

    // Tapping empty time clears the selection.
    await tester.tapAt(
      tester.getTopLeft(find.byType(CustomScrollView)) + const Offset(30, 300),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Change end time'), findsNothing);
  });

  testWidgets('mouse: drag moves at once; the top edge resizes', (
    tester,
  ) async {
    final repo = await _pump(tester);
    final before = _row(repo, 'Spanish lesson').startUtc!;
    final mouse = await tester.startGesture(
      tester.getCenter(find.text('Spanish lesson')),
      kind: PointerDeviceKind.mouse,
    );
    await mouse.moveBy(const Offset(0, 20));
    await mouse.moveBy(const Offset(0, 30 * _pxPerMin - 20));
    await mouse.up();
    await tester.pumpAndSettle();
    final moved = _row(repo, 'Spanish lesson');
    expect(moved.startUtc, before.add(const Duration(minutes: 30)));

    final tile = find.ancestor(
      of: find.text('Spanish lesson'),
      matching: find.byType(BlockGestures),
    );
    final top = tester.getTopLeft(tile) + const Offset(150, 3);
    final edge = await tester.startGesture(top, kind: PointerDeviceKind.mouse);
    await edge.moveBy(const Offset(0, -20));
    await edge.moveBy(const Offset(0, -30 * _pxPerMin + 20));
    await edge.up();
    await tester.pumpAndSettle();
    final resized = _row(repo, 'Spanish lesson');
    expect(resized.startUtc, before);
    expect(resized.durationMin, 90);
  });

  testWidgets('holding near the bottom edge auto-scrolls', (tester) async {
    await _pump(tester, size: const Size(420, 700));
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    final start = scrollable.position.pixels;
    final target = tester.getCenter(find.text('Spanish lesson'));
    final drag = await tester.startGesture(target);
    await tester.pump(const Duration(milliseconds: 300));
    await drag.moveTo(Offset(target.dx, 700 - 10));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(scrollable.position.pixels, greaterThan(start + 100));
    await drag.up();
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion: dragging still works', (tester) async {
    final repo = await _pump(tester, reduceMotion: true);
    final before = _row(repo, 'Spanish lesson').startUtc!;
    await _longPressDrag(tester, 'Spanish lesson', 15 * _pxPerMin);
    expect(
      _row(repo, 'Spanish lesson').startUtc,
      before.add(const Duration(minutes: 15)),
    );
  });
}
