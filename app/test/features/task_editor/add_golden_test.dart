// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

/// The four habits of `A-ios-add-what`, each used twice in the last weeks.
List<Occurrence> _habits() {
  var n = 0;
  Occurrence o(String title, String color, String icon, int hourUtc, int min) =>
      Occurrence(
        id: '01928c3e-0000-7000-8000-${(n++).toString().padLeft(12, '0')}',
        userId: testUserId,
        title: title,
        colorKey: color,
        iconKey: icon,
        startUtc: DateTime.utc(2026, 10, 10 + n, hourUtc),
        tzId: 'Europe/Berlin',
        durationMin: min,
        createdAt: DateTime.utc(2026, 10),
        updatedAt: DateTime.utc(2026, 10),
      );
  return [
    for (var i = 0; i < 2; i++) ...[
      o('Answer emails', 'slate', 'mail', 8, 15),
      o('Watch a movie', 'sky', 'tv', 18, 90),
      o('Go shopping', 'coral', 'bag', 15, 60),
      o('Go for a run', 'mint', 'run', 10, 60),
    ],
  ];
}

/// Today around the afternoon of `A-ios-add-when`: a call at 4:15 and
/// Spanish review at 7:30, so 5–6 PM is free until 7:30.
List<Occurrence> _today() {
  Occurrence o(String id, String title, String c, String i, int h, int m) =>
      Occurrence(
        id: '01928c3e-0000-7000-8000-0000000009$id',
        userId: testUserId,
        title: title,
        colorKey: c,
        iconKey: i,
        startUtc: DateTime.utc(2026, 10, 21, h, m),
        tzId: 'Europe/Berlin',
        durationMin: 30,
        createdAt: DateTime.utc(2026, 10),
        updatedAt: DateTime.utc(2026, 10),
      );
  return [
    o('01', 'Tidy desk', 'teal', 'document', 12, 45),
    o('02', 'Call Mum', 'amber', 'call', 14, 15),
    o('03', 'Spanish review', 'teal', 'language', 17, 30),
  ];
}

/// The sheet as it sits over Today: raised, 28 pt top corners; a centred
/// popover from medium width (`showAppSheet`).
Widget addSheet(GoldenCell cell, AddRequest request, {bool nested = false}) {
  final sheet = Builder(
    builder: (context) {
      final c = DotTheme.of(context).colors;
      return Container(
        decoration: BoxDecoration(
          color: c.raised,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DotRadii.sheet),
          ),
        ),
        padding: const EdgeInsets.only(top: DotSpace.l),
        child: AddFlowSheet(request: request),
      );
    },
  );
  return ProviderScope(
    overrides: timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 9),
      occurrences: FakeOccurrenceRepository([..._habits(), ..._today()]),
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
    child: nested
        ? Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: sheet,
                ),
              ),
            ),
          )
        : cell.width < WidthClass.mediumFrom
        ? Padding(padding: const EdgeInsets.only(top: 80), child: sheet)
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: appSheetMaxWidth,
                maxHeight: appSheetMaxHeight,
              ),
              child: sheet,
            ),
          ),
  );
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
    EditableText.debugDeterministicCursor = true;
  });
  tearDownAll(() => EditableText.debugDeterministicCursor = false);

  const shopping = AddRequest(languageCode: 'en', text: 'Go shopping');
  // A1 (`A-ios-add-what`): "Go shopping" typed, its habit ticked.
  goldenMatrix(
    'add_what',
    height: 844,
    build: (cell) => addSheet(cell, shopping),
  );
  goldenMatrix(
    'add_what_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    build: (cell) => addSheet(cell, shopping),
  );
  // A2 (`A-ios-add-when`): Continue from "Go shopping 5pm".
  const when = AddRequest(languageCode: 'en', text: 'Go shopping 5pm');
  Future<void> toWhen(WidgetTester tester) => tester.tap(find.text('Continue'));
  goldenMatrix(
    'add_when',
    height: 844,
    act: toWhen,
    build: (cell) => addSheet(cell, when),
  );
  goldenMatrix(
    'add_when_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    act: toWhen,
    build: (cell) => addSheet(cell, when),
  );
  // A3 (`A-ios-add-duration`): DURATION ⋯ at 1 h 30 from step 2.
  Future<void> toDuration(WidgetTester tester) async {
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1.5h'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More lengths'));
  }

  // Compact: the sheet opens on a nested navigator inside the frame (the
  // expanded popover uses the root navigator, outside the capture).
  goldenMatrix(
    'add_duration',
    height: 844,
    widths: const {'compact'},
    act: toDuration,
    build: (cell) => addSheet(cell, when, nested: true),
  );
  goldenMatrix(
    'add_duration_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    act: toDuration,
    build: (cell) => addSheet(cell, when, nested: true),
  );
  // A4 (`A-ios-add-time-menu`): the TIME ⋯ menu open.
  Future<void> toMenu(WidgetTester tester) async {
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More time options'));
  }

  goldenMatrix(
    'add_time_menu',
    height: 844,
    widths: const {'compact'},
    act: toMenu,
    build: (cell) => addSheet(cell, when, nested: true),
  );
  goldenMatrix(
    'add_time_menu_android',
    height: 915,
    platform: TargetPlatform.android,
    widths: const {'compact'},
    act: toMenu,
    build: (cell) => addSheet(cell, when, nested: true),
  );
  // Paste (derived, M3c.5): "Add 3 tasks?" under the title.
  goldenMatrix(
    'add_paste',
    height: 640,
    widths: const {'compact', 'expanded'},
    build: (cell) => addSheet(
      cell,
      const AddRequest(
        languageCode: 'en',
        text: '- Milk\n- Eggs 7pm\n- Call Mum tomorrow',
      ),
    ),
  );
  // A new user: no habits yet, so no Suggestions; the helper shows.
  goldenMatrix(
    'add_what_blank',
    height: 640,
    widths: const {'compact'},
    build: (cell) => ProviderScope(
      overrides: timelineOverrides(now: DateTime.utc(2026, 10, 21, 9)),
      child: addSheet(cell, const AddRequest(languageCode: 'en')),
    ),
  );
}
