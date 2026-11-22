// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:dottoday/features/search/widgets/search_or_run.dart';
import 'package:dottoday/features/search/widgets/search_or_run_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/sample_search.dart';
import '../../support/timeline_fakes.dart';

Widget _search() => ProviderScope(
  overrides: timelineOverrides(
    now: searchNow,
    occurrences: FakeOccurrenceRepository(sampleSearchRows()),
    profile: testProfile(settings: const Settings(use24h: false)),
    recentSearches: const ['taxes', 'Spanish', 'Sam'],
  ),
  child: const SearchScreen(),
);

Future<void> _type(WidgetTester tester, String text) =>
    tester.enterText(find.byType(TextField), text);

/// The palette over Search with some of the Mac's menu commands, [typed]
/// in its field.
Future<void> _palette(WidgetTester tester, String typed) async {
  void noop() {}
  // Not awaited: it completes when the palette closes.
  // ignore: unawaited_futures
  showSearchOrRun(
    tester.element(find.byType(SearchScreen)),
    commands: [
      PaletteCommand('New Task', noop, keys: '⌘N'),
      PaletteCommand('New Brain Dump', noop, keys: '⇧⌘N'),
      PaletteCommand('Today', noop, keys: '⌘1'),
      PaletteCommand('Inbox', noop, keys: '⌘2'),
      PaletteCommand('Go to Date…', noop, keys: '⇧⌘T'),
      PaletteCommand('Show Inspector', noop, keys: '⌥⌘I'),
    ],
    placeholder: 'Search or run',
  );
  await tester.pumpAndSettle();
  if (typed.isNotEmpty) {
    await tester.enterText(find.byType(TextField).last, typed);
  }
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
    EditableText.debugDeterministicCursor = true;
  });
  tearDownAll(() => EditableText.debugDeterministicCursor = false);

  // S1 (`A-ios-search`): "roadmap" with today / Monday / Friday / Inbox.
  goldenMatrix(
    'search',
    height: 844,
    act: (t) => _type(t, 'roadmap'),
    build: (_) => _search(),
  );
  goldenMatrix(
    'search_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    act: (t) => _type(t, 'roadmap'),
    build: (_) => _search(),
  );
  // The Mac's Search (E-R2-30): result cards, "4 results", Schedule.
  goldenMatrix(
    'search_mac',
    height: 800,
    platform: TargetPlatform.macOS,
    widths: const {'expanded'},
    act: (t) => _type(t, 'roadmap'),
    build: (_) => _search(),
  );
  goldenMatrix(
    'search_mac_no_results',
    height: 640,
    platform: TargetPlatform.macOS,
    widths: const {'expanded'},
    act: (t) async {
      await _type(t, 'zebra');
      await t.pumpAndSettle();
      await t.tap(find.text('Done'));
    },
    build: (_) => _search(),
  );
  // Search or run, ⌘K (E-R2-30 frame 3): tasks, then commands.
  for (final (name, typed) in [
    ('search_or_run', 'road'),
    ('search_or_run_empty', ''),
  ]) {
    goldenMatrix(
      name,
      height: 640,
      platform: TargetPlatform.macOS,
      widths: const {'expanded'},
      act: (t) => _palette(t, typed),
      build: (_) => _search(),
    );
  }
  // §5.3: nothing typed (recent + hint) and no results.
  goldenMatrix(
    'search_empty',
    height: 640,
    widths: const {'compact', 'expanded'},
    build: (_) => _search(),
  );
  goldenMatrix(
    'search_no_results',
    height: 640,
    widths: const {'compact', 'expanded'},
    act: (t) => _type(t, 'zebra'),
    build: (_) => _search(),
  );
}
