import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/features/timeline/workspace/inspector/workspace_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'calendar/calendar_world.dart';

/// The Week for screen readers and the keyboard (ED-248 B, E-DF3): it
/// reads day by day, each heading with its count and planned time, then
/// that day's cards in start order; an overlap is said; the grid is one
/// Tab stop that lands on today's first card.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  final call = calendarMonth().firstWhere((o) => o.title == 'Call with Sam');
  final rows = [
    ...calendarMonth(),
    call.copyWith(id: 'overlap', title: 'Quick sync'),
  ];

  Future<void> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = await pumpCalendar(tester, rows: rows);
    router.go(AppRoutes.weekOf(DateTime(2026, 11, 3)));
    await tester.pumpAndSettle();
  }

  /// What a screen reader says, in its order.
  List<String> reading(WidgetTester tester) {
    final said = <String>[];
    void walk(SemanticsNode n) {
      if (n.label.isNotEmpty) said.add(n.label);
      n
          .debugListChildrenInOrder(DebugSemanticsDumpOrder.traversalOrder)
          .forEach(walk);
    }

    walk(
      tester
          .binding
          .renderViews
          .first
          .owner!
          .semanticsOwner!
          .rootSemanticsNode!,
    );
    return said;
  }

  testWidgets('day by day: the heading with its count, then its cards', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    final said = reading(tester);
    int at(String start) => said.indexWhere((s) => s.startsWith(start));
    final monday = at('Monday, November 2,');
    final tuesday = at('Tuesday, November 3, today, 10 tasks,');
    final wednesday = at('Wednesday, November 4,');
    expect([monday, tuesday, wednesday], everyElement(isNonNegative));
    expect(monday, lessThan(tuesday));
    expect(tuesday, lessThan(wednesday));
    // Tuesday's cards sit between its heading and Wednesday's.
    for (final title in ['Deep work: roadmap', 'Lunch', 'Pick up parcel']) {
      final i = at('$title,');
      expect(i, greaterThan(tuesday), reason: title);
      expect(i, lessThan(wednesday), reason: title);
    }
    // In start order within the day.
    expect(at('Deep work: roadmap,'), lessThan(at('Lunch,')));
    semantics.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('overlapping cards say so', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Call with Sam, .*, overlaps Quick sync$'),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Quick sync, .*, overlaps Call with Sam$'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('Tab reaches one card, today\'s first; arrows move on', (
    tester,
  ) async {
    await pump(tester);
    String? card() => FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<WeekCard>()
        ?.task
        .title;
    final reached = <String>{};
    for (var i = 0; i < 80; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      if (card() case final title?) reached.add(title);
    }
    expect(reached, {'Morning run'});
    // On the card, ↓ goes to the next one that day.
    while (card() == null) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(card(), 'Standup');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('Esc from the inspector gives focus back to the card', (
    tester,
  ) async {
    await pump(tester);
    String? card() => FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<WeekCard>()
        ?.task
        .title;
    for (var i = 0; i < 80 && card() == null; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    expect(card(), 'Morning run');
    // As Return picks it (the fixture's ids are not links, so set it).
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WeekCard).first),
    );
    final id = rows.firstWhere((o) => o.title == 'Morning run').id;
    container.read(inspectedTaskProvider.notifier).show(id);
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsOneWidget);
    // Into the inspector, then Esc.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsNothing);
    expect(card(), 'Morning run');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
