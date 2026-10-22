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

/// The sheet as it sits over Today: raised, 28 pt top corners; a centred
/// popover from medium width (`showAppSheet`).
Widget addSheet(GoldenCell cell, AddRequest request) {
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
      occurrences: FakeOccurrenceRepository(_habits()),
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
    child: cell.width < WidthClass.mediumFrom
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
