@Tags(['golden'])
library;

import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/widgets/sheet_tiles.dart';
import 'package:dottoday/shared/pickers/when/when_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The one When picker (E-Phones-2 "Move (the When picker)", ED-099;
/// M19.4 part 4b): Move from option D on the iPhone and Android, light and
/// dark.
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
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    final move = find.descendant(
      of: find.byType(SheetTile),
      matching: find.text('Move'),
    );
    await tester.ensureVisible(move);
    await tester.pumpAndSettle();
    await tester.tap(move);
    await tester.pumpAndSettle();
  }

  /// A plain 1280 window that opens Move for Reply to email: the Mac's
  /// popover (a task there opens the editor panel, not a sheet).
  Future<void> host(WidgetTester tester, ThemeMode mode) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final rows = FakeOccurrenceRepository(demoDayRows(_date));
    await tester.pumpWidget(
      ProviderScope(
        overrides: timelineOverrides(
          now: _now,
          occurrences: rows,
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
        child: testApp(
          Builder(
            builder: (context) => Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => showWhenPicker(
                    context,
                    task: rows.rows.firstWhere(
                      (o) => o.title == 'Reply to email',
                    ),
                    mode: WhenMode.move,
                    today: _date,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
          themeMode: mode,
        ),
      ),
    );
    await tester.tap(find.text('open'));
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
      testWidgets('golden: When picker, move, $name, ${mode.name}', (
        tester,
      ) async {
        await on(p, () async {
          await pump(tester, mode, size);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/when_move_${name}_${mode.name}.png'),
          );
        });
      });
    }
  }

  // The Mac popover (E-FullA-v2 "the When popover"): a typed time and ↵.
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('golden: When picker, Mac popover, ${mode.name}', (
      tester,
    ) async {
      await on(TargetPlatform.macOS, () async {
        await host(tester, mode);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/when_move_mac_${mode.name}.png'),
        );
      });
    });
  }
}
