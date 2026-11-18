import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/layout/layout_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/timeline_fakes.dart';
import '../support/today_harness.dart';

/// ED-100: switching Full ↔ Minimal mid-action. A drag or a selection in
/// progress is dropped with nothing written; the date, the open task,
/// saved and unsaved edits and Undo all carry over.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(TodayScreen)));

  Future<void> switchLayout(
    WidgetTester tester, {
    required bool minimal,
  }) async {
    setLayout(tester.element(find.byType(TodayScreen)), minimal: minimal);
    await tester.pumpAndSettle();
    expect(
      containerOf(tester).read(layoutPolicyProvider).isMinimal,
      minimal,
      reason: 'the switch was written',
    );
  }

  test('a drag begun before a switch is void; the next one is live', () {
    DragSession.began();
    expect(DragSession.live, isTrue);
    DragSession.voidAll();
    expect(DragSession.live, isFalse);
    DragSession.began();
    expect(DragSession.live, isTrue);
  });

  testWidgets('the switch voids the drag in flight', (tester) async {
    await pumpToday(tester, wrap: (w) => LayoutSwitchGuard(child: w));
    DragSession.began();
    await switchLayout(tester, minimal: true);
    expect(DragSession.live, isFalse);
  });

  testWidgets('a selection is cleared without applying anything', (
    tester,
  ) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await pumpToday(tester, repo: repo);
    final before = [...repo.rows];
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(taskSelectionProvider).ids, isNotEmpty);
    await switchLayout(tester, minimal: true);
    expect(containerOf(tester).read(taskSelectionProvider).ids, isEmpty);
    expect(repo.rows, before, reason: 'nothing written');
  });

  testWidgets('the shown day and the open task stay', (tester) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await pumpToday(tester, repo: repo, date: DateTime(2026, 10, 22));
    final router = GoRouter.of(tester.element(find.byType(TodayScreen)));
    final task = repo.rows.firstWhere((o) => o.startUtc != null);
    router.go('/day/2026-10-22?task=${task.id}');
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await switchLayout(tester, minimal: true);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/day/2026-10-22?task=${task.id}',
    );
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('Undo still reverts a change made before the switch', (
    tester,
  ) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await pumpToday(tester, repo: repo);
    final container = containerOf(tester);
    final task = repo.rows.firstWhere(
      (o) => o.status == OccurrenceStatus.planned && o.startUtc != null,
    );
    final ref = tester.element(find.byType(TodayScreen)) as WidgetRef;
    await toggleDone(ref, task);
    await tester.pumpAndSettle();
    expect(
      repo.rows.firstWhere((o) => o.id == task.id).status,
      OccurrenceStatus.done,
    );
    await switchLayout(tester, minimal: true);
    final undo = container.read(undoServiceProvider);
    await undo.undo(undo.latest!);
    await tester.pumpAndSettle();
    expect(
      repo.rows.firstWhere((o) => o.id == task.id).status,
      OccurrenceStatus.planned,
    );
  });

  testWidgets('a title being typed in the editor panel is saved, not lost', (
    tester,
  ) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await pumpToday(
      tester,
      repo: repo,
      size: const Size(1280, 900),
      wrap: (w) => EditorPanelFrame(child: w),
    );
    final container = containerOf(tester);
    final task = repo.rows.firstWhere((o) => o.title == 'Deep work: roadmap');
    container.read(editingTaskProvider.notifier).open(task.id);
    await tester.pumpAndSettle();
    final title = find.widgetWithText(TextField, 'Deep work: roadmap');
    expect(title, findsWidgets);
    await tester.enterText(title.first, 'Deep work: plan');
    // Before the 600 ms autosave: the switch closes the full editor.
    await switchLayout(tester, minimal: true);
    expect(
      repo.rows.firstWhere((o) => o.id == task.id).title,
      'Deep work: plan',
    );
  });
}
