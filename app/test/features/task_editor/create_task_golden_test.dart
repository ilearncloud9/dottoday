@Tags(['golden'])
library;

import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/routine_samples.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

/// Create task on the phones (E-Phones ED-140, ED-141; E-Phones-2 ED-147,
/// ED-149; M19.3 part 3a): the Task tab on an iPhone and an Android phone,
/// and the Brain dump and Routine tabs, light and dark.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester,
    ThemeMode mode, {
    required Size size,
    String tab = 'Task',
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
        onQuickAdd: () => openQuickAdd(router),
        overrides: [
          ...timelineOverrides(
            now: addNow,
            occurrences: FakeOccurrenceRepository(demoTimed()),
            profile: testProfile(settings: const Settings(use24h: false)),
            routines: sampleRoutines(),
          ),
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    openQuickAdd(router);
    await tester.pumpAndSettle();
    if (tab != 'Task') {
      await tester.tap(
        find
            .descendant(
              of: find.byType(CreateTaskSheet),
              matching: find.text(tab),
            )
            .hitTestable()
            .first,
      );
      await tester.pumpAndSettle();
    }
  }

  Future<void> on(TargetPlatform p, Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = p;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  const iphone = Size(402, 874);
  const android = Size(412, 915);

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final m = mode.name;
    testWidgets('golden: iPhone Create task, $m', (tester) async {
      await on(TargetPlatform.iOS, () async {
        await pump(tester, mode, size: iphone);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/create_task_iphone_$m.png'),
        );
      });
    });
    testWidgets('golden: Android Create task, $m', (tester) async {
      await on(TargetPlatform.android, () async {
        await pump(tester, mode, size: android);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/create_task_android_$m.png'),
        );
      });
    });
    testWidgets('golden: iPhone Add › Routine, $m', (tester) async {
      await on(TargetPlatform.iOS, () async {
        await pump(tester, mode, size: iphone, tab: 'Routine');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/create_task_routine_iphone_$m.png'),
        );
      });
    });
  }
}
