// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/timeline_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/timeline_fakes.dart';

// 13:00 in Berlin on the demo day: some blocks past, now-line mid-day.
final _now = DateTime.utc(2026, 10, 21, 11);
final _date = DateTime(2026, 10, 21);

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  List<Occurrence>? rows,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: _now,
        occurrences: FakeOccurrenceRepository(rows ?? demoDayRows(_date)),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const TimelineScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// [count] 15-minute blocks spread evenly over the day (stress layout).
List<Occurrence> _many(int count) {
  final berlin = tz.getLocation('Europe/Berlin');
  final start = tz.TZDateTime(berlin, 2026, 10, 21).toUtc();
  final base = demoDayRows(_date).first;
  return [
    for (var i = 0; i < count; i++)
      base.copyWith(
        id: '01928c3e-0000-7000-8000-${i.toString().padLeft(12, '0')}',
        title: 'Block $i',
        startUtc: start.add(Duration(minutes: i * 1440 ~/ count)),
        durationMin: 15,
        status: base.status,
        pinned: false,
      ),
  ];
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  // Tall enough that the whole day, top to bottom, is in one image (R-14).
  const fullDay = Size(420, 1900);

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('full day, demo, ${mode.name}', (tester) async {
      await _pump(tester, size: fullDay, mode: mode);
      await expectLater(
        find.byType(TimelineScreen),
        matchesGoldenFile('goldens/timeline_full_day_${mode.name}.png'),
      );
    });
  }

  testWidgets('full day, demo, 200 % text', (tester) async {
    await _pump(tester, size: const Size(420, 3700), textScale: 2);
    await expectLater(
      find.byType(TimelineScreen),
      matchesGoldenFile('goldens/timeline_full_day_200.png'),
    );
  });

  testWidgets('empty day', (tester) async {
    await _pump(tester, size: fullDay, rows: const []);
    await expectLater(
      find.byType(TimelineScreen),
      matchesGoldenFile('goldens/timeline_empty.png'),
    );
  });

  testWidgets('bottom of the day renders (R-14)', (tester) async {
    await _pump(tester, size: const Size(420, 800));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TimelineScreen),
      matchesGoldenFile('goldens/timeline_bottom.png'),
    );
  });

  testWidgets('one block', (tester) async {
    await _pump(tester, size: fullDay, rows: [demoDayRows(_date)[2]]);
    await expectLater(
      find.byType(TimelineScreen),
      matchesGoldenFile('goldens/timeline_one_block.png'),
    );
  });

  for (final count in [30, 200]) {
    testWidgets('$count blocks', (tester) async {
      await _pump(tester, size: fullDay, rows: _many(count));
      await expectLater(
        find.byType(TimelineScreen),
        matchesGoldenFile('goldens/timeline_$count.png'),
      );
    });
  }
}
