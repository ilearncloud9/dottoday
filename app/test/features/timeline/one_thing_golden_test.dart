// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_sheet.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/sample_inbox.dart';
import '../../support/timeline_fakes.dart';

// Pick today's one thing (E-R2-34 section 2, ED-339): today's dots, then
// the Inbox, the pick ringed and tinted; the empty case. A sheet on
// phones, a centred dialog from medium width.

final _day = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 7, 22);

/// The first of the demo day's dots still ahead, picked.
Occurrence _pick() => demoDayRows(
  _day,
).where((o) => o.startUtc != null && o.startUtc!.isAfter(_now)).first;

Widget _opener() => Scaffold(
  // Keeps the profile and today alive, as Today does.
  body: Consumer(
    builder: (context, ref, _) {
      ref
        ..watch(currentProfileProvider)
        ..watch(todayDateProvider);
      return Center(
        child: TextButton(
          onPressed: () => unawaited(showOneThingSheet(context)),
          child: const Text('open'), // l10n-ignore: test trigger
        ),
      );
    },
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

List<Override> _overrides({bool empty = false}) => timelineOverrides(
  now: _now,
  occurrences: FakeOccurrenceRepository(
    empty ? const [] : [...demoDayRows(_day), ...sampleInbox()],
  ),
  profile: testProfile(
    settings: Settings(
      use24h: false,
      firstDayOfWeek: 1,
      oneThing: empty
          ? null
          : OneThing(date: '2026-10-21', occurrenceId: _pick().id),
    ),
  ),
);

void main() {
  tz_data.initializeTimeZones();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'one_thing_sheet',
    height: 900,
    widths: const {'compact', 'expanded'},
    overrides: _overrides(),
    build: (_) => _opener(),
    act: _open,
  );
  goldenMatrix(
    'one_thing_sheet_android',
    height: 900,
    widths: const {'compact'},
    platform: TargetPlatform.android,
    overrides: _overrides(),
    build: (_) => _opener(),
    act: _open,
  );
  goldenMatrix(
    'one_thing_sheet_empty',
    height: 700,
    widths: const {'compact'},
    overrides: _overrides(empty: true),
    build: (_) => _opener(),
    act: _open,
  );
}
