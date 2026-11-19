@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Mac Workspace (E-FullA-v2, M19.2 part 1a): sidebar and toolbar over
/// Week and 3 days on the hour grid and Day on hours (part 2), light and
/// dark.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester,
    ThemeMode mode, {
    String place = '/week/2026-10-21',
    bool steps = false,
    Size size = const Size(1280, 800),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        themeMode: mode,
        overrides: [
          ...timelineOverrides(
            now: DateTime.utc(2026, 10, 21, 8),
            occurrences: FakeOccurrenceRepository(
              demoDayRows(DateTime(2026, 10, 21)),
            ),
            subtasks: steps
                ? FakeSubtaskRepository(demoDaySubtasks(DateTime(2026, 10, 21)))
                : null,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go(place);
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('golden: the Mac Workspace, Week, ${mode.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_week_mac_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    testWidgets('golden: the Mac Workspace, Day, ${mode.name}', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode, place: '/today/2026-10-21');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_day_mac_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    // ED-116 on the grid: Spanish lesson under the pointer, Reply to email
    // keyboard-focused, Call the dentist dragged towards tomorrow.
    testWidgets('golden: hover, focus and drag on the grid, ${mode.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      try {
        await pump(tester, mode, place: '/3-days/2026-10-21');
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        Focus.of(tester.element(find.text('Reply to email'))).requestFocus();
        await tester.pumpAndSettle();
        final drag = await tester.startGesture(
          tester.getCenter(find.text('Call the dentist')),
          kind: PointerDeviceKind.mouse,
        );
        await drag.moveBy(const Offset(20, 20));
        await tester.pump();
        await drag.moveBy(const Offset(260, -40));
        await tester.pump();
        await mouse.moveTo(tester.getCenter(find.text('Spanish lesson')));
        await tester.pump();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_grid_states_${mode.name}.png'),
        );
        await drag.up();
        await mouse.removePointer();
        await tester.pumpAndSettle();
      } finally {
        debugDefaultTargetPlatformOverride = null;
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic;
      }
    });
    // ED-170 C1: a click picks the task into the docked inspector.
    testWidgets('golden: the inspector, ${mode.name}', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        // 3 days: the live task with its steps, as the board picks it.
        await pump(tester, mode, place: '/3-days/2026-10-21', steps: true);
        await tester.tap(find.textContaining('Deep work').first);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_inspector_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    // A second click: the full editor in the inspector's place (ED-391).
    testWidgets('golden: the editor from the grid, ${mode.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode);
        await tester.tap(find.text('Spanish lesson').first);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Spanish lesson').first);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_editor_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    // E-R2-30: Month as cards in the Workspace.
    testWidgets('golden: the Mac Workspace, Month, ${mode.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode, place: '/month/2026-10');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_month_mac_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    testWidgets('golden: the Mac Workspace, 3 days, ${mode.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode, place: '/3-days/2026-10-21');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_3days_mac_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    // E-G4-3-Narrow: the 840 minimum, its toolbar on one line (M19.2 3b).
    testWidgets('golden: the narrow Mac, Week at 840, ${mode.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode, size: const Size(840, 640));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_week_840_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
    // The picked Day row's 2 px ink edge (owner, M19.2 3b).
    testWidgets('golden: a picked Day row, ${mode.name}', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pump(tester, mode, place: '/today/2026-10-21');
        await tester.tap(find.text('Reply to email').first);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/workspace_day_picked_${mode.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
