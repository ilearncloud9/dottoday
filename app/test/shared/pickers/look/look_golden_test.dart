@Tags(['golden'])
library;

import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/reveal_row.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Colour and icon on phones (M19.4 part 4c-2): from option D's dot, the
/// compact sheet, All icons and All colours (with a custom colour and Your
/// colours), on the iPhone and Android, light and dark.
final _date = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 7, 22); // 09:22 Berlin

class _Recent extends RecentIcons {
  @override
  Future<List<String>> build() async => const ['run', 'book_open'];
}

void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester, ThemeMode mode, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = testProfile(
      settings: const Settings(use24h: false),
    ).copyWith(yourColours: const ['#E8A598', '#2E4A6B', '#000000']);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...timelineOverrides(
            now: _now,
            occurrences: FakeOccurrenceRepository(demoDayRows(_date)),
            subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
            profile: profile,
          ),
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
          recentIconsProvider.overrideWith(_Recent.new),
        ],
        child: testTaskApp(const TodayScreen(), themeMode: mode),
      ),
    );
    await tester.pumpAndSettle();
    await revealRow(tester, 'Reply to email');
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(RegExp('^Colour and icon')).first);
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

  Future<void> shot(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );

  const sizes = {
    TargetPlatform.iOS: Size(402, 874),
    TargetPlatform.android: Size(412, 915),
  };
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final MapEntry(key: p, value: size) in sizes.entries) {
      final name = p == TargetPlatform.iOS ? 'iphone' : 'android';
      testWidgets('golden: Colour and icon, $name, ${mode.name}', (
        tester,
      ) async {
        await on(p, () async {
          await pump(tester, mode, size);
          await shot('look_compact_${name}_${mode.name}');
          await tester.tap(find.byTooltip('All colours'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField).last, '#F0A28E');
          await tester.pumpAndSettle();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await shot('look_colours_${name}_${mode.name}');
        });
      });
    }
    testWidgets('golden: All icons, iphone, ${mode.name}', (tester) async {
      await on(TargetPlatform.iOS, () async {
        await pump(tester, mode, sizes[TargetPlatform.iOS]!);
        await tester.tap(find.textContaining('All icons ·'));
        await tester.pumpAndSettle();
        await shot('look_icons_iphone_${mode.name}');
      });
    });
  }
}
