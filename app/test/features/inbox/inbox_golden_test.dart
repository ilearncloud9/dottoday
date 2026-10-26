// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/inbox/inbox_sidebar.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/sample_inbox.dart';
import '../../support/timeline_fakes.dart';

/// I1 at 11:00 on the demo day (`A-ios-inbox`).
void main() {
  // Some overrides are built as the tests are declared.
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  goldenMatrix('inbox', height: 844, build: (_) => _inbox(sampleInbox()));
  // "Pick a time…" (derived, M3c.2): Call Mum on today's thread.
  goldenMatrix(
    'inbox_pick_time',
    height: 844,
    // Sheets open on the root navigator, so the overrides scope the app.
    widths: const {'compact'},
    overrides: _overrides(sampleInbox()),
    act: (tester) async {
      await tester.tap(find.byTooltip('Schedule').at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pick a time…'));
    },
    build: (_) => const InboxScreen(),
  );
  // M3e.2: Today with the 300 px Inbox sidebar (`A-mac-week-alt3-board`).
  goldenMatrix(
    'today_inbox_sidebar',
    height: 800,
    widths: const {'expanded'},
    build: (_) => _inbox(
      sampleInbox(),
      screen: const InboxSidebarFrame(child: TodayScreen()),
    ),
  );
  // M3f.6: the Completed group open (done day, not-done button, Clear).
  goldenMatrix(
    'inbox_completed_open',
    height: 1100,
    widths: const {'compact', 'expanded'},
    act: (tester) async {
      await tester.tap(find.text('Completed · 2'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Clear completed'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    },
    build: (_) => _inbox(sampleInbox()),
  );
  // M3f.9c: two picked, the selection bar.
  goldenMatrix(
    'inbox_selecting',
    height: 844,
    widths: const {'compact', 'expanded'},
    act: (tester) async {
      // Right-click: on Mac/web a touch hold drags the row instead.
      await tester.tap(find.text('Do taxes'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Call Mum'));
    },
    build: (_) => _inbox(sampleInbox()),
  );
  // §5.4 empty state: "Inbox is clear".
  goldenMatrix(
    'inbox_empty',
    height: 500,
    widths: const {'compact', 'expanded'},
    build: (_) => _inbox(const []),
  );
}

/// The demo day's timed rows plus [items] in the Inbox.
List<Override> _overrides(List<Occurrence> items) => timelineOverrides(
  now: DateTime.utc(2026, 10, 21, 9),
  learningMeta: captionPutAway(DateTime(2026, 10, 21)),
  occurrences: FakeOccurrenceRepository([
    for (final o in demoDayRows(DateTime(2026, 10, 21)))
      if (o.startUtc != null) o,
    ...items,
  ]),
  profile: testProfile(settings: const Settings(use24h: false)),
);

Widget _inbox(List<Occurrence> items, {Widget screen = const InboxScreen()}) =>
    ProviderScope(overrides: _overrides(items), child: screen);
