@Tags(['golden'])
library;

import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Option D's task sheet on phones (E-Phones F3 and the Task editor row,
/// ED-086; M19.4 part 4a): Deep work at its medium detent and pulled up,
/// on the iPhone and Android, light and dark.
final _date = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 7, 22); // 09:22 Berlin

void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester, ThemeMode mode, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...timelineOverrides(
            now: _now,
            occurrences: FakeOccurrenceRepository(demoDayRows(_date)),
            subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
            profile: testProfile(settings: const Settings(use24h: false)),
          ),
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: testTaskApp(const TodayScreen(), themeMode: mode),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deep work: roadmap').first);
    await tester.pumpAndSettle();
  }

  Future<void> on(TargetPlatform p, Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = p;
    debugDisableShadows = false;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
      debugDisableShadows = true;
    }
  }

  const sizes = {
    TargetPlatform.iOS: Size(402, 874),
    TargetPlatform.android: Size(412, 915),
  };
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final MapEntry(key: p, value: size) in sizes.entries) {
      final name = p == TargetPlatform.iOS ? 'iphone' : 'android';
      testWidgets('golden: option D, medium, $name, ${mode.name}', (
        tester,
      ) async {
        await on(p, () async {
          await pump(tester, mode, size);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/task_d_medium_${name}_${mode.name}.png'),
          );
        });
      });
      testWidgets('golden: option D, full, $name, ${mode.name}', (
        tester,
      ) async {
        await on(p, () async {
          await pump(tester, mode, size);
          // Pulled up to the full editor, its top in view (no fling).
          await tester.drag(
            find.text('Pull up for date, alerts, steps and notes'),
            const Offset(0, -300),
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/task_d_full_${name}_${mode.name}.png'),
          );
        });
      });
    }
  }

  // Kept from the old editor, placed quietly (owner, M19.4): a step's ⋯,
  // the time row's "Time and length" sheet, and ⋯'s Break it down.
  final kept = <String, Future<void> Function(WidgetTester)>{
    'step_menu': (t) async {
      await t.drag(
        find.text('Pull up for date, alerts, steps and notes'),
        const Offset(0, -300),
      );
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Draft milestones'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Options for Draft milestones'));
    },
    'time_sheet': (t) async {
      await t.tap(find.text('9:00 AM – 11:00 AM').last);
    },
    'menu': (t) async {
      // The sheet's own ⋯ (Today's header has one too).
      await t.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byTooltip('More options'),
        ),
      );
    },
  };
  for (final MapEntry(key: name, value: act) in kept.entries) {
    testWidgets('golden: option D kept, $name', (tester) async {
      await on(TargetPlatform.iOS, () async {
        await pump(tester, ThemeMode.light, sizes[TargetPlatform.iOS]!);
        await act(tester);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/task_d_kept_$name.png'),
        );
      });
    });
  }
}
